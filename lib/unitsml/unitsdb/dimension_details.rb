# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class DimensionDetails < ::Unitsdb::DimensionDetails
      def dim_symbols_ids(hash, dim_id)
        symbols&.each { |dim_sym| hash[dim_sym.id] = dim_id }
      end
    end

    Configuration.register_model(DimensionDetails, id: :dimension_details)
  end
end
