# frozen_string_literal: true

module Unitsml
  module Model
    class Quantity < Lutaml::Model::Serializable
      attribute :id, :xml_id
      attribute :name, Quantities::Name, collection: true
      attribute :quantity_type, :string, default: -> { 'base' }
      attribute :dimension_url, :string

      xml do
        namespace ::Unitsml::Namespace
        element 'Quantity'

        map_attribute :id, to: :id
        map_attribute :quantityType, to: :quantity_type, render_default: true
        map_attribute :dimensionURL, to: :dimension_url
        map_element :QuantityName, to: :name
      end
    end
  end
end
