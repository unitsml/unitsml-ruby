require "unitsml/version"
require "unitsml/dimension"
require "unitsml/quantity"
require "unitsml/unit"
require "unitsml/unit_system"

module Unitsml
  def find_unit(ascii:)
    Unitsml::Unit.find_unit(ascii: ascii)
  end

  def find_dimension(ascii:)
    Unitsml::Dimension.find_unit(ascii: ascii)
  end

  def find_unit_system(ascii:)
    Unitsml::UnitSystem.find_unit_system(ascii: ascii)
  end
end
