# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Quantities < ::Unitsdb::Quantities
      def find_by_id(q_id)
        quantities.find do |quantity|
          quantity.identifiers.find { |id| id.id == q_id }
        end
      end

      # Resolve a quantity by its human name: English names + short slug,
      # case-insensitive. Non-English synonyms are skipped (some contain
      # commas the parser's comma-metadata handling would truncate).
      def find_by_name(name)
        return if name.to_s.strip.empty?

        key = name.to_s.downcase
        quantities.find { |quantity| name_matches?(quantity, key) }
      end

      private

      def name_matches?(quantity, key)
        return true if quantity.short.to_s.downcase == key

        quantity.names.any? do |name|
          name.lang == "en" && name.value.to_s.downcase == key
        end
      end
    end

    Configuration.register_model(Quantities, id: :quantities)
  end
end
