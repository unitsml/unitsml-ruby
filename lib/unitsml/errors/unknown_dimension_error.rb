# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when a dimension reference cannot be resolved — by Dimension.new
    # (which validates its name against the parsable ids) or by the compose
    # validators, which fail fast with the same error before construction.
    class UnknownDimensionError < Unitsml::Errors::BaseError
      attr_reader :value

      def initialize(value:)
        @value = value
        super("[unitsml] Unknown dimension reference: #{describe(value)} — " \
              "expected a dimension id (e.g. \"dim_L\").")
      end
    end
  end
end
