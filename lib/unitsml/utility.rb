# frozen_string_literal: true

require "unitsml/model/unit"
require "unitsml/model/prefix"
require "unitsml/model/quantity"
require "unitsml/model/dimension"

module Unitsml
  module Utility
    # Unit to dimension
    U2D = {
      "m" => { dimension: "Length", order: 1, symbol: "L" },
      "g" => { dimension: "Mass", order: 2, symbol: "M" },
      "kg" => { dimension: "Mass", order: 2, symbol: "M" },
      "s" => { dimension: "Time", order: 3, symbol: "T" },
      "A" => { dimension: "ElectricCurrent", order: 4, symbol: "I" },
      "K" => { dimension: "ThermodynamicTemperature", order: 5,
               symbol: "Theta" },
      "degK" => { dimension: "ThermodynamicTemperature", order: 5,
                  symbol: "Theta" },
      "mol" => { dimension: "AmountOfSubstance", order: 6, symbol: "N" },
      "cd" => { dimension: "LuminousIntensity", order: 7, symbol: "J" },
      "deg" => { dimension: "PlaneAngle", order: 8, symbol: "phi" },
    }.freeze
    # Dimesion for dim_(dimesion) input
    Dim2D = {
      "dim_L" => U2D["m"],
      "dim_M" => U2D["g"],
      "dim_T" => U2D["s"],
      "dim_I" => U2D["A"],
      "dim_Theta" => U2D["K"],
      "dim_N" => U2D["mol"],
      "dim_J" => U2D["cd"],
      "dim_phi" => U2D["deg"],
    }.freeze
    DIMS_VECTOR = %w[
      ThermodynamicTemperature
      AmountOfSubstance
      LuminousIntensity
      ElectricCurrent
      PlaneAngle
      Length
      Mass
      Time
    ].freeze

    class << self
      def unit_instance(unit)
        Unitsdb.units.find_by_symbol_id(unit)
      end

      def quantity_instance(id)
        Unitsdb.quantities.find_by_id(id)
      end

      def units2dimensions(units)
        norm = decompose_units_list(units)
        return if norm.any? { |u| u.nil? || u[:unit].unit_name == "unknown" || u[:prefix] == "unknown" }

        norm.map do |u|
          unit_name = u[:unit].unit_name
          {
            dimension: U2D[unit_name][:dimension],
            unit: unit_name,
            exponent: u[:unit].power_numerator || 1,
            symbol: U2D[unit_name][:symbol],
          }
        end.sort { |a, b| U2D[a[:unit]][:order] <=> U2D[b[:unit]][:order] }
      end

      def dim_id(dims)
        return nil if dims.nil? || dims.empty?

        dim_hash = dims.each_with_object({}) { |h, m| m[h[:dimension]] = h }
        dims_vector = DIMS_VECTOR.map { |h| dim_hash.dig(h, :exponent) }.join(":")
        id = Unitsdb.dimensions.find_by_vector(dims_vector)&.id and return id.to_s

        "D_" + dims.map do |d|
          (U2D.dig(d[:unit], :symbol) || Dim2D.dig(d[:id], :symbol)) +
            (d[:exponent] == 1 ? "" : float_to_display(d[:exponent]))
        end.join("")
      end

      def decompose_units_list(units)
        gather_units(units.map { |u| decompose_unit(u) }.flatten)
      end

      def decompose_unit(u)
        if u&.unit_name == "g" || Lutaml::Model::Utils.snake_case(u.system_type) == "si_base"
          { unit: u, prefix: u&.prefix }
        elsif u.si_derived_bases.nil? || u.si_derived_bases.empty?
          { unit: Unit.new("unknown") }
        else
          u.si_derived_bases.each_with_object([]) do |k, object|
            prefix = if !k.prefix_reference.nil?
                       combine_prefixes(prefix_object(k.prefix_reference), u.prefix)
                     else
                       u.prefix
                     end
            unit_name = Unitsdb.units.find_by_id(k.unit_reference.id).symbols.first.id
            exponent = (k.power&.to_i || 1) * (u.power_numerator&.to_f || 1)
            object << { prefix: prefix,
                   unit: Unit.new(unit_name, exponent, prefix: prefix),
                 }
          end
        end
      end

      def gather_units(units)
        units.sort_by { |a| a[:unit]&.unit_name }.each_with_object([]) do |k, m|
          if m.empty? || m[-1][:unit]&.unit_name != k[:unit]&.unit_name
            m << k
          else
            m[-1][:unit]&.power_numerator = (k[:unit]&.power_numerator&.to_f || 1) + (m[-1][:unit]&.power_numerator&.to_f || 1)
            m[-1] = {
              prefix: combine_prefixes(prefix_object(m[-1][:prefix]), prefix_object(k[:prefix])),
              unit: m[-1][:unit],
            }
          end
        end
      end

      def prefix_object(prefix)
        return prefix unless prefix.is_a?(String)
        return nil unless Unitsdb.prefixes_array.any?(prefix)

        Prefix.new(prefix)
      end

      def combine_prefixes(p1, p2)
        return nil if p1.nil? && p2.nil?
        return p1.symbolid if p2.nil?
        return p2.symbolid if p1.nil?
        return "unknown" if p1.base != p2.base

        Unitsdb.prefixes_array.each do |prefix_name|
          p = prefix_object(prefix_name)
          return p if p.base == p1.base && p.power == p1.power + p2.power
        end

        "unknown"
      end

      def unit(units, formula, dims, norm_text, name, options)
        attributes = {
          id: unit_id(norm_text),
          system: unitsystem(units),
          name: unitname(norm_text, name),
          symbol: unitsymbols(formula, options),
          root_units: rootunits(units),
        }
        attributes[:dimension_url] = "##{dim_id(dims)}" if dims
        Model::Unit.new(attributes).to_xml
          .gsub("&lt;", "<")
          .gsub("&gt;", ">")
          .gsub("&amp;", "&")
          .gsub(/−/, "&#x2212;")
          .gsub(/⋅/, "&#x22c5;")
      end

      def unitname(text, name)
        name ||= unit_instance(text)&.en_name || text
        Model::Units::Name.new(name: name)
      end

      def unitsymbols(formula, options)
        %w[HTML MathMl].map do |lang|
          Model::Units::Symbol.new(
            type: lang,
            content: formula.public_send(:"to_#{lang.downcase}", options),
          )
        end
      end

      def unitsystem(units)
        ret = []
        if units.any? { |u| !u.si_system_type? }
          ret << Model::Units::System.new(name: "not_SI", type: "not_SI")
        end
        if units.any?(&:si_system_type?)
          if units.size == 1
            base = units[0].downcase_system_type == "si_base"
            base = true if units[0].unit_name == "g" && units[0]&.prefix_name == "k"
          end
          ret << Model::Units::System.new(name: "SI", type: (base ? 'SI_base' : 'SI_derived'))
        end
        ret
      end

      def dimension(norm_text)
        dim_id = unit_instance(norm_text)&.dimension_url
        return unless dim_id

        dim_attrs = { id: dim_id }
        dimid2dimensions(dim_id)&.compact&.each { |u| dimension1(u, dim_attrs) }
        Model::Dimension.new(dim_attrs).to_xml
      end

      def dimension1(dim, dims_hash)
        dim_name = dim[:dimension]
        dim_klass = Model::DimensionQuantities.const_get(dim_name)
        dims_hash[underscore(dim_name).to_sym] = dim_klass.new(
          symbol: dim[:symbol],
          power_numerator: float_to_display(dim[:exponent])
        )
      end

      def float_to_display(float)
        float.to_f.round(1).to_s.sub(/\.0$/, "")
      end

      def dimid2dimensions(normtext)
        dims = Unitsdb.dimensions.find_by_id(normtext)
        dims&.processed_keys&.map do |processed_key|
          humanized = processed_key.split("_").map(&:capitalize).join
          next unless DIMS_VECTOR.include?(humanized)

          dim_quantity = dims.public_send(processed_key)
          {
            dimension: humanized,
            symbol: dim_quantity.symbol,
            exponent: dim_quantity.power,
          }
        end
      end

      def prefixes(units, options)
        uniq_prefixes = units.map { |unit| unit.prefix }.compact.uniq { |d| d.prefix_name }
        uniq_prefixes.map do |prefix|
          prefix_attrs = { prefix_base: prefix&.base, prefix_power: prefix&.power, id: prefix&.id }
          type_and_methods = { ASCII: :to_asciimath, unicode: :to_unicode, LaTeX: :to_latex, HTML: :to_html }
          prefix_attrs[:name] = Model::Prefixes::Name.new(content: prefix&.name)
          prefix_attrs[:symbol] = type_and_methods.map do |type, method_name|
            Model::Prefixes::Symbol.new(
              type: type,
              content: prefix&.public_send(method_name, options),
            )
          end
          Model::Prefix.new(prefix_attrs).to_xml.gsub("&amp;", "&")
        end.join("\n")
      end

      def rootunits(units)
        return if units.size == 1 && !units[0].prefix

        enum_root_units = units.map do |unit|
          attributes = { unit: unit.enumerated_name }
          attributes[:prefix] = unit.prefix_name if unit.prefix
          unit.power_numerator && unit.power_numerator != "1" and
            attributes[:power_numerator] = unit.power_numerator
          Model::Units::EnumeratedRootUnit.new(attributes)
        end
        Model::Units::RootUnits.new(enumerated_root_unit: enum_root_units)
      end

      def unit_id(text)
        text = text&.gsub(/[()]/, "")
        unit = unit_instance(text)

        "U_#{unit ? unit.nist_id&.gsub(/'/, '_') : text&.gsub(/\*/, '.')&.gsub(/\^/, '')}"
      end

      def dimension_components(dims)
        return if dims.nil? || dims.empty?

        dim_attrs = { id: dim_id(dims) }
        dims.map { |u| dimension1(u, dim_attrs) }
        Model::Dimension.new(dim_attrs).to_xml
      end

      def quantity(normtext, quantity)
        unit = unit_instance(normtext)
        return unless unit && unit.quantity_references.size == 1 ||
          quantity_instance(quantity)

        id = (quantity || unit.quantity_references&.first&.id)
        Model::Quantity.new(
          id: id,
          name: quantity_name(id),
          dimension_url: "##{unit.dimension_url}",
        ).to_xml
      end

      def quantity_name(id)
        quantity_instance(id)&.names&.filter_map do |name|
          next unless name.lang == "en"

          Model::Quantities::Name.new(content: name.value)
        end
      end

      def string_to_html_entity(string)
        HTMLEntities.new.encode(
          string.frozen? ? string : string.force_encoding('UTF-8'),
          :hexadecimal,
        )
      end

      def html_entity_to_unicode(string)
        HTMLEntities.new.decode(string)
      end

      def underscore(str)
        str.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      def set_to_fence(set)
        return set if set.is_a?(Fenced)

        Fenced.new("(", set, ")")
      end
    end
  end
end
