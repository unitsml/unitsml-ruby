# frozen_string_literal: true

module Unitsml
  # Value object that adapts the various "prefix-shaped" inputs flowing
  # through Unitsml::Utility to a single, type-explicit interface.
  #
  # Dispatch is by `is_a?` / `case/when`, so type errors surface at the
  # boundary instead of silently falling through.
  #
  # Recognized inputs:
  #   - `Unitsml::Prefix`              — already adapted, has full API
  #   - `::Unitsdb::Prefix`            — upstream record, has `symbols`
  #   - `Unitsml::Unitsdb::PrefixReference` — UnitsML reference, has `symbolid`
  #   - `::Unitsdb::PrefixReference`   — bare id/type, needs lookup
  #   - `String`                       — prefix name, looked up
  #   - `nil`                          — null adapter
  class PrefixAdapter
    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def self.wrap(prefix)
      return new(nil) if prefix.nil?
      return prefix if prefix.is_a?(PrefixAdapter)

      case prefix
      when Unitsml::Prefix, ::Unitsdb::Prefix,
           Unitsml::Unitsdb::PrefixReference
        new(prefix)
      when ::Unitsdb::PrefixReference
        from_id(prefix.id)
      when String
        from_name(prefix)
      else
        new(nil)
      end
    end

    def self.from_name(name)
      return new(nil) unless Unitsml::Unitsdb.prefixes_array.include?(name)

      new(Unitsml::Prefix.new(name))
    end

    def self.from_id(id)
      new(Unitsml::Unitsdb.prefixes.find_by_id(id))
    end
    private_class_method :from_id

    def null?
      @raw.nil?
    end

    def base
      @raw&.base
    end

    def power
      @raw&.power
    end

    def symbolid
      case @raw
      when Unitsml::Prefix, Unitsml::Unitsdb::PrefixReference
        @raw.symbolid
      when ::Unitsdb::Prefix
        @raw.symbols.first&.ascii
      end
    end

    def prefix_name
      case @raw
      when Unitsml::Prefix
        @raw.prefix_name
      when ::Unitsdb::Prefix, Unitsml::Unitsdb::PrefixReference
        symbolid
      end
    end
  end
end
