# frozen_string_literal: true

module Unitsml
  class Number
    include FencedNumeric
    include MathmlHelper

    attr_accessor :value
    alias raw_value value

    def initialize(value)
      @value = value
    end

    # Coerce a builder-supplied power into a Number, mirroring the exponent
    # strings the parser produces: 1 -> "1", -1 -> "-1", 1/2 -> "1/2",
    # 2.0 -> "2". Non-integer Floats are rejected (the parser cannot express a
    # decimal exponent) - pass a Rational instead. nil and existing power
    # objects pass through untouched.
    def self.coerce(power)
      case power
      when nil, Number then power
      when Integer then new(power.to_s)
      when Rational
        new(power.denominator == 1 ? power.numerator.to_s : power.to_s)
      when Float then coerce_float(power)
      else raise ArgumentError, "unsupported power: #{power.inspect}"
      end
    end

    def self.coerce_float(power)
      unless power.finite? && power == power.to_i
        raise ArgumentError, "non-integer Float power #{power.inspect}; " \
                             "use a Rational (e.g. Rational(1, 2))"
      end

      new(power.to_i.to_s)
    end

    def ==(other)
      self.class == other.class &&
        value == other&.value
    end

    def to_mathml(_options)
      matched_value = value&.match(/-?(.+)/)
      mn_value = matched_value ? matched_value[1] : value
      mn_tag = mml_v4_new(:mn, value: mn_value)
      value.start_with?("-") ? mrow_hash(mn_tag) : mn_hash(mn_tag)
    end

    def to_html(_options)
      value.sub("-", "&#x2212;")
    end

    def to_latex(_options)
      value
    end

    def to_asciimath(_options)
      value
    end

    def to_unicode(_options)
      value
    end

    def negative?
      value.start_with?("-")
    end

    def update_negative_sign
      self.value = if negative?
                     value.delete_prefix("-")
                   else
                     ["-", value].join
                   end
    end

    def float_to_display
      return "" if value.nil?

      value.to_f.round(1).to_s.sub(/\.0$/, "")
    end

    private

    def mrow_hash(mn_tag)
      {
        method_name: :mrow,
        value: mml_v4_new(
          :mrow,
          mo_value: [mml_v4_new(:mo, value: "&#x2212;")],
          mn_value: [mn_tag],
        ),
      }
    end

    def mn_hash(mn_tag)
      {
        method_name: :mn,
        value: mn_tag,
      }
    end
  end
end
