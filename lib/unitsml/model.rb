# frozen_string_literal: true

module Unitsml
  module Model
    autoload :Dimension, "#{__dir__}/model/dimension"
    autoload :DimensionQuantities, "#{__dir__}/model/dimension_quantities"
    autoload :Namespace, "#{__dir__}/model/namespace"
    autoload :Prefix, "#{__dir__}/model/prefix"
    autoload :Prefixes, "#{__dir__}/model/prefixes"
    autoload :Quantities, "#{__dir__}/model/quantities"
    autoload :Quantity, "#{__dir__}/model/quantity"
    autoload :Unit, "#{__dir__}/model/unit"
    autoload :Units, "#{__dir__}/model/units"
  end
end
