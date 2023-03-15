# frozen_string_literal: true

module Unitsml
  class Unit
    attr_accessor :unit_name, :power_numerator

    def initialize(unit_name, power_numerator = nil)
      @unit_name = unit_name
      @power_numerator = power_numerator
    end

    def ==(object)
      self.class == object.class &&
        unit_name == object&.unit_name &&
        power_numerator == object&.power_numerator
    end
  end
end
