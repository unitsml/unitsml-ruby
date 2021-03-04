require "unitsml/version"
require "unitsml/unit"

module Unitsml
  def find_unit(ascii:)
    Unitsml::Unit.find_unit(ascii: ascii)
  end
end
