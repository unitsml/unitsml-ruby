# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      # A SOAP/WSDL-based conversion (WSDLConversionFrom). Remote by
      # definition; the conversion engine refuses it with a typed error.
      class WsdlConversionFrom < Lutaml::Model::Serializable
        attribute :id, :xml_id
        attribute :initial_unit, :string
        attribute :wsdl_url, :string
        attribute :wsdl_description, :string, collection: true

        xml do
          element "WSDLConversionFrom"
          namespace ::Unitsml::Namespace

          map_attribute :id, to: :id
          map_attribute :initialUnit, to: :initial_unit
          map_attribute :wsdlURL, to: :wsdl_url
          map_element :WSDLDescription, to: :wsdl_description
        end
      end
    end
  end
end
