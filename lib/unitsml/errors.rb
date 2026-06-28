# frozen_string_literal: true

module Unitsml
  module Errors
    autoload :BaseError, "unitsml/errors/base_error"
    autoload :InvalidModelError, "unitsml/errors/invalid_model_error"
    autoload :OpalPayloadNotBundledError,
             "unitsml/errors/opal_payload_not_bundled_error"
    autoload :PlurimathLoadError, "unitsml/errors/plurimath_load_error"
    autoload :UnsupportedPayloadTypeError,
             "unitsml/errors/unsupported_payload_type_error"
  end
end
