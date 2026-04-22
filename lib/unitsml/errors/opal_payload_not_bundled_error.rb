# frozen_string_literal: true

module Unitsml
  module Errors
    class OpalPayloadNotBundledError < Unitsml::Errors::BaseError
      def to_s
        "[unitsml] Error: Opal database payload is not bundled."
      end
    end
  end
end
