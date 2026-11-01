# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      # The linear conversion definition of UnitsML 1.0 (Float64ConversionFrom):
      # y = d + ((b / c) (x + a)) from the initial unit x to this unit y.
      #
      # Decimal attributes are lexical strings, preserved verbatim per the
      # numeric contract (CalConnect 36813): "273.15" never becomes 273.15.
      # The XSD defaults (a=0, b=1, c=1, d=0) apply where an attribute is
      # absent; the conversion engine resolves them at application time.
      class Float64ConversionFrom < Lutaml::Model::Serializable
        XSD_DEFAULTS = {
          initial_addend: "0",
          multiplicand: "1",
          divisor: "1",
          final_addend: "0",
        }.freeze

        attribute :id, :xml_id
        attribute :initial_unit, :string
        attribute :initial_addend, :string
        attribute :initial_addend_decimal_place, :integer
        attribute :multiplicand, :string
        attribute :multiplicand_digits, :integer
        attribute :divisor, :string
        attribute :divisor_digits, :integer
        attribute :final_addend, :string
        attribute :final_addend_decimal_place, :integer
        attribute :exact, :boolean
        attribute :conversion_note, ConversionNote, collection: true

        xml do
          element "Float64ConversionFrom"
          namespace ::Unitsml::Namespace

          map_attribute :id, to: :id
          map_attribute :initialUnit, to: :initial_unit
          map_attribute :initialAddend, to: :initial_addend
          map_attribute :initialAddendDecimalPlace,
                        to: :initial_addend_decimal_place
          map_attribute :multiplicand, to: :multiplicand
          map_attribute :multiplicandDigits, to: :multiplicand_digits
          map_attribute :divisor, to: :divisor
          map_attribute :divisorDigits, to: :divisor_digits
          map_attribute :finalAddend, to: :final_addend
          map_attribute :finalAddendDecimalPlace,
                        to: :final_addend_decimal_place
          map_attribute :exact, to: :exact
          map_element :ConversionNote, to: :conversion_note
        end

        # Lexical attribute with the XSD default applied.
        def lexical_decimal(name)
          value = public_send(name)
          value.nil? ? XSD_DEFAULTS.fetch(name) : value
        end
      end
    end
  end
end
