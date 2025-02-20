# frozen_string_literal: true

require "unitsml/model/units/name"
require "unitsml/model/units/symbol"
require "unitsml/model/units/system"
require "unitsml/model/units/root_units"

module Unitsml
  module Model
    class Unit < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :name, Units::Name
      attribute :dimension_url, :string
      attribute :symbol, Units::Symbol, collection: true
      attribute :system, Units::System, collection: true
      attribute :root_units, Units::RootUnits

      xml do
        root "Unit"
        namespace Unitsml::UNITSML_NS

        map_attribute :dimensionURL, to: :dimension_url
        map_attribute :id, to: :id, namespace: nil, prefix: "xml"
        map_element :UnitSystem, to: :system
        map_element :UnitName, to: :name
        map_element :UnitSymbol, to: :symbol
        map_element :RootUnits, to: :root_units
      end
    end
  end
end
