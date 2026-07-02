# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when a dimension reference cannot be resolved. Dimension.new has no
    # existence check, so compose validates eagerly to stay fail-fast.
    class UnknownDimensionError < Unitsml::Errors::BaseError
      attr_reader :value

      def initialize(value:)
        @value = value
        super("[unitsml] Unknown dimension reference: #{value.inspect} — " \
              "expected a dimension id (e.g. \"dim_L\").")
      end
    end
  end
end
