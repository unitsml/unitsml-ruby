# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      # The Conversions container of a unit: linear definitions
      # (Float64ConversionFrom) and the non-linear / remote stand-ins
      # (SpecialConversionFrom, WSDLConversionFrom).
      class Conversions < Lutaml::Model::Serializable
        attribute :float64_conversion_from, Float64ConversionFrom
        attribute :special_conversion_from, SpecialConversionFrom
        attribute :wsdl_conversion_from, WsdlConversionFrom

        xml do
          element "Conversions"
          namespace ::Unitsml::Namespace

          map_element :Float64ConversionFrom, to: :float64_conversion_from
          map_element :SpecialConversionFrom, to: :special_conversion_from
          map_element :WSDLConversionFrom, to: :wsdl_conversion_from
        end
      end
    end
  end
end
