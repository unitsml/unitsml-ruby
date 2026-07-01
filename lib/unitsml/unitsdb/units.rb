# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Units < ::Unitsdb::Units
      include Unitsml::Unitsdb::Finders

      def find_by_id(u_id)
        find_first_through(units, via: :identifiers, field: :id, value: u_id)
      end

      def find_by_name(u_name)
        find_first_through(units, via: :symbols, field: :id, value: u_name)
      end

      def filtered
        @filtered ||= symbols_ids.reject do |unit|
          %r{\*|\^|/|^1$}.match?(unit) || find_by_symbol_id(unit).prefixed
        end
      end

      def find_by_symbol_id(sym_id)
        symbols_hash[sym_id]
      end

      def symbols_ids
        symbols_hash.keys
      end

      def symbols_hash
        @symbols_hash ||= units.each_with_object({}) do |unit, object|
          unit.symbols&.each { |unit_sym| object[unit_sym.id] = unit }
        end
      end

      def find_by_short(short)
        short_hash[short]
      end

      def short_hash
        @short_hash ||= units.each_with_object({}) do |unit, object|
          object[unit.short] = unit if unit.short
        end
      end
    end

    Configuration.register_model(Units, id: :units)
  end
end
