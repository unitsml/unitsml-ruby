# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Dimensions < ::Unitsdb::Dimensions
      def find_by_vector(vector)
        @vectored ||= dimensions.each(&:set_vector)
        find(:vector, vector)
      end

      def find_by_id(d_id)
        find(:id, d_id)
      end

      def find_parsables_by_id(d_id)
        find(:id, parsables[d_id])
      end

      def parsables
        @parsables ||= dimensions.select(&:parsables).each_with_object({}) do |dimension, object|
          object.merge!(dimension.parsables)
        end
      end

      private

      def find(field, matching_data)
        dimensions.find { |dim| dim.send(field) == matching_data }
      end
    end
  end
end

Unitsml.register.register_model(Unitsml::Unitsdb::Dimensions, id: :unitsdb_dimensions)
