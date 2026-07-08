# frozen_string_literal: true

module Unitsml
  # Storage for the power_numerator exponent shared by Unit and Dimension. The
  # stored value is always a Unitsml::Number (or a Fenced exponent for the
  # parser's m^((1/2)) form, or nil for none) — never a bare Numeric: a Numeric
  # (e.g. a Float from unit decomposition, or Unit.new("m", 2) from the public
  # API) is coerced into a Number so every render/compare/decomposition path can
  # rely on the Number interface (raw_value/to_latex/to_i/to_f). Anything else
  # (a String, a Hash, a BasicObject) raises instead of being stored and
  # crashing later at render.
  module PowerNumerator
    attr_reader :power_numerator

    def power_numerator=(power)
      @power_numerator = coerce_power_type(power)
    end

    private

    def coerce_power_type(power)
      return power if Compose.type_any?([NilClass, Number, Fenced], power)
      if Compose.type?(Numeric, power)
        return Number.new(Compose.numeric_exponent_string(power))
      end

      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :unsupported_storage)
    end
  end
end
