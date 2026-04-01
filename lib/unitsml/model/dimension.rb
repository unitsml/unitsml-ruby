# frozen_string_literal: true

module Unitsml
  module Model
    class Dimension < Lutaml::Model::Serializable
      attribute :id, :xml_id
      attribute :length, DimensionQuantities::Length
      attribute :mass, DimensionQuantities::Mass
      attribute :time, DimensionQuantities::Time
      attribute :electric_current, DimensionQuantities::ElectricCurrent
      attribute :thermodynamic_temperature, DimensionQuantities::ThermodynamicTemperature
      attribute :amount_of_substance, DimensionQuantities::AmountOfSubstance
      attribute :luminous_intensity, DimensionQuantities::LuminousIntensity
      attribute :plane_angle, DimensionQuantities::PlaneAngle

      xml do
        namespace ::Unitsml::Namespace
        element 'Dimension'

        map_attribute :id, to: :id
        map_element :Length, to: :length
        map_element :Mass, to: :mass
        map_element :Time, to: :time
        map_element :ElectricCurrent, to: :electric_current
        map_element :ThermodynamicTemperature, to: :thermodynamic_temperature
        map_element :AmountOfSubstance, to: :amount_of_substance
        map_element :LuminousIntensity, to: :luminous_intensity
        map_element :PlaneAngle, to: :plane_angle
      end
    end
  end
end
