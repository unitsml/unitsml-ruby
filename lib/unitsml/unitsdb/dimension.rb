# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Dimension < ::Unitsdb::Dimension
      QUANTITY_KEYS = %i[
        length
        mass
        time
        thermodynamic_temperature
        amount_of_substance
        luminous_intensity
        plane_angle
        electric_current
      ].freeze

      attr_reader :parsables,
                  :parsable,
                  :processed_keys,
                  :vector

      def initialize(attrs)
        @quantities = {}
        @parsables = {}
        @processed_keys = []
        @parsable = false
        super
      end

      QUANTITY_KEYS.each do |key|
        define_method("#{key}=") do |value|
          register_quantity(key, value)
        end

        define_method(key) do
          @quantities[key]
        end
      end

      def dim_symbols
        processed_keys.flat_map do |vec|
          dimension_symbols_for(public_send(vec)).map(&:id)
        end.compact
      end

      def processed_symbol
        public_send(processed_keys.first).symbol
      end

      def set_vector
        @set_vector ||= Utility::DIMS_VECTOR.map do |h|
          public_send(Utility.underscore(h))&.power
        end.join(":")
      end

      def id
        identifiers.find { |id| id.type == "nist" }&.id
      end

      private

      def register_quantity(key, value)
        return if value.nil?

        @quantities[key] = value
        @processed_keys << key.to_s
        dim_symbols = dimension_symbols_for(value)
        return if Lutaml::Model::Utils.empty?(dim_symbols)

        @parsable = true
        dim_symbols.each { |dim_sym| @parsables[dim_sym.id] = id }
      end

      def dimension_symbols_for(value)
        return [] if value.nil?
        return Array(value.dim_symbols) if value.is_a?(::Unitsdb::Dimension)
        return Array(value.symbols) if value.is_a?(::Unitsdb::DimensionDetails)

        []
      end
    end

    Configuration.register_model(Dimension, id: :dimension)
  end
end
