# frozen_string_literal: true

module Unitsml
  class Prefix
    attr_accessor :prefix_name

    def initialize(prefix_name)
      @prefix_name = prefix_name
    end

    def ==(object)
      self.class == object.class &&
        prefix_name == object&.prefix_name
    end
  end
end
