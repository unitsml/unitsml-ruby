# frozen_string_literal: true

module Unitsml
  class Parser
    attr_accessor :text

    def initialize(text)
      @regexp = %r{(quantity|name|symbol|multiplier):\s*}
      @text = extract_equation(text)
      @orig_text = @text
      @text = @text.gsub("−", "-")
      post_extras
    end

    def parse
      nodes = Parse.new.parse(text)
      transformed = Transform.new.apply(nodes)
      formula_value = transformed.is_a?(Formula) ? transformed.value : [transformed].flatten
      formula = Formula.new(
        formula_value,
        explicit_value: @extras_hash,
        root: true,
        orig_text: @orig_text,
        norm_text: text,
      )
      update_units_exponents(formula.value, false)
      formula.value.first.only_instance = true if text.end_with?("-")
      formula
    end

    def update_units_exponents(array, inverse, sqrt = false)
      array.each do |object|
        if object.is_a?(Sqrt)
          object = object.value
          if object.respond_to?(:power_numerator)
            object.power_numerator = "0.5"
          else
            update_units_exponents([object], inverse, true)
          end
        end

        case object
        when Unit
          next object.power_numerator = "0.5" if sqrt
          next unless inverse

          exponent = inverse ? "-#{object&.power_numerator || '1'}" : object.power_numerator
          object.power_numerator = exponent&.sub(/^--+/, "")
        when Dimension then object.power_numerator = "0.5" if sqrt
        when Extender then inverse = !inverse if ["/", "//"].any?(object.symbol)
        when Formula then update_units_exponents(object.value, inverse)
        when Fenced then update_units_exponents([object.value], inverse, sqrt)
        end
      end
    end

    def post_extras
      return nil unless @regexp.match?(text)

      @extras_hash = {}
      texts_array = text&.split(",")&.map(&:strip)
      @text = texts_array&.shift
      texts_array&.map { |text| parse_extras(text) }
    end

    def parse_extras(text)
      return nil unless @regexp.match?(text)

      key, _, value = text&.partition(":")
      @extras_hash[key&.to_sym] ||= value&.strip
    end

    private

    def extract_equation(text)
      return text unless text&.start_with?("unitsml(")

      text.delete_prefix("unitsml(").delete_suffix(")")
    end
  end
end
