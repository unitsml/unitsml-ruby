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

      # Message per field; %s is the described value.
      MESSAGES = {
        operand: "[unitsml] Cannot compose with %s — expected a Unit, " \
                 "Dimension or Formula.",
        prefix: "[unitsml] A dimension cannot take a prefix: %s.",
        multiplier: "[unitsml] Invalid multiplier: %s — expected a String, " \
                    ":space, or :nospace.",
        name: "[unitsml] Invalid name: %s — expected a String or Symbol.",
        unit: "[unitsml] Invalid unit: %s — expected a String, Unit or " \
              "Formula.",
        extender: "[unitsml] Invalid extender: %s — expected \"*\", \"/\" " \
                  "or \"//\"; custom separators are a render option " \
                  "(multiplier:).",
      }.freeze

      private

      def message_for(field, value)
        template = MESSAGES.fetch(field) do
          "[unitsml] Invalid #{field} entry: %s — expected a reference " \
            "(String/Symbol), a Hash, or a matching Unit/Dimension."
        end
        format(template, describe(value))
      end
    end
  end
end
