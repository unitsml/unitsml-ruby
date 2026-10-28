# frozen_string_literal: true

module Unitsml
  module Errors
    class QuantityOperationError < BaseError; end
    class DimensionMismatchError < QuantityOperationError; end
    class ScaleOperationError < QuantityOperationError; end
    class IndeterminateResultError < QuantityOperationError; end
    class ConversionError < QuantityOperationError; end
  end
end
