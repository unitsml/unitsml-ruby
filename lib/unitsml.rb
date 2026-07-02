# frozen_string_literal: true

require "lutaml/model"
require "mml"

module Unitsml
  module_function

  autoload :Compose, "unitsml/compose"
  autoload :Dimension, "unitsml/dimension"
  autoload :Configuration, "unitsml/configuration"
  autoload :Errors, "unitsml/errors"
  autoload :Extender, "unitsml/extender"
  autoload :Fenced, "unitsml/fenced"
  autoload :FencedNumeric, "unitsml/fenced_numeric"
  autoload :Formula, "unitsml/formula"
  autoload :IntermediateExpRules, "unitsml/intermediate_exp_rules"
  autoload :MathmlHelper, "unitsml/mathml_helper"
  autoload :Model, "unitsml/model"
  autoload :Namespace, "unitsml/namespace"
  autoload :Number, "unitsml/number"
  autoload :Parse, "unitsml/parse"
  autoload :Parser, "unitsml/parser"
  autoload :Prefix, "unitsml/prefix"
  autoload :PrefixAdapter, "unitsml/prefix_adapter"
  autoload :Sqrt, "unitsml/sqrt"
  autoload :Transform, "unitsml/transform"
  autoload :Unit, "unitsml/unit"
  autoload :Unitsdb, "unitsml/unitsdb"
  autoload :Utility, "unitsml/utility"
  autoload :VERSION, "unitsml/version"
  autoload :Xml, "unitsml/xml"

  def parse(string)
    Unitsml::Parser.new(string).parse
  end

  def compose(units: nil, dimensions: nil,
              quantity: nil, name: nil, multiplier: nil)
    Unitsml::Compose::Composite.new(
      units: units, dimensions: dimensions,
      quantity: quantity, name: name, multiplier: multiplier
    ).to_formula
  end
end
