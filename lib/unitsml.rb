# frozen_string_literal: true

module Unitsml
  UNITSML_NS = "https://schema.unitsml.org/unitsml/1.0".freeze

  def self.parse(string)
    Unitsml::Parser.new(string).parse
  end
end

require "unitsml/error"
require "unitsml/sqrt"
require "unitsml/unit"
require "unitsml/parse"
require "unitsml/parser"
require "unitsml/prefix"
require "unitsml/formula"
require "unitsml/version"
require "unitsml/unitsdb"
require "unitsml/extender"
require "unitsml/dimension"
require "unitsml/transform"
require "unitsml/unitsdb/units"
require "unitsml/unitsdb/prefixes"
require "unitsml/unitsdb/dimension"
require "unitsml/unitsdb/dimensions"
require "unitsml/unitsdb/quantities"
require "unitsml/unitsdb/dimension_quantity"
require "unitsdb/config"
Unitsdb::Config.models = {
  units: Unitsml::Unitsdb::Units,
  prefixes: Unitsml::Unitsdb::Prefixes,
  dimension: Unitsml::Unitsdb::Dimension,
  dimensions: Unitsml::Unitsdb::Dimensions,
  quantities: Unitsml::Unitsdb::Quantities,
  dimension_quantity: Unitsml::Unitsdb::DimensionQuantity,
}
require "unitsdb"

DEFAULT_XML_ADAPTER = RUBY_ENGINE == "opal" ? :oga :  :ox
Lutaml::Model::Config.xml_adapter_type = DEFAULT_XML_ADAPTER
# TODO: Remove Moxml adapter assignment when Lutaml::Model utilizes Moxml completely
Moxml::Config.default_adapter = DEFAULT_ADAPTER
