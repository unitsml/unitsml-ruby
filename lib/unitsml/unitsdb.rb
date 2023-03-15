# frozen_string_literal: true

require "yaml"
module Unitsml
  module Unitsdb
    class << self
      def load_yaml(file_name)
        @@hash ||= {}
        file_path = File.path("unitsdb/#{file_name}.yaml")
        @@hash[file_name.to_sym] ||= YAML.load_file(file_path)
      end

      def units
        @@units ||= units_hash
      end

      def prefixes
        @@prefixes ||= prefixes_hash
      end

      def dimensions
        @@dimensions ||= dimensions_hash
      end

      def quantities
        @@quantities ||= quantities_hash
      end

      def units_hash
        @@units_hash ||= units_ids(load_yaml("units"))
      end

      def double_letter_units
        @@double_letter_units ||= units_hash.reject { |k, _| k.length == 1 }
      end

      def prefixes_hash
        @@prefixes_hash ||= prefixs_ids(load_yaml("prefixes"))
      end

      def dimensions_hash
        @@dimensions_hash ||= dimensions_ids(load_yaml("dimensions"))
      end

      def quantities_hash
        @@quantities_hash ||= load_yaml("quantities")
      end

      def units_ids(unit_hash, symbols = {})
        unit_hash.each do |key, value|
          value["unit_symbols"]&.each do |symbol|
            symbols[symbol["id"]] = { id: key, fields: value } unless symbol["id"]&.empty?
          end
        end
        symbols
      end

      def prefixs_ids(prefixe_hash, hash = {})
        prefixe_hash&.each do |key, value|
          symbol = value&.dig("symbol", "ascii")
          hash[symbol] = { id: key, fields: value } unless symbol&.empty?
        end
        hash
      end

      def dimensions_ids(dimension_hash, hash = {})
        dimension_hash.each do |key, value|
          value.each do |_, v|
            id = v["dim_symbols"]&.map { |symbol| symbol["id"] } unless v == true
            hash[id] = { id: key, fields: value }
          end
        end
        hash
      end
    end
  end
end
