# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class SiDerivedBase < ::Unitsdb::SiDerivedBase
      def prefix_reference=(value)
        return super if value.nil?
        return super if value.is_a?(PrefixReference)

        super(PrefixReference.new(value.to_hash))
      end
    end
  end
end
