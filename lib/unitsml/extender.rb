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
      extender = multiplier(options[:multiplier] || "⋅", unicode: true)
      rspace = "thickmathspace" if options[:multiplier] == :space
      {
        method_name: :mo,
        value: ::Mml::Mo.new(value: extender, rspace: rspace),
      }
    end

    def to_latex(options)
      multiplier(options[:multiplier] || "/")
    end

    def to_asciimath(options)
      multiplier(options[:multiplier] || symbol)
    end

    def to_html(options)
      multiplier(options[:multiplier] || "⋅", unicode: true)
    end

    def to_unicode(options)
      extender = options[:multiplier] ||
                   symbol == "*" ? "·" : symbol
      multiplier(extender)
    end

    private

    def multiplier(extender, unicode: false)
      case extender
      when :space
        unicode ? "&#x2062;" : " "
      when :nospace
        unicode ? "&#x2062;" : ""
      else
        unicode ? Utility.string_to_html_entity(extender) : extender
      end
    end
  end
end
