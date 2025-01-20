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

    def unit_instance
      Unitsdb.units.find_by_name(unit_name)
    end

    def unit_symbols
      unit_instance.unit_symbols.find { |symbol| symbol.id == unit_name }
    end

    def numerator_value(mathml = true)
      integer = power_numerator.to_s
      unless integer.match?(/-/)
        return mathml ? { mn_value: [::Mml::Mn.from_xml("<mn>#{integer}</mn>")] } : integer
      end

      return integer.sub(/(-)(.+)/, '&#x2212;\2') unless mathml

      integer = integer.sub(/(-)(.+)/, '<mn>\2</mn>')
      integer = ::Mml::Mn.from_xml(integer)
      mo_tag = ::Mml::Mo.new(value: "&#x2212;")
      { mo_value: [mo_tag], mn_value: [integer] }
    end

    def to_mathml
      value = unit_symbols&.mathml
      tag_name = value.match(/^<(?<tag>\w+)/)[:tag]
      value = ::Mml.const_get(tag_name.capitalize).from_xml(value)
      value.value = "#{prefix.to_mathml}#{value.value}" if prefix
      if power_numerator
        value = ::Mml::Msup.new(
          mrow_value: [
            ::Mml::Mrow.new("#{tag_name}_value": Array(value)),
            ::Mml::Mrow.new(numerator_value),
          ]
        )
        tag_name = :msup
      end
      { method_name: tag_name.to_sym, value: value }
    end

    def to_latex
      value = unit_symbols&.latex
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_latex}#{value}" if prefix
      value
    end

    def to_asciimath
      value = unit_symbols&.ascii
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_asciimath}#{value}" if prefix
      value
    end

    def to_html
      value = unit_symbols&.html
      if power_numerator
        value = "#{value}<sup>#{numerator_value(false)}</sup>"
      end
      value = "#{prefix.to_html}#{value}" if prefix
      value
    end

    def to_unicode
      value = unit_symbols&.unicode
      value = "#{value}^#{power_numerator}" if power_numerator
      value = "#{prefix.to_unicode}#{value}" if prefix
      value
    end

    def enumerated_name
      unit_instance&.unit_name&.first
    end

    def prefix_name
      prefix&.prefix_name
    end

    def system_type
      unit_instance.unit_system.type
    end

    def system_name
      unit_instance.unit_system.name
    end

    def si_derived_bases
      unit_instance.si_derived_bases
    end
  end
end
