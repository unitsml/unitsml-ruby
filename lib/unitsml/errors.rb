# frozen_string_literal: true

module Unitsml
  module Errors
    autoload :BaseError, "unitsml/errors/base_error"
    autoload :InvalidModelError, "unitsml/errors/invalid_model_error"
    autoload :MixedTermsError, "unitsml/errors/mixed_terms_error"
    autoload :OpalPayloadNotBundledError,
             "unitsml/errors/opal_payload_not_bundled_error"
    autoload :PlurimathLoadError, "unitsml/errors/plurimath_load_error"
    autoload :UnknownPrefixError, "unitsml/errors/unknown_prefix_error"
    autoload :UnknownUnitError, "unitsml/errors/unknown_unit_error"
    autoload :UnsupportedPayloadTypeError,
             "unitsml/errors/unsupported_payload_type_error"
  end
end
