module Unitsml
  class UnitSystem
    UNITS_DB_UNIT_SYSTEMS_PATH = File
                      .expand_path("../../vendor/unitsdb/unit_systems.yaml",
                        File.dirname(__FILE__))
                      .freeze

    attr_reader :id,
      :name,
      :acceptable

    class << self
      def find_unit_system(ascii:)
        symbols.find { |unit| unit.id == ascii.to_s }
      end

      def symbols
        @symbols ||= YAML
                      .load(File.read(UNITS_DB_UNIT_SYSTEMS_PATH))
                      .map { |attrs| Unitsml::UnitSystem.new(attrs["id"], attrs) }
      end

      def from_yaml(yaml_path)
        @symbols = YAML
                    .load(File.read(yaml_path))
                    .map { |attrs| Unitsml::UnitSystem.new(attrs["id"], attrs) }
      end
    end

    def initialize(id, attrs)
      @id = attrs["id"]
      @name = attrs["name"]
      @acceptable = attrs["acceptable"]
    end
  end
end
