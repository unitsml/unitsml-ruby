# frozen_string_literal: true

module Unitsml
  class Extender
    attr_accessor :symbol

    def initialize(symbol)
      @symbol = symbol
    end

    def ==(object)
      self.class == object.class &&
        symbol == object&.symbol
    end

    def to_mathml(options)
      multiplier = options[:multiplier] || "&#x22c5;"
      Utility.ox_element("mo") << multiplier
    end

    def to_latex(options)
      options[:multiplier] || "/"
    end

    def to_asciimath(options)
      options[:multiplier] || symbol
    end

    def to_html(options)
      options[:multiplier] || "&#x22c5;"
    end

    def to_unicode(options)
      options[:multiplier] ||
        symbol == "*" ? "·" : symbol
    end
  end
end
