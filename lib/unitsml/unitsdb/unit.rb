# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Unit < ::Unitsdb::Unit
      def dimension_url
        quantity = Unitsml::QuantityKind.primary_for(self)&.record
        quantity&.dimension_reference&.id
      end

      def en_name
        names.find { |name| name.lang == "en" }&.value
      end

      def nist_id
        identifiers.find { |id| id.type == "nist" }&.id
      end

      Configuration.register_model(self, id: :unit)
    end
  end
end
