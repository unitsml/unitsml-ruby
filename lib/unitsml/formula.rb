# frozen_string_literal: true

require "mml"
require "htmlentities"

module Unitsml
  class Formula
    include MathmlHelper

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
      if root
        options = update_options(options)
        math = mml_v4_new(:math, display: 'block')
        math.ordered = true
        math.element_order ||= []
        value.each do |instance|
          process_value(math, instance.to_mathml(options))
        end
        generated_math = math.to_xml.gsub(%r{&amp;(.*?)(?=</)}, '&\1')

        generated_math.force_encoding("UTF-8")
      else
        value.map { |obj| obj.to_mathml(options) }
      end
    end

    def to_latex(options = {})
      value.map { |obj| obj.to_latex(update_options(options)) }.join
    end

    def to_asciimath(options = {})
      value.map { |obj| obj.to_asciimath(update_options(options)) }.join
    end

    def to_html(options = {})
      value.map { |obj| obj.to_html(update_options(options)) }.join
    end

    def to_unicode(options = {})
      value.map { |obj| obj.to_unicode(update_options(options)) }.join
    end

    def to_xml(options = {})
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
      ensure_plurimath_defined!
      options = update_options(options)
      if @orig_text.match?(/-$/)
        return Plurimath::Math.parse(to_asciimath(options),
                                     :asciimath)
      end

      Plurimath::Math.parse(compact_mathml_for_plurimath(to_mathml(options)), :mathml)
    end

    def dimensions_extraction
      extract_dimensions(value)
    end

    private

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
                     explicit_value&.dig(:name), options),
        Utility.prefixes(all_units, options),
        *unique_dimensions(dims, norm_text),
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
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
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
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
      return options unless root

      multiplier = options[:multiplier] || explicit_value&.dig(:multiplier)
      explicit_parenthesis = options.key?(:explicit_parenthesis) ? options[:explicit_parenthesis] : true
      options.merge(multiplier: multiplier,
                    explicit_parenthesis: explicit_parenthesis).compact
    end

    def compact_mathml_for_plurimath(mathml)
      mathml.gsub(/>\s+</, "><").strip
    end

    def compact_mathml_for_plurimath(mathml)
      mathml.gsub(/>\s+</, "><").strip
    end
  end
end
