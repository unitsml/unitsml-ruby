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
      @prefix_instance ||= Unitsdb.prefixes.find_by_symbol_name(prefix_name)
    end

    def id
      @id ||= prefix_instance.identifiers.find { |prefix| prefix.type == "nist" }&.id
    end

    def name
      @name ||= prefix_instance.names.find { |name| name.lang == "en" }.value
    end

    def prefix_symbols
      prefix_instance.symbols.last
    end

    def to_mathml(_)
      symbol = Utility.string_to_html_entity(
        Utility.html_entity_to_unicode(
          prefix_symbols.html
        ),
      )
      return symbol unless only_instance

      { method_name: :mi, value: ::Mml::Mi.new(value: symbol)}
    end

    def to_latex(_)
      prefix_symbols.latex
    end

    def to_asciimath(_)
      prefix_symbols.ascii
    end

    def to_html(_)
      prefix_symbols.html
    end

    def to_unicode(_)
      prefix_symbols.unicode
    end

    def symbolid
      prefix_symbols.ascii if prefix_symbols
    end

    def base
      prefix_instance.base
    end

    def power
      prefix_instance.power
    end
  end
end
