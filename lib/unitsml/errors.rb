# frozen_string_literal: true

module Unitsml
  module Errors
    autoload :BaseError, "unitsml/errors/base_error"
    autoload :InvalidModelError, "unitsml/errors/invalid_model_error"
    autoload :OpalPayloadNotBundledError,
             "unitsml/errors/opal_payload_not_bundled_error"
    autoload :PlurimathLoadError, "unitsml/errors/plurimath_load_error"
    autoload :PargLoadError, "unitsml/errors/parg_load_error"
    autoload :QuantityOperationError, "unitsml/errors/quantity_errors"
    autoload :DimensionMismatchError, "unitsml/errors/quantity_errors"
    autoload :ScaleOperationError, "unitsml/errors/quantity_errors"
    autoload :IndeterminateResultError, "unitsml/errors/quantity_errors"
    autoload :ConversionError, "unitsml/errors/quantity_errors"
    autoload :UnsupportedPayloadTypeError,
             "unitsml/errors/unsupported_payload_type_error"
  end
end
