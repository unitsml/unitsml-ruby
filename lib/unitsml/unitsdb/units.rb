# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Units < ::Unitsdb::Units
      def find_by_id(u_id)
        find(u_id, :id, :identifiers)
      end

      def find_by_name(u_name)
        find(u_name, :id, :symbols)
      end

      def filtered
        @filtered ||= symbols_ids.reject do |unit|
          ((/\*|\^|\/|^1$/).match?(unit) || find_by_symbol_id(unit).prefixed)
        end
      end

      def find_by_symbol_id(sym_id)
        symbols_hash[sym_id]
      end

      def symbols_ids
        symbols_hash.keys
      end

      def symbols_hash
        @symbol_ids_hash ||= units.each_with_object({}) do |unit, object|
          unit.symbols&.each { |unit_sym| object[unit_sym.id] = unit }
        end
      end

      private

      def find(matching_data, field, unit_method)
        units.find do |unit|
          unit.public_send(unit_method.to_sym).find do |id|
            id.public_send(field) == matching_data
          end
        end
      end
    end
  end
end

Unitsml.register.register_model(Unitsml::Unitsdb::Units, id: :unitsdb_units)
