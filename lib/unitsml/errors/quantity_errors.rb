# frozen_string_literal: true

module Unitsml
  module Errors
    class QuantityOperationError < BaseError; end
    class DimensionMismatchError < QuantityOperationError; end
    class ScaleOperationError < QuantityOperationError; end
    class IndeterminateResultError < QuantityOperationError; end
    class ConversionError < QuantityOperationError; end
    class InexactPowerError < ConversionError; end
    # Data-declared kinds of the same dimension that the register does not
    # make interchangeable (torque + energy).
    class QuantityKindMismatchError < QuantityOperationError; end
    class UnknownQuantityKindError < QuantityOperationError; end
    # A unit record whose quantity references do not identify exactly one
    # primary quantity.
    class PrimaryQuantityError < BaseError; end
    # A caller register entry that cannot be used: bad factor/offset,
    # declared dimensions that differ from the unit's, or disagreement
    # with the register's own canonical conversion.
    class InvalidUnitRegisterError < ConversionError; end
  end
end
