# frozen_string_literal: true

module Unitsml
  module Errors
    class UnknownUnitError < Unitsml::Errors::BaseError
      attr_reader :value, :field

      def initialize(value:, field: :unit)
        @value = value
        @field = field
        super("[unitsml] Unknown unit reference: #{value.inspect} — expected " \
              "a unit symbol id (e.g. \"W\").")
      end
    end
  end
end
