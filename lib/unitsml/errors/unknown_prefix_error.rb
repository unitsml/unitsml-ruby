# frozen_string_literal: true

module Unitsml
  module Errors
    class UnknownPrefixError < Unitsml::Errors::BaseError
      attr_reader :value, :field

      def initialize(value:, field: :prefix)
        @value = value
        @field = field
        super("[unitsml] Unknown prefix reference: #{describe(value)}.")
      end
    end
  end
end
