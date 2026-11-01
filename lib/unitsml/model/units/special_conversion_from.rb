# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      # A conversion more complex than the linear equation
      # (SpecialConversionFrom). Never approximated by a linear factor;
      # the conversion engine refuses it with a typed error.
      class SpecialConversionFrom < Lutaml::Model::Serializable
        attribute :id, :xml_id
        attribute :initial_unit, :string
        attribute :conversion_url, :string
        attribute :conversion_description, :string, collection: true

        xml do
          element "SpecialConversionFrom"
          namespace ::Unitsml::Namespace

          map_attribute :id, to: :id
          map_attribute :initialUnit, to: :initial_unit
          map_attribute :conversionURL, to: :conversion_url
          map_element :ConversionDescription, to: :conversion_description
        end
      end
    end
  end
end
