module Unitsml
  module FencedNumeric
    def to_i
      value.to_i
    end

    def to_f
      value.to_f
    end

    def raw_value
      value.raw_value
    end
  end
end
