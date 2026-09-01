# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when a composition mixes units and dimensions in one expression.
    # The XML serializer emits only the dimension block for such a mix, silently
    # dropping the units; the parser rejects the same input outright.
    class MixedTermsError < Unitsml::Errors::BaseError
      def initialize(msg = nil)
        super(msg || "[unitsml] Cannot combine units and dimensions in a " \
                     "single expression.")
      end
    end
  end
end
