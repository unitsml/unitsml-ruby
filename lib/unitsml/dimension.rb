# frozen_string_literal: true

module Unitsml
  class Dimension
    attr_accessor :dimension_name, :power_numerator

    def initialize(dimension_name, power_numerator = nil)
      @dimension_name = dimension_name
      @power_numerator = power_numerator
    end

    def ==(object)
      self.class == object.class &&
        dimension_name == object&.dimension_name &&
        power_numerator == object&.power_numerator
    end
  end
end
