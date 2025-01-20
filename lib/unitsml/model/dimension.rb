# frozen_string_literal: true

require "unitsml/model/dimension_quantities/quantity"
require "unitsml/model/dimension_quantities/length"
require "unitsml/model/dimension_quantities/mass"
require "unitsml/model/dimension_quantities/time"
require "unitsml/model/dimension_quantities/electric_current"
require "unitsml/model/dimension_quantities/thermodynamic_temperature"
require "unitsml/model/dimension_quantities/amount_of_substance"
require "unitsml/model/dimension_quantities/luminous_intensity"
require "unitsml/model/dimension_quantities/plane_angle"

module Unitsml
  module Model
    class Dimension < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :length, DimensionQuantities::Length
      attribute :mass, DimensionQuantities::Mass
      attribute :time, DimensionQuantities::Time
      attribute :electric_current, DimensionQuantities::ElectricCurrent
      attribute :thermodynamic_temperature, DimensionQuantities::ThermodynamicTemperature
      attribute :amount_of_substance, DimensionQuantities::AmountOfSubstance
      attribute :luminous_intensity, DimensionQuantities::LuminousIntensity
      attribute :plane_angle, DimensionQuantities::PlaneAngle

      xml do
        root "Dimension"
        namespace Unitsml::UNITSML_NS

        map_attribute :id, to: :id, namespace: nil, prefix: "xml"
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
