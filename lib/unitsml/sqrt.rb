# frozen_string_literal: true

module Unitsml
  class Sqrt
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value
    end
  end
end
