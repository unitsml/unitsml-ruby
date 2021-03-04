require "yaml"

module Unitsml
  class Unit
    UNITS_DB_PATH = File
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
      def find_unit(ascii: ascii)
        id, attrs = symbols.find { |(id, attribute)| id == ascii.to_s }
        Unitsml::Unit.new(id, attrs) if id
      end

      def symbols
        @symbols ||= YAML.load(File.read(UNITS_DB_PATH))
      end
    end

    def initialize(id, hash)
      begin
        @id = id
        @short = short
        @dimension = hash["dimension_url"].sub(/^#/, "")
        hash["short"] && !hash["short"].empty? and @short = hash["short"]
        @unit_system = hash["unit_system"]
        @names = hash["unit_name"]
        @symbols_hash = hash["unit_symbols"]&.each_with_object({}) { |h, m| m[h["id"]] = h } || {}
        @symbols = hash["unit_symbols"]
        hash["root_units"] and hash["root_units"]["enumerated_root_units"] and
          @root = hash["root_units"]["enumerated_root_units"]
        hash["quantity_reference"] and @quantities = hash["quantity_reference"].map { |x| x["url"].sub(/^#/, "") }
        hash["si_derived_bases"] and @si_derived_bases = hash["si_derived_bases"]
      rescue
        raise StandardError.new "Parse fail on Unit #{id}: #{hash}"
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
  end
end
