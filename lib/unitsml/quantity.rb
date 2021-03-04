require "unitsml/unit"

module Unitsml
  class Quantity
    UNITS_DB_QUANTITIES_PATH = File
                      .expand_path("../../vendor/unitsdb/quantities.yaml",
                        File.dirname(__FILE__))
                      .freeze

    attr_reader :id, :dimension, :type, :names, :units

    class << self
      def find_quantity(ascii:)
        symbols.find { |unit| unit.id == ascii.to_s }
      end

      def symbols
        @symbols ||= YAML
                      .load(File.read(UNITS_DB_QUANTITIES_PATH))
                      .map { |(id, attrs)| Unitsml::Quantity.new(id, attrs) }
      end

      def from_yaml(yaml_path)
        @symbols = YAML
                    .load(File.read(yaml_path))
                    .map { |(id, attrs)| Unitsml::Quantity.new(id, attrs) }
      end
    end

    def initialize(id, hash)
      begin
        @id = id
        @dimension = hash["dimension_url"].sub(/^#/, "")
        @type = hash["quantity_type"]
        hash["quantity_name"] and @names = hash["quantity_name"]
        @units = serialize_units(hash["unit_reference"])
      # rescue
      #   raise StandardError.new "Parse fail on Quantity #{id}: #{hash}"
      end
    end

    def serialize_units(unit_references)
      return unless unit_references

      unit_references
        .map do |attrs|
          id = attrs["url"].sub(/^#/, "")
          Unitsml::Unit.symbols.find { |unit| unit.id == id }
        end
    end

    def name
      @names&.first
    end

    def unit
      @units&.first
    end
  end
end