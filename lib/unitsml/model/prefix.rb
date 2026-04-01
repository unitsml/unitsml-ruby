# frozen_string_literal: true

module Unitsml
  module Model
    class Prefix < Lutaml::Model::Serializable
      attribute :name, Prefixes::Name
      attribute :id, :xml_id
      attribute :symbol, Prefixes::Symbol, collection: true
      attribute :prefix_base, :string
      attribute :prefix_power, :string

      xml do
        namespace ::Unitsml::Namespace
        element 'Prefix'

        map_attribute :prefixBase, to: :prefix_base
        map_attribute :prefixPower, to: :prefix_power
        map_attribute :id, to: :id
        map_element :PrefixName, to: :name
        map_element :PrefixSymbol, to: :symbol
      end
    end
  end
end
