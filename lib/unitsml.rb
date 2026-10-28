# frozen_string_literal: true

require "lutaml/model"
require "mml"

module Unitsml
  module_function

  autoload :Dimension, "unitsml/dimension"
  autoload :Configuration, "unitsml/configuration"
  autoload :Errors, "unitsml/errors"
  autoload :Extender, "unitsml/extender"
  autoload :Fenced, "unitsml/fenced"
  autoload :FencedNumeric, "unitsml/fenced_numeric"
  autoload :Formula, "unitsml/formula"
  autoload :MathmlHelper, "unitsml/mathml_helper"
  autoload :Model, "unitsml/model"
  autoload :Namespace, "unitsml/namespace"
  autoload :Number, "unitsml/number"
  autoload :Parg, "unitsml/parg"
  autoload :Parser, "unitsml/parser"
  autoload :Prefix, "unitsml/prefix"
  autoload :PrefixAdapter, "unitsml/prefix_adapter"
  autoload :Sqrt, "unitsml/sqrt"
  autoload :Unit, "unitsml/unit"
  autoload :Unitsdb, "unitsml/unitsdb"
  autoload :Utility, "unitsml/utility"
  autoload :VERSION, "unitsml/version"
  autoload :Quantity, "unitsml/quantity"
  autoload :Conversion, "unitsml/conversion"
  autoload :Xml, "unitsml/xml"

  def parse(string)
    Parser.new(string).parse
  end
end
