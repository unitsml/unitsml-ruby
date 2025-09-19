# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Quantities < ::Unitsdb::Quantities
      def find_by_id(q_id)
        quantities.find do |quantity|
          quantity.identifiers.find { |id| id.id == q_id }
        end
      end
    end
  end
end

Unitsml.register_model(Unitsml::Unitsdb::Quantities, id: :unitsdb_quantities)
