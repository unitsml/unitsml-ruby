# frozen_string_literal: true

module Unitsml
  # Validated storage for the power_numerator exponent shared by Unit and
  # Dimension: only types the render/decomposition paths can handle may be
  # stored — nil, a raw Numeric (internal decomposition), a Number, or a
  # Fenced exponent (the parser's m^((1/2)) form). Anything else raises
  # rather than being stored and crashing later at render. Values are stored
  # as given (never coerced): value-level rules such as "the parser cannot
  # express a decimal exponent" belong to the compose input boundary.
  module PowerNumerator
    attr_reader :power_numerator

    def power_numerator=(power)
      @power_numerator = validate_power_type(power)
    end

    private

    def validate_power_type(power)
      return power if power.nil? || power.is_a?(Numeric)
      return power if power.is_a?(Number) || power.is_a?(Fenced)

      raise Errors::InvalidPowerError.new(value: power)
    end
  end
end
