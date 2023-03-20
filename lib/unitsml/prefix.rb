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

    def id
      Unitsdb.prefixes_hash.dig(prefix_name, :id)
    end

    def name
      fields.dig("name")
    end

    def fields
      Unitsdb.prefixes_hash.dig(prefix_name, :fields)
    end

    def prefixes_symbols
      fields&.dig("symbol")
    end

    def to_mathml
      prefixes_symbols["html"]
    end

    def to_latex
      prefixes_symbols["latex"]
    end

    def to_asciimath
      prefixes_symbols["ascii"]
    end

    def to_html
      prefixes_symbols["html"]
    end

    def to_unicode
      prefixes_symbols["unicode"]
    end

    def symbolid
      prefixes_symbols["ascii"] if prefixes_symbols
    end

    def base
      fields&.dig("base")
    end

    def power
      fields&.dig("power")
    end
  end
end
