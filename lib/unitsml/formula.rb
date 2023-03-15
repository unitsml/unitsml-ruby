# frozen_string_literal: true

module Unitsml
  class Formula
    attr_accessor :value, :explicit_value

    def initialize(value = [], explicit_value = nil)
      @value = value
      @explicit_value = explicit_value
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value &&
        explicit_value == object&.explicit_value
    end
  end
end
