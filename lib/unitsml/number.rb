# frozen_string_literal: true

module Unitsml
  class Number
    include FencedNumeric

    attr_accessor :value
    alias raw_value value

    def initialize(value)
      @value = value
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value
    end

    def to_mathml(_options)
      matched_value = value&.match(/-?(.+)/)
      mn_value = matched_value ? matched_value[1] : value
      mn_tag = ::Mml::Mn.new(value: mn_value)
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
      if negative?
        self.value = value.delete_prefix("-")
      else
        self.value = ["-", value].join
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
