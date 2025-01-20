# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Units
      attr_accessor :units

      def find_by_id(u_id)
        units.find { |unit| unit.id == u_id }
      end

      def find_by_name(u_name)
        units.find do |unit|
          unit.unit_symbols.find { |u_sym| u_sym.id == u_name }
        end
      end

      def filtered
        @filtered ||= units_symbol_ids.reject do |unit|
          ((/\*|\^|\/|^1$/).match?(unit) || find_by_symbol_id(unit).prefixed)
        end
      end

      def find_by_symbol_id(sym_id)
        units_symbol_hash[sym_id]
      end

      def units_symbol_ids
        units_symbol_hash.keys
      end

      def units_symbol_hash
        @symbol_ids_hash ||= {}

        if @symbol_ids_hash.empty?
          units.each_with_object(@symbol_ids_hash) do |unit, object|
            unit.unit_symbols.each { |unit_sym| object[unit_sym.id] = unit }
          end
        end
        @symbol_ids_hash
      end
    end
  end
end
