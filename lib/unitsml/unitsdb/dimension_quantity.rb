# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class DimensionQuantity
      attr_accessor :power_numerator,
                    :symbol,
                    :dim_symbols

      def dim_symbols_ids(hash, dim_id)
        dim_symbols.each { |dim_sym| hash[dim_sym.id] = dim_id }
      end
    end
  end
end
