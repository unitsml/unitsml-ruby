# frozen_string_literal: true

module Unitsml
  class Unit
    attr_accessor :unit_name, :power_numerator, :prefix

    def initialize(unit_name,
                   power_numerator = nil,
                   prefix: nil)
      @prefix = prefix
      @unit_name = unit_name
      @power_numerator = power_numerator
    end

    def ==(object)
      self.class == object.class &&
        prefix == object&.prefix &&
        unit_name == object&.unit_name &&
        power_numerator == object&.power_numerator
    end

    def fields_hash
      Unitsdb.units.dig(unit_name, :fields)
    end

    def unit_symbols
      symbols = fields_hash.dig("unit_symbols")
      symbols.find{|symbol| symbol["id"] == unit_name }
    end

    def numerator_value(mathml = true)
      integer = power_numerator.to_s
      if integer.match?(/-/)
        replacer = mathml ? '<mo>&#x2212;</mo><mn>\2</mn>' : '&#x2212;\2'
        integer.sub(/(-)(.+)/, replacer)
      else
        mathml ? "<mn>#{integer}</mn>" : integer
      end
    end

    def to_mathml
      value = unit_symbols&.dig("mathml")
      if power_numerator
        value = "<msup><mrow>#{value}</mrow><mrow>#{numerator_value}</mrow></msup>"
      end
      value = insert_prefix(value) if prefix
      value
    end

    def insert_prefix(value)
      value.sub(/<mi mathvariant='normal'>/,"<mi mathvariant='normal'>#{prefix.to_mathml}")
    end

    def to_latex
      value = unit_symbols&.dig("latex")
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_latex}#{value}" if prefix
      value
    end

    def to_asciimath
      value = unit_symbols&.dig("ascii")
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_asciimath}#{value}" if prefix
      value
    end

    def to_html
      value = unit_symbols&.dig("html")
      if power_numerator
        value = "#{value}<sup>#{numerator_value(false)}</sup>"
      end
      value = "#{prefix.to_html}#{value}" if prefix
      value
    end

    def to_unicode
      value = unit_symbols&.dig("unicode")
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_unicode}#{value}" if prefix
      value
    end

    def enumerated_name
      fields_hash.dig("unit_name")&.first
    end

    def prefix_name
      prefix&.prefix_name
    end

    def system_type
      fields_hash.dig("unit_system", "type")
    end

    def system_name
      fields_hash.dig("unit_system", "name")
    end

    def si_derived_bases
      fields_hash.dig("si_derived_bases")
    end
  end
end
