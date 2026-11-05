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

    # The exponent lexemes the library itself stores: an integer, an n/m or
    # n//m fraction (parser), or a decimal ("0.5" for sqrt, "2.0" from unit
    # decomposition). Anything else ("abc") has no numeric meaning and would
    # render and serialize as garbage.
    NUMBER_LEXEME = %r{\A-?\d+(\.\d+)?(//?-?\d+)?\z}
    private_constant :NUMBER_LEXEME

    def coerce_power_type(power)
      return power if Compose.type?(NilClass, power)
      return validate_number_power(power) if Compose.type?(Number, power)
      return validate_fenced_power(power) if Compose.type?(Fenced, power)
      # Only the numeric types the parser can express (Integer, Rational, whole
      # Float) coerce; other Numerics (BigDecimal, Complex, ...) are rejected
      # rather than stringified into a non-parser exponent.
      if Compose.type_any?([Integer, Rational, Float], power)
        return Number.new(Compose.numeric_exponent_string(power))
      end

      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :unsupported_storage)
    end

    def validate_number_power(power)
      lexeme = Compose.safe_string(power.raw_value)
      return power if lexeme&.match?(NUMBER_LEXEME)

      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :invalid_number)
    end

    # A Fenced exponent is checked at its innermost Number; other parser
    # payloads inside the fence are kept as-is.
    def validate_fenced_power(power)
      inner = power.value
      inner = inner.value while Compose.type?(Fenced, inner)
      validate_number_power(inner) if Compose.type?(Number, inner)
      power
    end
  end
end
