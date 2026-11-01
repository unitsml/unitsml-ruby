# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      autoload :ConversionNote, "unitsml/model/units/conversion_note"
      autoload :Conversions, "unitsml/model/units/conversions"
      autoload :EnumeratedRootUnit, "unitsml/model/units/enumerated_root_unit"
      autoload :Float64ConversionFrom, "unitsml/model/units/float64_conversion_from"
      autoload :Name, "unitsml/model/units/name"
      autoload :RootUnits, "unitsml/model/units/root_units"
      autoload :Symbol, "unitsml/model/units/symbol"
      autoload :SpecialConversionFrom, "unitsml/model/units/special_conversion_from"
      autoload :System, "unitsml/model/units/system"
      autoload :WsdlConversionFrom, "unitsml/model/units/wsdl_conversion_from"
    end
  end
end
