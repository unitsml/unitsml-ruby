# frozen_string_literal: true

require "plurimath"
require_relative "utility"
module Unitsml
  class Formula
    attr_accessor :value, :explicit_value, :root

    def initialize(value = [],
                   explicit_value: nil,
                   root: false,
                   orig_text: nil,
                   norm_text: nil)
      @value = value
      @explicit_value = explicit_value || {}
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

    def to_mathml(options = {})
      options = update_options(options)
      if root
        attributes = { xmlns: "http://www.w3.org/1998/Math/MathML", display: "block" }
        math = Utility.ox_element("math", attributes: attributes)
        Ox.dump(
          Utility.update_nodes(
            math,
            value.map { |obj| obj.to_mathml(options) }.flatten,
          ),
        ).gsub(/&amp;(.*?)(?=<\/)/, '&\1')
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
      dimensions_array = extract_dimensions(value)
      if (dimensions_array).any?
        dimensions(sort_dims(dimensions_array), options)
      elsif @orig_text.match(/-$/)
        prefixes(options)
      else
        units(options)
      end
    end

    def to_plurimath(options = {})
      options = update_options(options)
      return Plurimath::Math.parse(to_asciimath(options), :asciimath) if @orig_text.match?(/-$/)

      Plurimath::Math.parse(to_mathml(options), :mathml)
    end

    private

    def extract_dimensions(formula)
      dimensions = []

      formula.each do |term|
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

      dimensions
    end

    def extract_units(formula)
      units_arr = []

      formula.each do |term|
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

      units_arr
    end

    def units(options)
      all_units = extract_units(value)
      norm_text = Utility.postprocess_normtext(all_units)
      dims = Utility.units2dimensions(extract_units(value))
      [
        Utility.unit(all_units, self, dims, norm_text, explicit_value&.dig(:name)),
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
      attributes = { xmlns: Utility::UNITSML_NS, "xml:id": "D_#{dim_id}" }
      Ox.dump(
        Utility.update_nodes(
          Utility.ox_element("Dimension", attributes: attributes),
          dims.map { |dim| dim.to_xml(options) },
        ),
      )
    end

    def sort_dims(values)
      dims_hash = Utility::Dim2D
      values.sort do |first, second|
        dims_hash.dig(first.dimension_name, :order) <=> dims_hash.dig(second.dimension_name, :order)
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

    def update_options(options)
      return options unless root

      multiplier = options[:multiplier] || explicit_value[:multiplier]
      options.merge(multiplier: multiplier).compact
    end
  end
end
