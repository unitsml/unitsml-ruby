# frozen_string_literal: true

require "mml"
require "htmlentities"

module Unitsml
  class Formula
    include MathmlHelper
    include Composable

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

      Plurimath::Math.parse(compact_mathml_for_plurimath(to_mathml(options)),
                            :mathml)
    end

    def dimensions_extraction
      extract_dimensions(value)
    end

    class << self
      # Assemble a root Formula from a left-hand term list and a right-hand
      # operand. `/` inverts every unit/dimension term on the right. Terms are
      # deep-copied so operands are never mutated.
      def build_product(lhs_terms, rhs, operator)
        lhs = lhs_terms.map { |term| dup_term(term) }
        rhs_terms = terms_of(rhs).map { |term| dup_term(term) }
        invert_terms(rhs_terms) if operator == "/"
        terms = lhs + [Extender.new("*")] + rhs_terms
        guard_terms!(terms)
        text = synthesize_text(terms)
        new(terms, root: true, orig_text: text, norm_text: text)
      end

      # Build a root Formula from an ordered list of unit/dimension objects,
      # interleaving multiplication. Used by the keyword compose builder.
      def from_terms(objects, quantity: nil, name: nil, multiplier: nil)
        raise ArgumentError, "compose requires at least one unit" if objects.empty?

        terms = interleave(objects.map { |object| dup_term(object) })
        guard_terms!(terms)
        text = synthesize_text(terms)
        new(terms, explicit_value: build_extras(quantity, name, multiplier),
                   root: true, orig_text: text, norm_text: text)
      end

      private

      def interleave(objects)
        objects.each_with_index.flat_map do |object, index|
          index.zero? ? [object] : [Extender.new("*"), object]
        end
      end

      def build_extras(quantity, name, multiplier)
        extras = { quantity: quantity, name: name,
                   multiplier: multiplier }.compact
        extras.empty? ? nil : extras
      end

      def terms_of(rhs)
        case rhs
        when Formula then rhs.value
        when Unit, Dimension then [rhs]
        else raise ArgumentError, "cannot compose with #{rhs.inspect}"
        end
      end

      # Deep-copy a term so composing never mutates an operand. Nested Formula,
      # Fenced and Sqrt structures are copied recursively (a parsed operand can
      # carry them), and unit/dimension powers are coerced + duplicated.
      def dup_term(term)
        case term
        when Unit then dup_leaf(term, dup_prefix: true)
        when Dimension then dup_leaf(term)
        when Formula then dup_formula(term)
        when Fenced then Fenced.new(term.open_paren, dup_term(term.value),
                                    term.close_paren)
        when Sqrt then Sqrt.new(dup_term(term.value))
        else term.dup
        end
      end

      def dup_leaf(term, dup_prefix: false)
        copy = term.dup
        power = Number.coerce(copy.power_numerator)
        copy.power_numerator = power.is_a?(Number) ? power.dup : power
        copy.prefix = copy.prefix.dup if dup_prefix && copy.prefix
        copy
      end

      def dup_formula(formula)
        copy = formula.dup
        copy.value = formula.value.map { |term| dup_term(term) }
        copy
      end

      # Invert every unit/dimension term (division). The right-hand term list is
      # already exponent-resolved - the parser bakes division into the powers and
      # leaves "/" extenders decorative - so each leaf is negated and extenders
      # are ignored; Fenced/Sqrt/nested Formula structures recurse.
      def invert_terms(terms)
        terms.each do |term|
          case term
          when Unit then invert_unit(term)
          when Dimension then invert_dimension(term)
          when Fenced, Sqrt then invert_terms([term.value])
          when Formula then invert_terms(term.value)
          end
        end
      end

      # A resolved exponent of +1 renders as no exponent (canonical plain unit),
      # so dividing by an inverse term matches the parsed equivalent.
      def invert_unit(unit)
        unit.inverse_power_numerator
        unit.power_numerator = nil if unit.power_numerator&.raw_value == "1"
      end

      def invert_dimension(dimension)
        raw = dimension.power_numerator&.raw_value
        negated = raw ? negate(raw) : "-1"
        dimension.power_numerator = negated == "1" ? nil : Number.new(negated)
      end

      def negate(raw)
        raw.start_with?("-") ? raw.delete_prefix("-") : "-#{raw}"
      end

      def guard_terms!(terms)
        raise Errors::MixedTermsError if terms.any?(Unit) &&
          terms.any?(Dimension)
      end

      def synthesize_text(terms)
        terms.map { |term| term_text(term) }.join
      end

      def term_text(term)
        case term
        when Unit then term.xml_postprocess_name
        when Dimension then dimension_text(term)
        when Extender then term.symbol
        when Fenced
          "#{term.open_paren}#{term_text(term.value)}#{term.close_paren}"
        when Sqrt then "sqrt(#{term_text(term.value)})"
        when Formula then synthesize_text(term.value)
        else ""
        end
      end

      def dimension_text(dimension)
        exponent = dimension.power_numerator&.raw_value
        suffix = exponent && exponent != "1" ? "^#{exponent}" : ""
        "#{dimension.dimension_name}#{suffix}"
      end
    end

    private

    def composable_terms
      value
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
