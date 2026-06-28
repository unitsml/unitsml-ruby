# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Dimensions < ::Unitsdb::Dimensions
      include Unitsml::Unitsdb::Finders

      def dimensions=(value)
        super(value.map { |d| Dimension.new(d.to_hash) })
      end

      def find_by_vector(vector)
        dimensions.each(&:set_vector)
        dimensions.find { |dim| dim.set_vector == vector }
      end

      def find_by_id(d_id)
        find_first_in(dimensions, field: :id, value: d_id)
      end

      def find_parsables_by_id(d_id)
        find_first_in(dimensions, field: :id, value: parsables[d_id])
      end

      def parsables
        @parsables ||= dimensions.select(&:parsables).each_with_object({}) do |dimension, object|
          object.merge!(dimension.parsables)
        end
      end
    end

    Configuration.register_model(Dimensions, id: :dimensions)
  end
end
