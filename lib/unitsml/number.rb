# frozen_string_literal: true

module Unitsml
  class Number
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value
    end

    def to_mathml(_options)
      mn_tag = ::Mml::Mn.new(value: value.match(/-?(.+)/)[1])
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

    def inverse_negative
      if negative?
        value.delete_prefix!("-")
      else
        value.insert(0, "-")
      end
    end

    def float_to_display
      value&.to_f&.round(1)&.to_s&.sub(/\.0$/, "")
    end

    def to_i_value
      value.to_i
    end

    def to_f
      value.to_f
    end

    def display_exp
      value
    end

    private

    def mrow_hash(mn_tag)
      {
        method_name: :mrow,
        value: ::Mml::Mrow.new(
          mo_value: [::Mml::Mo.new(value: "&#x2212;")],
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
