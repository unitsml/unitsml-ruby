# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised when Unitsml.compose is given nothing to build from — neither a
    # non-empty units: nor dimensions: list.
    class EmptyCompositionError < Unitsml::Errors::BaseError
      def initialize(msg = nil)
        super(msg || "[unitsml] Nothing to compose — supply a non-empty " \
                     "`units:` or `dimensions:` list.")
      end
    end
  end
end
