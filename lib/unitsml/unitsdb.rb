# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class << self
      def load_file(file_name)
        @@hash ||= {}
        @@hash[file_name] ||= File.read(valid_path(file_name))
      end

      def units
        @@units_file ||= get_class_from_register(:unitsdb_units).from_yaml(load_file(:units))
      end

      def prefixes
        @@prefixes ||= get_class_from_register(:unitsdb_prefixes).from_yaml(load_file(:prefixes))
      end

      def dimensions
        @@dim_file ||= get_class_from_register(:unitsdb_dimensions).from_yaml(load_file(:dimensions))
      end

      def quantities
        @@quantities ||= get_class_from_register(:unitsdb_quantities).from_yaml(load_file(:quantities))
      end

      def prefixes_array
        @@prefixes_array ||= prefixes.ascii_symbols.sort_by(&:length)
      end

      def prefixes_by_size(size)
        @@sized_prefixes ||= {}
        return @@sized_prefixes[size] if @@sized_prefixes.key?(size)

        @@sized_prefixes[size] = prefixes_array.select { |p| p.size == size }
      end

      def valid_path(file_name)
        File.expand_path(
          File.join(__dir__, "..", "..","unitsdb", "#{file_name}.yaml")
        )
      end

      def get_class_from_register(class_name)
        Unitsml.register.get_class(class_name)
      end
    end
  end
end
