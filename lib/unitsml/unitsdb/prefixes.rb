# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Prefixes < ::Unitsdb::Prefixes
      include Unitsml::Unitsdb::Finders

      def find_by_id(p_id)
        find_first_through(prefixes, via: :identifiers, field: :id, value: p_id)
      end

      def find_by_symbol_name(ascii_sym)
        find_first_through(prefixes, via: :symbols, field: :ascii,
                                     value: ascii_sym)
      end

      def ascii_symbols
        prefixes.each_with_object([]) do |prefix, names_array|
          symbol = prefix.symbols.map(&:ascii)
          next if symbol.empty?

          names_array.concat(symbol)
        end
      end
    end

    Configuration.register_model(Prefixes, id: :prefixes)
  end
end
