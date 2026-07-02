# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when a compose entry (or operator operand) is not something the
    # builder can turn into a term: the wrong type, the wrong kind for the mode
    # (a Dimension in units: / a Unit in dimensions:), a prefix on a dimension,
    # or a non-composable `*`/`/` operand.
    class InvalidUnitEntryError < Unitsml::Errors::BaseError
      attr_reader :value, :field

      def initialize(value:, field: :entry)
        @value = value
        @field = field
        super(message_for(field, value))
      end

      private

      def message_for(field, value)
        case field
        when :operand
          "[unitsml] Cannot compose with #{value.inspect} — expected a " \
          "Unit, Dimension or Formula."
        when :prefix
          "[unitsml] A dimension entry cannot take a prefix: #{value.inspect}."
        else
          "[unitsml] Invalid #{field} entry: #{value.inspect} — expected a " \
          "reference (String/Symbol), a Hash, or a matching Unit/Dimension."
        end
      end
    end
  end
end
