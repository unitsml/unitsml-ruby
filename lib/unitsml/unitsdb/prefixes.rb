# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Prefixes < ::Unitsdb::Prefixes
      def find_by_id(p_id)
        find(p_id, :id, :identifiers)
      end

      def find_by_symbol_name(ascii_sym)
        find(ascii_sym, :ascii, :symbols)
      end

      def ascii_symbols
        prefixes.each_with_object([]) do |prefix, names_array|
          symbol = prefix.symbols.map(&:ascii)
          next if symbol.empty?

          names_array.concat(symbol)
        end
      end

      private

      def find(matching_data, field, prefix_method)
        prefixes.find do |prefix|
          prefix.public_send(prefix_method.to_sym).find do |object|
            object.public_send(field) == matching_data
          end
        end
      end
    end
  end
end

Unitsml.register_model(Unitsml::Unitsdb::Prefixes, id: :unitsdb_prefixes)
