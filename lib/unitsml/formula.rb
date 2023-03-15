# frozen_string_literal: true

module Unitsml
  class Formula
    attr_accessor :value, :explicit_value, :root

    def initialize(value = [],
                   explicit_value: nil,
                   root: false,
                   orig_text: nil,
                   norm_text: nil)
      @value = value
      @explicit_value = explicit_value
      @root = root
      @orig_text = orig_text
      @norm_text = norm_text
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value &&
        explicit_value == object&.explicit_value &&
        root == object.root
    end
  end
end
