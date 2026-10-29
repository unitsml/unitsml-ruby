# frozen_string_literal: true

module Unitsml
  module Errors
    # Raised at render time when a composed Formula puts a separator (extender)
    # where no operand follows it: the expression ends with an extender ("W/"),
    # or two extenders sit together ("W/*"). Such a term list has no valid
    # rendering; only a raw extender chain (#extender/#ext or an Extender
    # operand) can build one — the parser grammar never produces it.
    class MisplacedExtenderError < Unitsml::Errors::BaseError
      def initialize(text = nil)
        super(text || "[unitsml] Composed expression has a separator " \
                      "(extender) with no operand after it; it cannot be " \
                      "rendered.")
      end
    end
  end
end
