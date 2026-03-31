# frozen_string_literal: true

require "lutaml/model"
require "unitsdb"

module Unitsml
  extend self

  autoload :Dimension, "unitsml/dimension"
  autoload :Error, "unitsml/error"
  autoload :Extender, "unitsml/extender"
  autoload :Fenced, "unitsml/fenced"
  autoload :FencedNumeric, "unitsml/fenced_numeric"
  autoload :Formula, "unitsml/formula"
  autoload :IntermediateExpRules, "unitsml/intermediate_exp_rules"
  autoload :Model, "unitsml/model"
  autoload :Namespace, "unitsml/namespace"
  autoload :Number, "unitsml/number"
  autoload :Parse, "unitsml/parse"
  autoload :Parser, "unitsml/parser"
  autoload :Prefix, "unitsml/prefix"
  autoload :Sqrt, "unitsml/sqrt"
  autoload :Transform, "unitsml/transform"
  autoload :Unit, "unitsml/unit"
  autoload :Unitsdb, "unitsml/unitsdb"
  autoload :Utility, "unitsml/utility"
  autoload :VERSION, "unitsml/version"

  REGISTER_ID = :unitsml_ruby

  def parse(string)
    Unitsml::Parser.new(string).parse
  end

  def register
    @register ||= Lutaml::Model::GlobalRegister.lookup(REGISTER_ID)
  end

  def register_model(klass, id:)
    register.register_model(klass, id: id)
  end

  def get_class_from_register(class_name)
    register.get_class(class_name)
  end

  def register_type_substitution(from:, to:)
    register.register_global_type_substitution(
      from_type: from,
      to_type: to,
    )
  end
end

Lutaml::Model::GlobalRegister.register(
  Lutaml::Model::Register.new(Unitsml::REGISTER_ID),
)

{
  ::Unitsdb::Unit => Unitsml::Unitsdb::Unit,
  ::Unitsdb::Units => Unitsml::Unitsdb::Units,
  ::Unitsdb::Prefixes => Unitsml::Unitsdb::Prefixes,
  ::Unitsdb::Dimension => Unitsml::Unitsdb::Dimension,
  ::Unitsdb::PrefixReference => Unitsml::Unitsdb::PrefixReference,
  ::Unitsdb::DimensionDetails => Unitsml::Unitsdb::DimensionQuantity,
}.each do |key, value|
  Unitsml.register_type_substitution(from: key, to: value)
end

[
  [Unitsml::Unitsdb::Dimensions, :unitsdb_dimensions],
  [Unitsml::Unitsdb::Prefixes, :unitsdb_prefixes],
  [Unitsml::Unitsdb::Quantities, :unitsdb_quantities],
  [Unitsml::Unitsdb::Units, :unitsdb_units],
].each { |klass, id| Unitsml.register_model(klass, id: id) }

Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = RUBY_ENGINE == "opal" ? :oga : :ox
end

