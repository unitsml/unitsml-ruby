# frozen_string_literal: true

module Unitsml
  extend self

  UNITSML_NS = "https://schema.unitsml.org/unitsml/1.0"

  def parse(string)
    Unitsml::Parser.new(string).parse
  end

  def register
    @register ||= Lutaml::Model::GlobalRegister.lookup(
      Lutaml::Model::Config.default_register,
    )
  end
end

require "unitsdb"
require "unitsml/error"
require "unitsml/sqrt"
require "unitsml/unit"
require "unitsml/parse"
require "unitsml/parser"
require "unitsml/prefix"
require "unitsml/fenced"
require "unitsml/formula"
require "unitsml/version"
require "unitsml/unitsdb"
require "unitsml/extender"
require "unitsml/dimension"
require "unitsml/transform"
require "unitsml/unitsdb/unit"
require "unitsml/unitsdb/units"
require "unitsml/unitsdb/prefixes"
require "unitsml/unitsdb/dimension"
require "unitsml/unitsdb/dimensions"
require "unitsml/unitsdb/quantities"
require "unitsml/unitsdb/prefix_reference"
require "unitsml/unitsdb/dimension_quantity"

{
  ::Unitsdb::Unit => Unitsml::Unitsdb::Unit,
  ::Unitsdb::Units => Unitsml::Unitsdb::Units,
  ::Unitsdb::Prefixes => Unitsml::Unitsdb::Prefixes,
  ::Unitsdb::Dimension => Unitsml::Unitsdb::Dimension,
  ::Unitsdb::PrefixReference => Unitsml::Unitsdb::PrefixReference,
  ::Unitsdb::DimensionDetails => Unitsml::Unitsdb::DimensionQuantity,
}.each do |key, value|
  Unitsml.register
    .register_global_type_substitution(
      from_type: key,
      to_type: value,
    )
end

Lutaml::Model::Config.xml_adapter_type = RUBY_ENGINE == "opal" ? :oga : :ox
