# frozen_string_literal: true

module Unitsml
  # Value object for a Unit/Dimension exponent.
  #
  # Unit and Dimension store either nil (no exponent) or this class in
  # @power_numerator. Numeric inputs are normalized into renderable payloads so
  # renderers have one stable interface. Internal dimension-vector throwaway
  # units may additionally carry the exact vector component used for UnitsDB
  # lookup, without changing the render/read API.
  class PowerNumerator
    attr_reader :value, :dimension_vector_value

    def self.coerce(power)
      return power if Compose.type_any?([NilClass, self], power)
      return new(power) if valid_payload?(power)
      if public_numeric?(power)
        return from_raw_value(Compose.numeric_exponent_string(power))
      end

      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :unsupported_storage)
    end

    def self.from_raw_value(raw_value, dimension_vector_value: nil)
      new(Number.new(raw_value.to_s),
          dimension_vector_value: dimension_vector_value)
    end

    def self.for_dimension_vector(power)
      unless public_numeric?(power)
        raise Errors::InvalidPowerError.new(value: power,
                                            reason: :unsupported_storage)
      end

      raw_value = power.to_s
      from_raw_value(raw_value, dimension_vector_value: raw_value)
    end

    def self.valid_payload?(power)
      Compose.type_any?([Number, Fenced], power)
    end

    def self.public_numeric?(power)
      Compose.type_any?([Integer, Rational, Float], power)
    end

    module Storage
      attr_reader :power_numerator

      def power_numerator=(power)
        @power_numerator = PowerNumerator.coerce(power)
      end
    end

    def initialize(value, dimension_vector_value: nil)
      if self.class.valid_payload?(value)
        @value = value
        @dimension_vector_value = dimension_vector_value
      else
        raise_invalid!(value)
      end
    end

    def ==(other)
      case other
      when PowerNumerator
        equivalent_power_numerator?(other)
      else
        equivalent_numeric?(other)
      end
    end

    def negative?
      value.negative?
    end

    def to_i
      value.to_i
    end

    def to_f
      value.to_f
    end

    def to_s
      raw_value
    end

    def float_to_display
      value.float_to_display
    end

    def to_mathml(options)
      value.to_mathml(options)
    end

    def to_html(options)
      value.to_html(options)
    end

    def to_latex(options)
      value.to_latex(options)
    end

    def to_asciimath(options)
      value.to_asciimath(options)
    end

    def to_unicode(options)
      value.to_unicode(options)
    end

    def raw_value
      value.raw_value
    end

    def update_negative_sign
      value.update_negative_sign
      @dimension_vector_value = raw_value if dimension_vector_value
    end

    def one?
      raw_value == "1"
    end

    def fenced?
      value.is_a?(Fenced)
    end

    private

    def equivalent_power_numerator?(other)
      value == other.value
    end

    def equivalent_numeric?(other)
      return false unless Compose.type_any?([Integer, Rational, Float], other)

      raw_value == Compose.numeric_exponent_string(other)
    rescue Errors::InvalidPowerError
      false
    end

    def raise_invalid!(power)
      raise Errors::InvalidPowerError.new(value: power,
                                          reason: :unsupported_storage)
    end
  end
end
