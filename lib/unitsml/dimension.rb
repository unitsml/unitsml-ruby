# frozen_string_literal: true

module Unitsml
  class Dimension
    attr_accessor :dimension_name, :power_numerator

    def initialize(dimension_name, power_numerator = nil)
      @dimension_name = dimension_name
      @power_numerator = power_numerator
    end

    def ==(object)
      self.class == object.class &&
        dimension_name == object&.dimension_name &&
        power_numerator == object&.power_numerator
    end

    def dim_instance
      @dim ||= Unitsdb.dimensions.find_parsables_by_id(dimension_name)
    end

    def dim_symbols
      dim_instance.send(@dim.processed_keys.last).symbols.first
    end

    def to_mathml(_)
      # MathML key's value in unitsdb/dimensions.yaml file includes mi tags only.
      value = ::Mml::Mi.from_xml(dim_symbols.mathml)
      method_name = power_numerator ? :msup : :mi
      if power_numerator
        value = ::Mml::Msup.new(
          mrow_value: [
            ::Mml::Mrow.new(mi_value: [value]),
            ::Mml::Mrow.new(
              mn_value: [::Mml::Mn.new(value: power_numerator)],
            ),
          ]
        )
      end
      { method_name: method_name, value: value }
    end

    def to_latex(_)
      power_numerator_generic_code(:latex)
    end

    def to_asciimath(_)
      power_numerator_generic_code(:ascii)
    end

    def to_unicode(_)
      power_numerator_generic_code(:unicode)
    end

    def to_html(_)
      value = dim_symbols.html
      value = "#{value}<sup>#{power_numerator}</sup>" if power_numerator
      value
    end

    def generate_id
      "#{dimension_name.split('_').last}#{power_numerator}"
    end

    def to_xml(_)
      attributes = {
        symbol: dim_instance.processed_symbol,
        power_numerator: power_numerator || 1,
      }
      Model::DimensionQuantities.const_get(modelize(element_name)).new(attributes)
    end

    def xml_instances_hash(options)
      { element_name => to_xml(options) }
    end

    def modelize(value)
      value&.split("_")&.map(&:capitalize)&.join
    end

    private

    def power_numerator_generic_code(method_name)
      value = dim_symbols.public_send(method_name)
      return value unless power_numerator

      "#{value}^#{power_numerator}"
    end

    def element_name
      dim_instance.processed_keys.first
    end
  end
end
