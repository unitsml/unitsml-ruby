# frozen_string_literal: true

require "mml"
require "htmlentities"

module Unitsml
  class Formula
    include MathmlHelper
    include Compose::Composable

    attr_accessor :value, :explicit_value, :root

    def initialize(value = [],
                   explicit_value: nil,
                   root: false,
                   orig_text: nil,
                   norm_text: nil)
      @value = value
      @explicit_value = explicit_value
      @root = root
      @orig_text = orig_text
      @norm_text = norm_text
    end

    def ==(other)
      self.class == other.class &&
        value == other&.value &&
        explicit_value == other&.explicit_value &&
        root == other.root
    end

    def to_mathml(options = {})
      guard_renderable!
      if root
        options = update_options(options)
        math = mml_v4_new(:math, display: "block")
        math.ordered = true
        math.element_order ||= []
        value.each do |instance|
          process_value(math, instance.to_mathml(options))
        end
        generated_math = math.to_xml(register: mml_v4_context.id)
          .gsub(%r{&amp;(.*?)(?=</)}, '&\1')

        generated_math.force_encoding("UTF-8")
      else
        value.map { |obj| obj.to_mathml(options) }
      end
    end

    def to_latex(options = {})
      guard_renderable!
      value.map { |obj| obj.to_latex(update_options(options)) }.join
    end

    def to_asciimath(options = {})
      guard_renderable!
      value.map { |obj| obj.to_asciimath(update_options(options)) }.join
    end

    def to_html(options = {})
      guard_renderable!
      value.map { |obj| obj.to_html(update_options(options)) }.join
    end

    def to_unicode(options = {})
      guard_renderable!
      value.map { |obj| obj.to_unicode(update_options(options)) }.join
    end

    def to_xml(options = {})
      guard_renderable!
      options = update_options(options)
      if (dimensions_array = extract_dimensions(value)).any?
        dimensions(sort_dims(dimensions_array), options)
      elsif /-$/.match?(@orig_text)
        prefixes(options)
      else
        units(options)
      end
    end

    def to_plurimath(options = {})
      guard_renderable!
      ensure_plurimath_defined!
      options = update_options(options)
      if @orig_text.match?(/-$/)
        return Plurimath::Math.parse(to_asciimath(options),
                                     :asciimath)
      end

      Plurimath::Math.parse(compact_mathml_for_plurimath(to_mathml(options)),
                            :mathml)
    end

    def dimensions_extraction
      extract_dimensions(value)
    end

    # A composed Formula contributes its already-interleaved term list (the
    # Composable default of [self] is only right for a single leaf).
    def composable_terms
      value
    end

    private

    # A composed term list must not dangle on a separator or place two
    # separators together ("W/", "W/*"); such a term list has no valid
    # rendering. The parser never builds these — only a raw extender chain
    # (#extender/#ext or an Extender operand) can — so this only ever fires on
    # compose misuse. Walks nested Formula/Fenced/Sqrt so a separator misplaced
    # inside a group is caught too, regardless of the render path taken.
    def guard_renderable!(node = value)
      if node.is_a?(Array)
        reject_misplaced_extenders!(node)
        node.each { |term| guard_renderable!(term) }
      elsif renderable_container?(node)
        guard_container!(node.value)
      end
    end

    # A group (Fenced/Sqrt) wrapping a bare separator — Fenced.new("(", ext) —
    # is as unrenderable as a dangling one; its value is never a lone Extender
    # in valid parser/compose output.
    def guard_container!(inner)
      raise Errors::MisplacedExtenderError if inner.is_a?(Extender)

      guard_renderable!(inner)
    end

    def reject_misplaced_extenders!(terms)
      return unless terms.last.is_a?(Extender) || adjacent_extenders?(terms)

      raise Errors::MisplacedExtenderError
    end

    def adjacent_extenders?(terms)
      terms.each_cons(2).any? do |left, right|
        left.is_a?(Extender) && right.is_a?(Extender)
      end
    end

    def renderable_container?(node)
      node.is_a?(Formula) || node.is_a?(Fenced) || node.is_a?(Sqrt)
    end

    def extract_dimensions(formula)
      formula.each_with_object([]) do |term, dimensions|
        case term
        when Dimension
          dimensions << term
        when Sqrt
          if term.value.is_a?(Dimension)
            sqrt_term = term.value.dup
            sqrt_term.power_numerator = Number.new("0.5")
            dimensions << sqrt_term
          elsif term.value.is_a?(Fenced)
            dimensions.concat(Array(term.value.dimensions_extraction))
          end
        when Formula
          dimensions.concat(extract_dimensions(term.value))
        when Fenced
          dimensions.concat(Array(term.dimensions_extraction))
        end
      end
    end

    def extract_units(formula)
      formula.each_with_object([]) do |term, units_arr|
        case term
        when Unit
          units_arr << term.dup
        when Formula
          units_arr.concat(extract_units(term.value.dup))
        when Sqrt
          next unless term.value.is_a?(Unit)

          units_arr << term.value
        when Fenced
          units_arr.concat(extract_units([term.value]))
        end
      end
    end

    def units(options)
      all_units = extract_units(value)
      norm_text = all_units.map(&:xml_postprocess_name).join("*")
      dims = Utility.units2dimensions(extract_units(value))
      [
        Utility.unit(all_units, self, dims, norm_text,
                     options[:name] || explicit_value&.dig(:name), options),
        Utility.prefixes(all_units, options),
        *unique_dimensions(dims, norm_text),
        Utility.quantity(norm_text,
                         options[:quantity] || explicit_value&.dig(:quantity),
                         dims),
      ].join
    end

    def unique_dimensions(dims, norm_text)
      [
        Utility.dimension(norm_text),
        Utility.dimension_components(dims),
      ].uniq
    end

    def dimensions(dims, options)
      dim_id = dims.map(&:generate_id).join
      attributes = { id: "D_#{dim_id}" }
      dims.each { |dim| attributes.merge!(dim.xml_instances_hash(options)) }
      Model::Dimension.new(
        **attributes,
        lutaml_register: Configuration.context.id,
      ).to_xml.force_encoding("UTF-8")
    end

    def sort_dims(values)
      dims_hash = Utility::DIM2D
      values.sort do |first, second|
        dims_hash.dig(first.dimension_name,
                      :order) <=> dims_hash.dig(second.dimension_name, :order)
      end
    end

    def prefixes(options)
      norm_text = @norm_text&.split("-")&.first
      prefix_object = Unit.new("", prefix: Prefix.new(norm_text))
      [
        Utility.prefixes([prefix_object], options),
        Utility.dimension(norm_text),
        Utility.quantity(norm_text,
                         options[:quantity] || explicit_value&.dig(:quantity)),
      ].join
    end

    def ensure_plurimath_defined!
      return if plurimath_available?

      require "plurimath"
    rescue LoadError
      raise Errors::PlurimathLoadError
    end

    def add_math_element(math_instance, child_hash)
      method_name = child_hash[:method_name]
      method_value = math_instance.public_send(:"#{method_name}_value") || []
      method_value += Array(child_hash[:value])
      math_instance.public_send(:"#{method_name}_value=", method_value)
      math_instance.element_order << Lutaml::Xml::Element.new("Element",
                                                              method_name.to_s)
    end

    def plurimath_available?
      Object.const_defined?(:Plurimath) &&
        Plurimath.const_defined?(:Math) &&
        Plurimath.const_defined?(:Mathml)
    end

    def process_value(math, mathml_instances)
      case mathml_instances
      when Array
        mathml_instances.each { |hash| process_value(math, hash) }
      when Hash
        add_math_element(math, mathml_instances)
      end
    end

    def update_options(options)
      # Validate render options on every path (a directly-rendered non-root
      # Formula would otherwise skip this and leak at the extender).
      Compose.validate_name!(options[:name])
      Compose.validate_multiplier!(options[:multiplier])
      return options unless root

      multiplier = options[:multiplier] || explicit_value&.dig(:multiplier)
      explicit_parenthesis = options.key?(:explicit_parenthesis) ? options[:explicit_parenthesis] : true
      options.merge(multiplier: multiplier,
                    explicit_parenthesis: explicit_parenthesis).compact
    end

    def compact_mathml_for_plurimath(mathml)
      mathml.gsub(/>\s+</, "><").strip
    end
  end
end
