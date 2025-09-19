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
      @dim_instance ||= Unitsdb.dimensions.find_parsables_by_id(dimension_name)
    end

    def dim_symbols
      dim_instance.send(dim_instance.processed_keys.last).symbols.first
    end

    def to_mathml(options)
      # MathML key's value in unitsdb/dimensions.yaml
      # file includes mi tags only.
      value = ::Mml::Mi.from_xml(dim_symbols.mathml)
      method_name = if power_numerator
                      value = msup_tag(value, options)
                      :msup
                    else
                      :mi
                    end
      { method_name: method_name, value: value }
    end

    def to_latex(options)
      power_numerator_generic_code(:latex, options)
    end

    def to_asciimath(options)
      power_numerator_generic_code(:ascii, options)
    end

    def to_unicode(options)
      power_numerator_generic_code(:unicode, options)
    end

    def to_html(options)
      value = dim_symbols.html
      value = "#{value}#{html_numerator_conversion(options)}" if power_numerator
      value
    end

    def generate_id
      "#{dimension_name.split('_').last}#{power_numerator&.raw_value}"
    end

    def to_xml(_)
      attributes = {
        symbol: dim_instance.processed_symbol,
        power_numerator: power_numerator&.raw_value || 1,
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

    def html_numerator_conversion(options)
      "<sup>#{power_numerator.to_html(options)}</sup>"
    end

    def power_numerator_generic_code(method_name, options)
      value = dim_symbols.public_send(method_name)
      return value unless power_numerator

      method_name = :asciimath if method_name == :ascii
      "#{value}^#{power_numerator&.public_send(:"to_#{method_name}", options)}"
    end

    def element_name
      dim_instance.processed_keys.first
    end

    def msup_tag(value, options)
      mathml = power_numerator.to_mathml(options)
      msup = ::Mml::Msup.new(
        mrow_value: [::Mml::Mrow.new(mi_value: [value])],
      )
      [mathml].flatten.each do |record|
        record_values = msup.public_send("#{record[:method_name]}_value") || []
        record_values += [record[:value]]
        msup.public_send("#{record[:method_name]}_value=", record_values)
      end
      msup
    end
  end
end
