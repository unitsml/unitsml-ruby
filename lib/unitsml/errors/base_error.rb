# frozen_string_literal: true

module Unitsml
  module Errors
    class BaseError < StandardError
      private

      # Render a user-supplied value for an error message without letting a
      # pathological #inspect (one that raises, or a BasicObject that has none)
      # escape as a non-Errors::* exception while building the message.
      def describe(value)
        rendered = value.inspect
        rendered.is_a?(String) ? rendered : "(unprintable value)"
      rescue StandardError
        "(unprintable value)"
      end
    end
  end
end
