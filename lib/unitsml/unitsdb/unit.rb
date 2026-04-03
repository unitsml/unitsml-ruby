# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Unit < ::Unitsdb::Unit
      def dimension_url
        quantity_id = quantity_references[0].id
        quantity = Unitsdb.quantities.find_by_id(quantity_id)
        quantity.dimension_reference.id
      end

      def en_name
        names.find { |name| name.lang == "en" }&.value
      end

      def nist_id
        identifiers.find { |id| id.type == "nist" }&.id
      end
    end
  end
end
