# frozen_string_literal: true

module Unitsml
  module Unitsdb
    autoload :Unit, "#{__dir__}/unitsdb/unit"
    autoload :Units, "#{__dir__}/unitsdb/units"
    autoload :Prefixes, "#{__dir__}/unitsdb/prefixes"
    autoload :Dimension, "#{__dir__}/unitsdb/dimension"
    autoload :Dimensions, "#{__dir__}/unitsdb/dimensions"
    autoload :Quantities, "#{__dir__}/unitsdb/quantities"
    autoload :PrefixReference, "#{__dir__}/unitsdb/prefix_reference"
    autoload :DimensionQuantity, "#{__dir__}/unitsdb/dimension_quantity"

    class << self
      def units
        Units.new(units: ::Unitsdb.database.units)
      end

      def prefixes
        Prefixes.new(prefixes: ::Unitsdb.database.prefixes)
      end

      def dimensions
        Dimensions.new(dimensions: ::Unitsdb.database.dimensions)
      end

      def quantities
        Quantities.new(quantities: ::Unitsdb.database.quantities)
      end

      def prefixes_array
        @prefixes_array ||= prefixes.ascii_symbols.sort_by(&:length)
      end

      def prefixes_by_size(size)
        @sized_prefixes ||= {}
        return @sized_prefixes[size] if @sized_prefixes.key?(size)

        @sized_prefixes[size] = prefixes_array.select { |p| p.size == size }
      end
    end
  end
end
