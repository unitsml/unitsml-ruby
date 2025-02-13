# frozen_string_literal: true

require "mml"
require "htmlentities"
require "unitsml/utility"
module Unitsml
  class Formula
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

    def ==(object)
      self.class == object.class &&
        value == object&.value &&
        explicit_value == object&.explicit_value &&
        root == object.root
    end

    def to_mathml
      if root
        nullify_mml_models if plurimath_available?
        math = ::Mml::MathWithNamespace.new(display: "block")
        math.ordered = true
        math.element_order ||= []
        value.each do |instance|
          processed_instance = instance.to_mathml
          case processed_instance
          when Array
            processed_instance.each { |hash| add_math_element(math, hash) }
          when Hash
            add_math_element(math, processed_instance)
          end
        end
        reset_mml_models if plurimath_available?
        math.to_xml.gsub(/&amp;(.*?)(?=<\/)/, '&\1')
      else
        value.map(&:to_mathml)
      end
    end

    def to_latex
      value.map(&:to_latex).join
    end

    def to_asciimath
      value.map(&:to_asciimath).join
    end

    def to_html
      value.map(&:to_html).join
    end

    def to_unicode
      value.map(&:to_unicode).join
    end

    def to_xml
      if (dimensions_array = extract_dimensions(value)).any?
        dimensions(sort_dims(dimensions_array))
      elsif @orig_text.match(/-$/)
        prefixes
      else
        units
      end
    end

    def to_plurimath
      ensure_plurimath_defined!
      return Plurimath::Math.parse(to_asciimath, :asciimath) if @orig_text.match?(/-$/)

      Plurimath::Math.parse(to_mathml, :mathml)
    end

    private

    def extract_dimensions(formula)
      formula.each_with_object([]) do |term, dimensions|
        if term.is_a?(Dimension)
          dimensions << term
        elsif term.is_a?(Sqrt) && term.value.is_a?(Dimension)
          sqrt_term = term.value.dup
          sqrt_term.power_numerator = "0.5"
          dimensions << sqrt_term
        elsif term.is_a?(Formula)
          dimensions.concat(extract_dimensions(term.value))
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
        end
      end
    end

    def units
      all_units = extract_units(value)
      norm_text = Utility.postprocess_normtext(all_units)
      dims = Utility.units2dimensions(extract_units(value))
      dimension, dimension_component = unique_dimensions(dims, norm_text)
      [
        Utility.unit(all_units, self, dims, norm_text, explicit_value&.dig(:name)),
        Utility.prefixes(all_units),
        dimension,
        dimension_component,
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
      ].join
    end

    def unique_dimensions(dims, norm_text)
      [
        Utility.dimension(norm_text),
        Utility.dimension_components(dims),
      ].uniq
    end

    def dimensions(dims)
      dim_id = dims.map(&:generate_id).join
      attributes = { id: "D_#{dim_id}" }
      dims.each { |dim| attributes.merge!(dim.xml_instances_hash) }
      Model::Dimension.new(attributes).to_xml
    end

    def sort_dims(values)
      dims_hash = Utility::Dim2D
      values.sort do |first, second|
        dims_hash.dig(first.dimension_name, :order) <=> dims_hash.dig(second.dimension_name, :order)
      end
    end

    def prefixes
      norm_text = @norm_text&.split("-")&.first
      prefix_object = Unit.new("", prefix: Prefix.new(norm_text))
      [
        Utility.prefixes([prefix_object]),
        Utility.dimension(norm_text),
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
      ].join
    end

    def ensure_plurimath_defined!
      return if plurimath_available?

      require "plurimath"
    rescue LoadError => e
      raise Errors::PlurimathLoadError
    end

    def add_math_element(math_instance, child_hash)
      method_name = child_hash[:method_name]
      method_value = math_instance.public_send(:"#{method_name}_value")
      method_value += Array(child_hash[:value])
      math_instance.public_send(:"#{method_name}_value=", method_value)
      math_instance.element_order << Lutaml::Model::XmlAdapter::Element.new("Element", method_name.to_s)
    end

    def plurimath_available?
      Object.const_defined?(:Plurimath)
    end

    def nullify_mml_models
      Plurimath::Mathml::Parser::CONFIGURATION.each_key { |klass| klass.model(klass) }
    end

    def reset_mml_models
      ::Mml::Configuration.custom_models = Plurimath::Mathml::Parser::CONFIGURATION
    end
  end
end
