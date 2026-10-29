# frozen_string_literal: true

module Unitsml
  # Storage for the power_numerator exponent shared by Unit and Dimension.
  # Values assigned through #power_numerator= are always a Unitsml::Number (or a
  # Fenced exponent for the parser's m^((1/2)) form, or nil for none) -- never a
  # bare Numeric: public Numeric inputs like Unit.new("m", 2) are coerced into a
  # Number so render/compare paths can rely on raw_value/to_latex/to_i/to_f.
  # Internal dimension-vector throwaway units may bypass this setter and keep a
  # raw Numeric in @power_numerator; those objects are never rendered.
  # Anything else (a String, a Hash, a BasicObject) raises instead of being
  # stored and crashing later at render.
  module PowerNumerator
    attr_reader :power_numerator

    def power_numerator=(power)
      @power_numerator = coerce_power_type(power)
    end

    private

    def coerce_power_type(power)
      return power if Compose.type_any?([NilClass, Number, Fenced], power)
      # Only the numeric types the parser can express (Integer, Rational, whole
      # Float) coerce; other Numerics (BigDecimal, Complex, ...) are rejected
      # rather than stringified into a non-parser exponent.
      if Compose.type_any?([Integer, Rational, Float], power)
        return Number.new(Compose.numeric_exponent_string(power))
      end

      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :unsupported_storage)
    end
  end
end
