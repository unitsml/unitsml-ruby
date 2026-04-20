# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class PrefixReference < ::Unitsdb::PrefixReference
      def base
        prefix.base
      end

      def symbolid
        prefix.symbols.first.ascii
      end

      def power
        prefix.power
      end

      def prefix
        @prefix ||= Unitsml::Unitsdb.database.prefixes.find do |p|
          p.identifiers.any? { |i| i.id == id }
        end
      end
    end

    Configuration.register_model(PrefixReference, id: :prefix_reference)
  end
end
