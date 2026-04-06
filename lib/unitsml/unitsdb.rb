# frozen_string_literal: true

module Unitsml
  module Unitsdb
    autoload :Unit, "#{__dir__}/unitsdb/unit"
    autoload :Units, "#{__dir__}/unitsdb/units"
    autoload :Prefixes, "#{__dir__}/unitsdb/prefixes"
    autoload :Dimension, "#{__dir__}/unitsdb/dimension"
    autoload :Dimensions, "#{__dir__}/unitsdb/dimensions"
    autoload :Quantities, "#{__dir__}/unitsdb/quantities"
    autoload :PrefixReference, "#{__dir__}/unitsdb/prefix_reference"
    autoload :DimensionQuantity, "#{__dir__}/unitsdb/dimension_quantity"
    autoload :SiDerivedBase, "#{__dir__}/unitsdb/si_derived_base"

    class << self
      REQUIRED_DATABASE_FILES = %w[
        prefixes.yaml
        dimensions.yaml
        units.yaml
        quantities.yaml
        unit_systems.yaml
      ].freeze

      def units
        Units.new(units: database.units)
      end

      def prefixes
        Prefixes.new(prefixes: database.prefixes)
      end

      def dimensions
        Dimensions.new(dimensions: database.dimensions)
      end

      def quantities
        Quantities.new(quantities: database.quantities)
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
          return ::Unitsdb.database
        end

        ::Unitsdb::Database.from_db(database_path)
      rescue ::Unitsdb::Errors::DatabaseNotFoundError,
             ::Unitsdb::Errors::DatabaseFileNotFoundError
        ::Unitsdb::Database.from_db(database_path)
      end

      def database_path
        candidate_database_paths.find { |path| database_files_present?(path) } ||
          File.join(unitsdb_gem_path, "vendor", "unitsdb")
      end

      def candidate_database_paths
        [
          File.join(unitsdb_gem_path, "data"),
          File.join(unitsdb_gem_path, "vendor", "unitsdb")
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
