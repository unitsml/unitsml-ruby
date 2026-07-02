# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when a builder-supplied power cannot become a parser-style
    # exponent: an unsupported type, or a non-integer / non-finite Float (the
    # parser has no decimal exponent — pass a Rational instead).
    class InvalidPowerError < Unitsml::Errors::BaseError
      attr_reader :value, :reason

      def initialize(value:, reason: :unsupported_type)
        @value = value
        @reason = reason
        super(message_for(reason, value))
      end

      private

      def message_for(reason, value)
        case reason
        when :non_integer_float
          "[unitsml] Non-integer Float power: #{value.inspect} — use a " \
          "Rational (e.g. Rational(1, 2)) for a fractional exponent."
        else
          "[unitsml] Unsupported power: #{value.inspect} — expected an " \
          "Integer, Rational, Float or Unitsml::Number."
        end
      end
    end
  end
end
