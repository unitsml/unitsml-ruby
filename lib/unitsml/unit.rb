# frozen_string_literal: true

module Unitsml
  class Unit
    attr_accessor :unit_name, :power_numerator, :prefix

    SI_UNIT_SYSTEM = %w[si_base si_derived_special si_derived_non_special].freeze

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

    def unknown_name?
      unit_name == Utility::UNKNOWN
    end

    def unit_symbols
      unit_instance.symbols.find { |symbol| symbol.id == unit_name }
    end

    def to_mathml(options)
      value = unit_symbols&.mathml
      tag_name = value.match(/^<(?<tag>\w+)/)[:tag]
      value = ::Mml.const_get(tag_name.capitalize).from_xml(value)
      value.value = "#{prefix.to_mathml(options)}#{value.value}" if prefix
      if power_numerator
        value = msup_tag(
          { method_name: tag_name, value: value },
          options,
        )
        tag_name = :msup
      end
      { method_name: tag_name.to_sym, value: value }
    end

    def to_latex(options)
      value = unit_symbols&.latex
      value = "#{value}^#{power_numerator.to_latex(options)}" if power_numerator
      value = "#{prefix.to_latex(options)}#{value}" if prefix
      value
    end

    def to_asciimath(options)
      value = unit_symbols&.ascii
      value = "#{value}^#{power_numerator.to_asciimath(options)}" if power_numerator
      value = "#{prefix.to_asciimath(options)}#{value}" if prefix
      value
    end

    def to_html(options)
      value = unit_symbols&.html
      if power_numerator
        value = "#{value}<sup>#{power_numerator.to_html(options)}</sup>"
      end
      value = "#{prefix.to_html(options)}#{value}" if prefix
      value
    end

    def to_unicode(options)
      value = unit_symbols&.unicode
      value = "#{value}^#{power_numerator.to_unicode(options)}" if power_numerator
      value = "#{prefix.to_unicode(options)}#{value}" if prefix
      value
    end

    def enumerated_name
      unit_instance.names.find { |name| name.lang == "en" }&.value
    end

    def prefix_name
      prefix&.prefix_name
    end

    def system_type
      system_reference&.first&.id
    end

    def si_derived_bases
      unit_instance.si_derived_bases
    end

    def xml_postprocess_name
      "#{prefix_name}#{unit_name}#{display_exp}"
    end

    def si_system_type?
      SI_UNIT_SYSTEM.include?(downcase_system_type)
    end

    def downcase_system_type
      Lutaml::Model::Utils.snake_case(system_type)
    end

    def inverse_power_numerator
      if power_numerator
        power_numerator.update_negative_sign
      else
        @power_numerator = Number.new("-1")
      end
    end

    private

    def display_exp
      return unless power_numerator

      exp = power_numerator.raw_value
      "^#{exp}" if exp != "1"
    end

    def system_reference
      unit_instance.unit_system_reference
    end

    def msup_tag(value, options)
      msup = ::Mml::Msup.new
      msup.ordered = true
      msup.element_order = []
      [value, power_numerator.to_mathml(options)].flatten.each do |record|
        values = msup.public_send("#{record[:method_name]}_value") || []
        values += [record[:value]]
        msup.element_order << Lutaml::Model::Xml::Element.new("Element", record[:method_name].to_s)
        msup.public_send("#{record[:method_name]}_value=", values)
      end
      msup
    end
  end
end
