# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class EnumeratedRootUnit < Lutaml::Model::Serializable
        attribute :unit, :string
        attribute :prefix, :string
        attribute :power_numerator, :string
        attribute :power_denominator, :string

        xml do
          namespace ::Unitsml::Namespace
          map_attribute :unit, to: :unit
          map_attribute :prefix, to: :prefix
          map_attribute :powerNumerator, to: :power_numerator
          map_attribute :powerDenominator, to: :power_denominator
        end
      end
    end
  end
end
