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
        @prefix ||= Unitsdb.prefixes.find_by_id(id)
      end
    end
  end
end
