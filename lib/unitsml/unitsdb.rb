# frozen_string_literal: true

require_relative "unitsdb/database"
require_relative "unitsdb/dimension_details"
require_relative "unitsdb/prefix_reference"
require_relative "unitsdb/dimension"
require_relative "unitsdb/dimensions"
require_relative "unitsdb/unit"
require_relative "unitsdb/units"
require_relative "unitsdb/prefixes"
require_relative "unitsdb/quantities"
module Unitsml
  module Unitsdb
    class << self
      REQUIRED_DATABASE_FILES = %w[
        prefixes.yaml
        dimensions.yaml
        units.yaml
        quantities.yaml
        unit_systems.yaml
      ].freeze

      def units
        @units ||= Units.new(
          units: database.units,
          lutaml_register: Configuration.context.id,
        )
      end

      def prefixes
        @prefixes ||= Prefixes.new(
          prefixes: database.prefixes,
          lutaml_register: Configuration.context.id,
        )
      end

      def dimensions
        @dimensions ||= Dimensions.new(
          dimensions: database.dimensions,
          lutaml_register: Configuration.context.id,
        )
      end

      def quantities
        @quantities ||= Quantities.new(
          quantities: database.quantities,
          lutaml_register: Configuration.context.id,
        )
      end

      def prefixes_array
        @prefixes_array ||= prefixes.ascii_symbols.sort_by(&:length)
      end

      def prefixes_by_size(size)
        @sized_prefixes ||= {}
        return @sized_prefixes[size] if @sized_prefixes.key?(size)

        @sized_prefixes[size] = prefixes_array.select { |p| p.size == size }
      end

      def database
        @database ||= load_database
      end

      private

      def load_database
        if ::Unitsdb.respond_to?(:database)
          return ::Unitsdb.database(context: Configuration.context.id)
        end

        ::Unitsdb::Database.from_db(database_path)
      rescue ::Unitsdb::Errors::DatabaseNotFoundError,
             ::Unitsdb::Errors::DatabaseFileNotFoundError
        ::Unitsdb::Database.from_db(database_path)
      end

      def database_path
        candidate_database_paths.find do |path|
          database_files_present?(path)
        end ||
          File.join(unitsdb_gem_path, "vendor", "unitsdb")
      end

      def candidate_database_paths
        [
          File.join(unitsdb_gem_path, "data"),
          File.join(unitsdb_gem_path, "vendor", "unitsdb"),
        ]
      end

      def database_files_present?(dir_path)
        REQUIRED_DATABASE_FILES.all? do |file_name|
          File.exist?(File.join(dir_path, file_name))
        end
      end

      def unitsdb_gem_path
        Gem.loaded_specs.fetch("unitsdb").full_gem_path
      end
    end
  end
end
