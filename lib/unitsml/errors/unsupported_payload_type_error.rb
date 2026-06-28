# frozen_string_literal: true

module Unitsml
  module Errors
    class UnsupportedPayloadTypeError < Unitsml::Errors::BaseError
      def initialize(actual_class)
        super("[unitsml] Error: Unsupported Opal payload type " \
              "#{actual_class}. PayloadGenerator only emits Hash, Array, " \
              "String, Symbol, Integer, Float, true, false, and nil.")
      end
    end
  end
end
