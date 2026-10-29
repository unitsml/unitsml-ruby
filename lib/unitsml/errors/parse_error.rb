# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised by Unitsml.parse for text that is not a UnitsML expression. The
    # parser's own error (Parsanol::ParseFailed) is kept as #cause, so
    # callers rescue this class instead of the parser library's.
    class ParseError < BaseError
      attr_reader :text

      def initialize(text)
        @text = text
        super("[unitsml] Error: cannot parse #{text.inspect} as a UnitsML " \
              "expression.")
      end
    end
  end
end
