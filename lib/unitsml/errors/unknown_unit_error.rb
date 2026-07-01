# frozen_string_literal: true

module Unitsml
  module Errors
    class UnknownUnitError < Unitsml::Errors::BaseError
      attr_reader :value, :field

      def initialize(value:, field: :unit)
        @value = value
        @field = field
        super("[unitsml] Unknown unit reference: #{value.inspect} — expected " \
              "a symbol id (e.g. \"W\") or short name (e.g. \"watt\").")
      end
    end
  end
end
