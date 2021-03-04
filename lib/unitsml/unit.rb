require "yaml"
require "unitsml/unit_symbol"

module Unitsml
  class Unit
    UNITS_DB_UNITS_PATH = File
                      .expand_path("../../vendor/unitsdb/units.yaml",
                        File.dirname(__FILE__))
                      .freeze

    attr_reader :id,
      :dimension,
      :short,
      :root,
      :unit_system,
      :names,
      :symbols,
      :symbols_hash,
      :root_units,
      :quantities,
      :si_derived_bases,
      :prefixed

    class << self
      def find_unit(ascii:)
        symbols.find { |unit| unit.symbols_hash.keys.include?(ascii.to_s) }
      end

      def symbols
        @symbols ||= YAML
                      .load(File.read(UNITS_DB_UNITS_PATH))
                      .map { |(id, attrs)| Unitsml::Unit.new(id, attrs) }
      end

      def from_yaml(yaml_path)
        @symbols = YAML
                    .load(File.read(yaml_path))
                    .map { |(id, attrs)| Unitsml::Unit.new(id, attrs) }
      end
    end

    def initialize(id, attrs)
      begin
        @id = id
        @short = short
        @dimension = attrs["dimension_url"].sub(/^#/, "")
        attrs["short"] && !attrs["short"].empty? and @short = attrs["short"]
        @unit_system = attrs["unit_system"]
        @names = attrs["unit_name"]
        @symbols_hash = attrs["unit_symbols"]
                          &.each_with_object({}) do |sym_attrs, res|
                            res[sym_attrs["id"]] = Unitsml::UnitSymbol.new(id, sym_attrs)
                          end || {}
        @symbols = attrs["unit_symbols"]&.map { |sym_attrs| Unitsml::UnitSymbol.new(sym_attrs["id"], sym_attrs) }
        attrs["root_units"] and attrs["root_units"]["enumerated_root_units"] and
          @root = attrs["root_units"]["enumerated_root_units"]
        attrs["quantity_reference"] and @quantities = attrs["quantity_reference"].map { |x| x["url"].sub(/^#/, "") }
        attrs["si_derived_bases"] and @si_derived_bases = attrs["si_derived_bases"]
      rescue
        raise StandardError.new "Parse fail on Unit #{id}: #{attrs}"
      end
    end

    def system_name
      @unit_system["name"]
    end

    def system_type
      @unit_system["type"]
    end

    def name
      @names.first
    end

    def symbolid
      @symbols ? @symbols.first["id"] : @short
    end

    def symbolids
      @symbols ? @symbols.map { |s| s["id"] } : [ @short ]
    end

    def to_latex
      @symbols.map(&:latex).reduce(:+) if @symbols
    end
  end
end
