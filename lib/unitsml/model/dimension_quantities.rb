# frozen_string_literal: true

module Unitsml
  module Model
    module DimensionQuantities
      autoload :AmountOfSubstance,
               "#{__dir__}/dimension_quantities/amount_of_substance"
      autoload :ElectricCurrent,
               "#{__dir__}/dimension_quantities/electric_current"
      autoload :Length, "#{__dir__}/dimension_quantities/length"
      autoload :LuminousIntensity,
               "#{__dir__}/dimension_quantities/luminous_intensity"
      autoload :Mass, "#{__dir__}/dimension_quantities/mass"
      autoload :PlaneAngle, "#{__dir__}/dimension_quantities/plane_angle"
      autoload :Quantity, "#{__dir__}/dimension_quantities/quantity"
      autoload :ThermodynamicTemperature,
               "#{__dir__}/dimension_quantities/thermodynamic_temperature"
      autoload :Time, "#{__dir__}/dimension_quantities/time"
    end
  end
end
