# frozen_string_literal: true

require "unitsml/model/quantities/name"

module Unitsml
  module Model
    class Quantity < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :name, Quantities::Name, collection: true
      attribute :quantity_type, :string, default: -> { "base" }
      attribute :dimension_url, :string

      xml do
        root "Quantity"
        namespace Unitsml::UNITSML_NS

        map_attribute :id, to: :id, namespace: nil, prefix: "xml"
        map_attribute :quantityType, to: :quantity_type, render_default: true
        map_attribute :dimensionURL, to: :dimension_url
        map_element :QuantityName, to: :name
      end
    end
  end
end
