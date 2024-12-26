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

    def to_asciimath(options)
      value&.to_asciimath(options)
    end

    def to_latex(options)
      value&.to_latex(options)
    end

    def to_mathml(options)
      value&.to_mathml(options)
    end

    def to_html(options)
      value&.to_html(options)
    end

    def to_unicode(options)
      value&.to_unicode(options)
    end
  end
end
