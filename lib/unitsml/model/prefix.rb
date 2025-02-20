# frozen_string_literal: true

require "unitsml/model/prefixes/name"
require "unitsml/model/prefixes/symbol"


module Unitsml
  module Model
    class Prefix < Lutaml::Model::Serializable
      attribute :name, Prefixes::Name
      attribute :id, :string
      attribute :symbol, Prefixes::Symbol, collection: true
      attribute :prefix_base, :string
      attribute :prefix_power, :string

      xml do
        root "Prefix"
        namespace Unitsml::UNITSML_NS

        map_attribute :prefixBase, to: :prefix_base
        map_attribute :prefixPower, to: :prefix_power
        map_attribute :id, to: :id, namespace: nil, prefix: "xml"
        map_element :PrefixName, to: :name
        map_element :PrefixSymbol, to: :symbol
      end
    end
  end
end
