# frozen_string_literal: true

require "unitsdb"

module Unitsml
  module Unitsdb
    autoload :Database, "unitsml/unitsdb/database"
    autoload :DimensionDetails, "unitsml/unitsdb/dimension_details"
    autoload :Finders, "unitsml/unitsdb/finders"
    autoload :PrefixReference, "unitsml/unitsdb/prefix_reference"
    autoload :Dimension, "unitsml/unitsdb/dimension"
    autoload :Dimensions, "unitsml/unitsdb/dimensions"
    autoload :Unit, "unitsml/unitsdb/unit"
    autoload :Units, "unitsml/unitsdb/units"
    autoload :Prefixes, "unitsml/unitsdb/prefixes"
    autoload :Quantities, "unitsml/unitsdb/quantities"

    class << self
      REQUIRED_DATABASE_FILES = %w[
        prefixes.yaml
        dimensions.yaml
        units.yaml
        quantities.yaml
        unit_systems.yaml
      ].freeze

      CACHE_INSTANCE_VARIABLES = %i[
        @units
        @prefixes
        @dimensions
        @quantities
        @prefixes_array
        @sized_prefixes
        @database
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

      def reset_caches
        CACHE_INSTANCE_VARIABLES.each do |ivar|
          remove_instance_variable(ivar) if instance_variable_defined?(ivar)
        end
      end

      private

      def load_database
        context_id = Configuration.context.id

        load_unitsdb_database(context_id)
      rescue ::Unitsdb::Errors::DatabaseNotFoundError,
             ::Unitsdb::Errors::DatabaseFileNotFoundError
        Database.from_db(database_path, context: context_id)
      end

      def load_unitsdb_database(context_id)
        ::Unitsdb.database(context: context_id)
      rescue ::Unitsdb::Errors::DatabaseNotFoundError,
             ::Unitsdb::Errors::DatabaseFileNotFoundError
        Database.from_db(database_path, context: context_id)
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
