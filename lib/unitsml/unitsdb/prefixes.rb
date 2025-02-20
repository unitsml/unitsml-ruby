# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Prefixes
      attr_accessor :prefixes

      def find_by_symbol_name(ascii_sym)
        prefixes.find { |prefix| prefix.symbol.ascii == ascii_sym }
      end

      def ascii_symbols
        prefixes.each_with_object([]) do |prefix, names_array|
          symbol = prefix.symbol.ascii
          next if symbol.empty?

          names_array << symbol
        end
      end
    end
  end
end
