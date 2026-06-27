# frozen_string_literal: true

module Unitsml
  module Model
    module DimensionQuantities
      autoload :AmountOfSubstance,
               "unitsml/model/dimension_quantities/amount_of_substance"
      autoload :ElectricCurrent,
               "unitsml/model/dimension_quantities/electric_current"
      autoload :Length, "unitsml/model/dimension_quantities/length"
      autoload :LuminousIntensity,
               "unitsml/model/dimension_quantities/luminous_intensity"
      autoload :Mass, "unitsml/model/dimension_quantities/mass"
      autoload :PlaneAngle, "unitsml/model/dimension_quantities/plane_angle"
      autoload :Quantity, "unitsml/model/dimension_quantities/quantity"
      autoload :ThermodynamicTemperature,
               "unitsml/model/dimension_quantities/thermodynamic_temperature"
      autoload :Time, "unitsml/model/dimension_quantities/time"
    end
  end
end
