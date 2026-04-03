# frozen_string_literal: true

module Unitsml
  module Model
    class Unit < Lutaml::Model::Serializable
      attribute :id, :xml_id
      attribute :name, Units::Name
      attribute :dimension_url, :string
      attribute :symbol, Units::Symbol, collection: true
      attribute :system, Units::System, collection: true
      attribute :root_units, Units::RootUnits

      xml do
        namespace ::Unitsml::Namespace
        element "Unit"

        map_attribute :dimensionURL, to: :dimension_url
        map_attribute :id, to: :id
        map_element :UnitSystem, to: :system
        map_element :UnitName, to: :name
        map_element :UnitSymbol, to: :symbol
        map_element :RootUnits, to: :root_units
      end
    end
  end
end
