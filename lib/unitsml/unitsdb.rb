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
        @@prefixes_array ||= prefixes_hash.keys.sort_by(&:length).reverse
      end

      def parsable_dimensions
        @@parsable_dimensions ||= dimensions_ids(dimensions_hash)
      end

      def quantities
        @@quantities ||= quantities_hash
      end

      def units_hash
        @@units_hash ||= units_ids(load_yaml("units"))
      end

      def filtered_units
        @@filtered_units_array ||= units_hash.keys.reject do |unit|
          ((/\*|\^|\/|^1$/).match(unit) || units_hash.dig(unit, :fields, "prefixed"))
        end
      end

      def prefixes_hash
        @@prefixes_hashes ||= prefixs_ids(load_yaml("prefixes"))
      end

      def dimensions_hash
        @@dimensions_hashs ||= insert_vectors(load_yaml("dimensions"))
      end

      def quantities_hash
        @@quantities_hashs ||= load_yaml("quantities")
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
            hash[find_id(v)] = { id: key, fields: value }
          end
        end
        hash
      end

      def find_id(value)
        return if value == true
        return unless value.is_a?(Hash)

        value&.dig("dim_symbols")&.map { |symbol| symbol&.dig("id") }&.first
      end

      def vector(dim_hash)
        %w(Length Mass Time ElectricCurrent ThermodynamicTemperature
            AmountOfSubstance LuminousIntensity PlaneAngle)
          .map { |h| dim_hash.dig(underscore(h), "powerNumerator") }.join(":")
      end

      def underscore(str)
        str.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      def insert_vectors(dims)
        dims.each do |key, value|
          value[:vector] = vector(value)
          value[:id] = key
        end
      end
    end
  end
end
