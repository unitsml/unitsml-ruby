# frozen_string_literal: true

module Unitsml
  class Parser
    attr_accessor :text

    def initialize(text)
      @regexp = %r{(quantity|name|symbol|multiplier):\s*}
      @text = text&.match(/unitsml\((.*)\)/) ? Regexp.last_match[1] : text
      post_extras
    end

    def parse
      nodes = Parse.new.parse(text)
      Formula.new(
        [
          Transform.new.apply(nodes),
        ],
        @extras_hash,
      )
    end

    def post_extras
      return nil unless @regexp.match?(text)

      @extras_hash = {}
      texts_array = text&.split(",")&.map(&:strip)
      @text = texts_array&.shift
      texts_array&.map { |text| parse_extras(text) }
    end

    def parse_extras(text)
      return nil unless @regexp.match?(text)

      key, _, value = text&.partition(":")
      @extras_hash[key&.to_sym] ||= value&.strip
    end
  end
end
