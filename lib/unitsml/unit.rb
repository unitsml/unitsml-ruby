# frozen_string_literal: true

module Unitsml
  class Unit
    attr_accessor :unit_name, :power_numerator, :display_exponent, :prefix

    def initialize(unit_name,
                   power_numerator = nil,
                   display_exponent = nil,
                   prefix: nil)
      @prefix = prefix
      @unit_name = unit_name
      @power_numerator = power_numerator
      @display_exponent = display_exponent
    end

    def ==(object)
      self.class == object.class &&
        prefix == object&.prefix &&
        unit_name == object&.unit_name &&
        power_numerator == object&.power_numerator &&
        display_exponent == object&.display_exponent
    end
  end
end
