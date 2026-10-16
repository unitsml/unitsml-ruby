# frozen_string_literal: true

require "htmlentities"

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
    DIM2D = {
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

    # XML 1.0 NameChar ranges excluding ASCII and colon. Generated IDs start U_.
    XML_NAME_CHARACTER_RANGES = [
      0xB7..0xB7, 0xC0..0xD6, 0xD8..0xF6, 0xF8..0x37D,
      0x37F..0x1FFF, 0x200C..0x200D, 0x203F..0x2040,
      0x2070..0x218F, 0x2C00..0x2FEF, 0x3001..0xD7FF,
      0xF900..0xFDCF, 0xFDF0..0xFFFD, 0x10000..0xEFFFF
    ].freeze
    ENCODED_UNIT_ID_PREFIX = "EncodedUnit_"

    UNKNOWN = "unknown"
    PREFIX_SYMBOL_METHODS = {
      ASCII: :to_asciimath,
      unicode: :to_unicode,
      LaTeX: :to_latex,
      HTML: :to_html,
    }.freeze

    class << self
      def unit_instance(unit)
        Unitsdb.units.find_by_symbol_id(unit)
      end

      def quantity_instance(id)
        Unitsdb.quantities.find_by_id(id)
      end

      def units2dimensions(units)
        norm = decompose_units_list(units)
        return if norm.any? do |u|
          u.nil? || u[:unit]&.unknown_name? || u[:prefix] == UNKNOWN
        end

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

        dim_hash = dims.to_h { |h| [h[:dimension], h] }
        dims_vector = DIMS_VECTOR.map do |h|
          dim_hash.dig(h, :exponent)
        end.join(":")
        id = Unitsdb.dimensions.find_by_vector(dims_vector)&.id and return id.to_s

        "D_" + dims.map do |d|
          (U2D.dig(d[:unit], :symbol) || DIM2D.dig(d[:id], :symbol)) +
            (to_i_value(d[:exponent]) == 1 ? "" : float_to_display(d[:exponent]))
        end.join
      end

      def to_i_value(object)
        case object
        when Integer, Float then object
        when Number, Fenced then object.to_i
        end
      end

      def decompose_units_list(units)
        gather_units(units.map { |u| decompose_unit(u) }.flatten)
      end

      def decompose_unit(u)
        if u&.unit_name == "g" || Lutaml::Model::Utils.snake_case(u.system_type) == "si_base"
          { unit: u, prefix: u&.prefix }
        elsif u.si_derived_bases.nil? || u.si_derived_bases.empty?
          { unit: Unit.new(UNKNOWN) }
        else
          u.si_derived_bases.each_with_object([]) do |k, object|
            prefix = if k.prefix_reference.nil?
                       u.prefix
                     else
                       combine_prefixes(k.prefix_reference, u.prefix)
                     end
            unit_name = Unitsdb.units.find_by_id(k.unit_reference.id).symbols.first.id
            exponent = (k.power&.to_i || 1) * (u.power_numerator&.to_f || 1)
            object << { prefix: prefix,
                        unit: Unit.new(unit_name, exponent, prefix: prefix) }
          end
        end
      end

      def gather_units(units)
        units.sort_by { |a| a[:unit]&.unit_name }.each_with_object([]) do |k, m|
          if m.empty? || m[-1][:unit]&.unit_name != k[:unit]&.unit_name
            m << k
          else
            m[-1][:unit]&.power_numerator = Number.new(numerator_value(k, m))
            m[-1] = {
              prefix: combine_prefixes(m[-1][:prefix], k[:prefix]),
              unit: m[-1][:unit],
            }
          end
        end
      end

      def numerator_value(unit_hash, unit_array)
        unit_numerator_float(unit_hash) +
          unit_numerator_float(unit_array[-1])
      end

      def unit_numerator_float(object_hash)
        object_hash[:unit]&.power_numerator&.to_f || 1
      end

      def combine_prefixes(p1, p2)
        a1 = PrefixAdapter.wrap(p1)
        a2 = PrefixAdapter.wrap(p2)
        return nil if a1.null? && a2.null?
        return a1.symbolid if a2.null?
        return a2.symbolid if a1.null?
        return UNKNOWN if a1.base != a2.base

        Unitsdb.prefixes_array.each do |prefix_name|
          candidate = PrefixAdapter.from_name(prefix_name)
          return candidate.raw if candidate.base == a1.base &&
            candidate.power == a1.power + a2.power
        end

        UNKNOWN
      end

      def unit(units, formula, dims, norm_text, name, options)
        attributes = {
          id: unit_id(norm_text, quantity_id: formula.explicit_value&.[](:quantity)),
          system: unitsystem(units),
          name: unitname(norm_text, name),
          symbol: unitsymbols(formula, options),
          root_units: rootunits(units),
        }
        attributes[:dimension_url] = "##{dim_id(dims)}" if dims
        xml = Model::Unit.new(
          **attributes,
          lutaml_register: Configuration.context.id,
        ).to_xml
        Xml::Formatter.format_unit(xml)
      end

      def unitname(text, name)
        name ||= unit_en_name(unit_instance(text)) || text
        Model::Units::Name.new(
          name: name,
          lutaml_register: Configuration.context.id,
        )
      end

      def unitsymbols(formula, options)
        %w[HTML MathMl].map do |lang|
          Model::Units::Symbol.new(
            type: lang,
            content: formula.public_send(:"to_#{lang.downcase}", options),
            lutaml_register: Configuration.context.id,
          )
        end
      end

      def unitsystem(units)
        ret = []
        if units.any? { |u| !u.si_system_type? }
          ret << Model::Units::System.new(
            name: "not_SI",
            type: "not_SI",
            lutaml_register: Configuration.context.id,
          )
        end
        if units.any?(&:si_system_type?)
          if units.size == 1
            base = units[0].downcase_system_type == "si_base"
            base = true if units[0].unit_name == "g" && units[0]&.prefix_name == "k"
          end
          ret << Model::Units::System.new(
            name: "SI",
            type: (base ? "SI_base" : "SI_derived"),
            lutaml_register: Configuration.context.id,
          )
        end
        ret
      end

      def dimension(norm_text)
        dim_id = unit_dimension_id(unit_instance(norm_text))
        return unless dim_id

        dim_attrs = { id: dim_id }
        dimid2dimensions(dim_id)&.compact&.each { |u| dimension1(u, dim_attrs) }
        xml = Model::Dimension.new(
          dim_attrs,
          lutaml_register: Configuration.context.id,
        ).to_xml
        xml.force_encoding("UTF-8")
      end

      def dimension1(dim, dims_hash)
        dim_name = dim[:dimension]
        dim_klass = Model::DimensionQuantities.const_get(dim_name)
        dims_hash[underscore(dim_name).to_sym] = dim_klass.new(
          symbol: dim[:symbol],
          power_numerator: float_to_display(dim[:exponent]),
          lutaml_register: Configuration.context.id,
        )
      end

      def float_to_display(float)
        case float
        when Integer, Float
          float.to_f.round(1).to_s.sub(/\.0$/, "")
        when Number, Fenced
          float.float_to_display
        end
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
        uniq_prefixes = xml_root_values(units).filter_map(&:prefix).uniq(&:prefix_name)
        uniq_prefixes.map do |prefix|
          prefix_xml(prefix, options)
        end.join("\n")
      end

      def prefix_xml(prefix, options)
        xml = Model::Prefix.new(
          prefix_attributes(prefix, options),
          lutaml_register: Configuration.context.id,
        ).to_xml
        Xml::Formatter.format_prefix(xml)
      end

      def prefix_attributes(prefix, options)
        adapter = PrefixAdapter.wrap(prefix)
        {
          prefix_base: adapter.base,
          prefix_power: adapter.power,
          id: prefix_id(prefix, adapter),
          name: prefix_name(prefix, adapter),
          symbol: prefix_symbols(prefix, options),
        }
      end

      def prefix_id(prefix, adapter)
        if prefix.is_a?(Unitsml::Prefix)
          prefix.id
        else
          adapter.raw&.identifiers&.find do |i|
            i.type == "nist"
          end&.id
        end
      end

      def prefix_name(prefix, adapter)
        name_value = if prefix.is_a?(Unitsml::Prefix)
                       prefix.name
                     elsif adapter.raw.is_a?(::Unitsdb::Prefix)
                       adapter.raw.names.find { |n| n.lang == "en" }&.value
                     end
        Model::Prefixes::Name.new(
          content: name_value,
          lutaml_register: Configuration.context.id,
        )
      end

      def prefix_symbols(prefix, options)
        adapter = PrefixAdapter.wrap(prefix)
        PREFIX_SYMBOL_METHODS.map do |type, method_name|
          Model::Prefixes::Symbol.new(
            type: type,
            content: adapter.raw&.public_send(method_name, options),
            lutaml_register: Configuration.context.id,
          )
        end
      end

      def rootunits(units)
        return if units.size == 1 && !units[0].prefix

        enum_root_units = xml_root_values(units).map do |unit|
          attributes = { unit: unit.unit_instance.short }
          attributes[:prefix] = unit.prefix_name if unit.prefix
          attributes.merge!(xml_root_power(unit.power_numerator))
          Model::Units::EnumeratedRootUnit.new(
            **attributes,
            lutaml_register: Configuration.context.id,
          )
        end
        Model::Units::RootUnits.new(
          enumerated_root_unit: enum_root_units,
          lutaml_register: Configuration.context.id,
        )
      end

      def xml_root_values(units)
        return units if units.size == 1 && !units.first.prefix

        units.flat_map do |unit|
          next unit if unit.prefix

          record = unit.unit_instance
          next unit unless record&.prefixed

          roots = record.root_units
          if roots.nil? || roots.empty?
            next unit if record.root

            raise ArgumentError, "Registered prefixed unit #{unit.unit_name} has no roots"
          end

          roots.map { |root| xml_root_unit(root, unit) }
        end
      end

      def xml_root_unit(root, unit)
        base = Unitsdb.units.find_by_id(root.unit_reference.id)
        prefix = PrefixAdapter.wrap(root.prefix_reference).prefix_name
        unless base && (!root.prefix_reference || prefix)
          raise ArgumentError, "Unresolved root for #{unit.unit_name}"
        end

        power = unit.power_numerator
        if root.power && root.power != 1
          exponent = (power ? xml_power_value(power) : 1) * Rational(root.power.to_s)
          power = Number.new(exponent.to_s)
        end
        Unit.new(base.symbols.first.id, power,
                 prefix: prefix && Prefix.new(prefix))
      end

      def xml_root_power(power)
        return {} unless power

        exponent = xml_power_value(power)
        unless (-128..127).cover?(exponent.numerator) &&
            (1..127).cover?(exponent.denominator)
          raise RangeError, "Root-unit exponent #{power.raw_value} exceeds " \
                            "the UnitsML numerator/denominator bounds"
        end

        attributes = { power_numerator: exponent.numerator.to_s }
        if exponent.denominator != 1
          attributes[:power_denominator] = exponent.denominator.to_s
        end
        attributes
      end

      def xml_power_value(power)
        Rational(power.raw_value.gsub("//", "/"))
      end

      def unit_id(text, quantity_id: nil)
        text = text&.gsub(/[()]/, "")
        unit = unit_instance(text)
        id = format_unit_id(unit, text)
        return unless id

        xml_unit_id("U_#{id}", quantity_id)
      end

      def xml_unit_id(id, quantity_id)
        valid = id.each_char.all? do |character|
          /[A-Za-z0-9_.-]/.match?(character) ||
            XML_NAME_CHARACTER_RANGES.any? { |range| range.cover?(character.ord) }
        end
        return id if valid

        # Normal completed Unit IDs always start U_; encoding is disjoint.
        hex = id.bytes.map { |byte| byte.to_s(16).rjust(2, "0") }.join
        encoded = "#{ENCODED_UNIT_ID_PREFIX}#{hex}"
        records = Unitsdb.prefixes.prefixes + Unitsdb.dimensions.dimensions +
          Unitsdb.quantities.quantities
        collision = records.any? do |record|
          record.identifiers.any? { |identifier| identifier.id == encoded }
        end
        if encoded == quantity_id || collision
          raise ArgumentError, "Encoded unit ID #{encoded} collides with a peer ID"
        end

        encoded
      end

      private :xml_root_values, :xml_root_unit, :xml_root_power,
              :xml_power_value, :xml_unit_id

      def format_unit_id(unit, text)
        return unit_nist_id(unit)&.gsub("'", "_") if unit

        text&.gsub("*", ".")&.gsub("^", "")
      end

      def dimension_components(dims)
        return if dims.nil? || dims.empty?

        dim_attrs = { id: dim_id(dims) }
        dims.map { |u| dimension1(u, dim_attrs) }
        xml = Model::Dimension.new(
          **dim_attrs,
          lutaml_register: Configuration.context.id,
        ).to_xml
        xml.force_encoding("UTF-8")
      end

      def quantity(normtext, instance)
        unit = unit_instance(normtext)
        return unless unit_or_quantity(unit, instance)

        model_quantity_xml(
          instance || unit.quantity_references&.first&.id,
          "##{unit_dimension_id(unit)}",
        )
      end

      def unit_nist_id(unit)
        return unless unit
        return unit.nist_id if unit.is_a?(Unitsml::Unitsdb::Unit)

        unit.identifiers&.find { |identifier| identifier.type == "nist" }&.id
      end

      def unit_en_name(unit)
        return unless unit
        return unit.en_name if unit.is_a?(Unitsml::Unitsdb::Unit)

        unit.names&.find { |name| name.lang == "en" }&.value
      end

      def unit_dimension_id(unit)
        return unless unit
        return unit.dimension_url if unit.is_a?(Unitsml::Unitsdb::Unit)

        unit.dimension_reference&.id ||
          quantity_dimension_id(quantity_instance(unit.quantity_references&.first&.id))
      end

      def quantity_dimension_id(quantity)
        quantity&.dimension_reference&.id
      end

      def unit_or_quantity(unit, quantity)
        (unit && unit.quantity_references.size == 1) ||
          quantity_instance(quantity)
      end

      def model_quantity_xml(id, url)
        xml = Model::Quantity.new(
          id: id,
          name: quantity_name(id),
          dimension_url: url,
          lutaml_register: Configuration.context.id,
        ).to_xml
        xml.force_encoding("UTF-8")
      end

      def quantity_name(id)
        quantity_instance(id)&.names&.filter_map do |name|
          next unless name.lang == "en"

          Model::Quantities::Name.new(content: name.value,
                                      lutaml_register: Configuration.context.id)
        end
      end

      def string_to_html_entity(string)
        HTMLEntities.new.encode(
          string.frozen? ? string : string.force_encoding("UTF-8"),
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
