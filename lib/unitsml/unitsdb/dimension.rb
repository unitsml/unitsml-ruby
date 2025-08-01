# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Dimension < ::Unitsdb::Dimension
      attr_reader :parsables,
                  :parsable,
                  :processed_keys,
                  :vector

      def initialize(attrs)
        super
        @parsables = {}
        @processed_keys = []
        @parsable = false
      end

      def length=(value)
        quantities_common_code(:length, value)
      end

      def mass=(value)
        quantities_common_code(:mass, value)
      end

      def time=(value)
        quantities_common_code(:time, value)
      end

      def thermodynamic_temperature=(value)
        quantities_common_code(:thermodynamic_temperature, value)
      end

      def amount_of_substance=(value)
        quantities_common_code(:amount_of_substance, value)
      end

      def luminous_intensity=(value)
        quantities_common_code(:luminous_intensity, value)
      end

      def plane_angle=(value)
        quantities_common_code(:plane_angle, value)
      end

      def electric_current=(value)
        quantities_common_code(:electric_current, value)
      end

      def dim_symbols
        processed_keys.map { |vec| public_send(vec)&.dim_symbols&.map(&:id) }.flatten.compact
      end

      def processed_symbol
        public_send(processed_keys.first).symbol
      end

      def set_vector
        @vector ||= Utility::DIMS_VECTOR.map do |h|
          public_send(Utility.underscore(h))&.power
        end.join(":")
      end

      def id
        identifiers.find { |id| id.type == "nist" }&.id
      end

      private

      def quantities_common_code(instance_var, value)
        return if value.nil?

        instance_variable_set(:"@#{instance_var}", value)
        @processed_keys << instance_var.to_s
        return if Lutaml::Model::Utils.empty?(value.symbols)

        @parsable = true
        value.dim_symbols_ids(@parsables, id)
      end
    end
  end
end
