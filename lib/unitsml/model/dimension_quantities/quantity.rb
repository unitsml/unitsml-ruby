# frozen_string_literal: true

module Unitsml
  module Model
    module DimensionQuantities
      class Quantity < Lutaml::Model::Serializable
        attribute :symbol, :string
        attribute :power_numerator, :string

        xml do
          map_attribute :symbol, to: :symbol
          map_attribute :powerNumerator, to: :power_numerator
        end
      end
    end
  end
end
