# frozen_string_literal: true

module Unitsml
  class Prefix
    attr_accessor :prefix_name, :only_instance

    def initialize(prefix_name, only_instance = false)
      @prefix_name = prefix_name
      @only_instance = only_instance
    end

    def ==(object)
      self.class == object.class &&
        prefix_name == object&.prefix_name &&
        only_instance == object&.only_instance
    end

    def prefix_instance
      @prefix ||= Unitsdb.prefixes.find_by_symbol_name(prefix_name)
    end

    def id
      @prefix.id
    end

    def name
      prefix_instance.name
    end

    def prefixes_symbols
      prefix_instance.symbol
    end

    def to_mathml
      symbol = Utility.string_to_html_entity(
        Utility.html_entity_to_unicode(
          prefixes_symbols.html
        ),
      )
      return symbol unless only_instance

      { method_name: :mi, value: ::Mml::Mi.new(value: symbol)}
    end

    def to_latex
      prefixes_symbols.latex
    end

    def to_asciimath
      prefixes_symbols.ascii
    end

    def to_html
      prefixes_symbols.html
    end

    def to_unicode
      prefixes_symbols.unicode
    end

    def symbolid
      prefixes_symbols.ascii if prefixes_symbols
    end

    def base
      prefix_instance.base
    end

    def power
      prefix_instance.power
    end
  end
end
