# frozen_string_literal: true

module Unitsml
  # Canonical unit conversion (R-A3): reduces a parsed unit expression to
  # its SI-referenced canonical composition using the unitsdb
  # canonical_conversion data (unitsdb schema 2.1.0), prefix factors and
  # si_derived_bases/root_units chains.
  #
  # Semantics: value_target = value * factor + offset. The additive offset
  # exists only for affine scales (temperature) and is permitted only when
  # the whole expression is that single unit with power 1 — an affine unit
  # inside a composite raises.
  module Conversion
    Result = Struct.new(:factor, :offset, keyword_init: true)

    module_function

    # The dispatch walkers mirror the grammar's case structure; the
    # branchiness is inherent and gated by the conformance suite.
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Layout/LineLength, Lint/DuplicateBranch, Lint/ElseLayout

    # Returns a Result for the parsed expression.
    def to_canonical(formula)
      walk(formula, 1)
    end

    def walk(node, sign)
      case node
      when Formula
        # The parser already normalizes "/" and "//" by inverting the
        # following exponents (update_units_exponents), so the tree walks
        # multiplicatively with no sign tracking.
        node.value.reduce(Result.new(factor: Rational(1), offset: 0)) do |acc, part|
          next acc if part.is_a?(Extender)

          merge(acc, walk_with_sign(part, sign))
        end
      when Fenced
        walk(node.value, sign)
      when Sqrt
        sub = walk(node.value, sign)
        Result.new(factor: sqrt_rational(sub.factor), offset: sub.offset)
      when Extender
        Result.new(factor: Rational(1), offset: 0)
      when Unit
        unit_result(node, sign)
      when Dimension, Number_, Prefix
        Result.new(factor: Rational(1), offset: 0)
      else
        raise Errors::ConversionError, "cannot convert #{node.class} node"
      end
    end

    def walk_inner(node, sign)
      case node
      when Formula
        # The parser already normalizes "/" and "//" by inverting the
        # following exponents (update_units_exponents), so the tree walks
        # multiplicatively with no sign tracking.
        node.value.reduce(Result.new(factor: Rational(1),
                                     offset: 0)) do |acc, part|
          next acc if part.is_a?(Extender)

          merge(acc, walk_with_sign(part, sign))
        end
      when Fenced
        walk(node.value, sign)
      when Sqrt
        sub = walk(node.value, sign)
        Result.new(factor: sqrt_rational(sub.factor), offset: sub.offset)
      when Extender
        Result.new(factor: Rational(1), offset: 0)
      when Unit
        unit_result(node, sign)
      when Dimension, Number_, Prefix
        Result.new(factor: Rational(1), offset: 0)
      else
        raise Errors::ConversionError, "cannot convert #{node.class} node"
      end
    end

    def walk_with_sign(part, sign)
      result = walk(part, sign)
      sign.negative? ? Result.new(factor: 1 / result.factor, offset: 0) : result
    end

    def merge(left, right)
      if (left.offset != 0 && right.factor != 1) || (right.offset != 0 && left.factor != 1)
        raise Errors::ConversionError,
              "affine unit inside a composite expression"
      end

      Result.new(
        factor: left.factor * right.factor,
        offset: left.offset + right.offset,
      )
    end

    def unit_result(unit, _sign)
      prefix_factor = if unit.prefix
                        Rational(unit.prefix.base)**unit.prefix.power
                      else
                        Rational(1)
                      end
      power = node_power(unit.power_numerator)
      record = unit.unit_instance
      unless record
        raise Errors::ConversionError,
              "unknown unit #{unit.unit_name.inspect}"
      end

      # The prefix scales with the unit power: 1 km2 = 1 000 000 m2, not
      # 1 000 m2 — the prefix is as squared as the unit is.
      factor, offset = record_factor(record, power, [record_identity(record)])
      factor *= prefix_factor**power
      Result.new(factor: factor, offset: offset)
    end

    # [multiplicative factor, additive offset] for one unit record at the
    # given power. Cyclic derivations (e.g. a unit defined in terms of
    # itself) have no linear canonical conversion and raise.
    def record_identity(record)
      record.identifiers&.map { |i| "#{i.type}:#{i.id}" }&.sort&.join("|")
    end

    def record_factor(record, power, _visited = [])
      cc = record.canonical_conversion
      return conversion_factor(cc, power) if cc

      bases = record.si_derived_bases
      bases = record.root_units if bases.nil? || bases.empty?
      if bases.nil? || bases.empty?
        system = record.unit_system_reference&.first&.id.to_s
        if Lutaml::Model::Utils.snake_case(system) == "si_base"
          return [Rational(1),
                  Rational(0)]
        end

        raise Errors::ConversionError,
              "no canonical conversion path for #{record.symbols&.first&.id.inspect}"
      end

      factor = Rational(1)
      bases.each do |base|
        base_power = (base.power || 1) * power
        prefix_factor = prefix_factor_from_reference(base.prefix_reference)
        sub_factor, sub_offset = base_factor(base.unit_reference, base_power)
        if sub_offset != 0
          raise Errors::ConversionError,
                "affine unit inside a derived composition"
        end

        # sub_factor already carries base_power (base_factor exponentiates the
        # canonical factor by it); prefix scales with the base power too, so a
        # squared prefixed unit squares its prefix (km2 -> 1 000 000 m2).
        factor *= (prefix_factor**base_power) * sub_factor
      end
      [factor, Rational(0)]
    end

    def conversion_factor(cc, power)
      if cc.offset && cc.offset != "0" && power != 1
        raise Errors::ConversionError, "affine unit raised to power #{power}"
      end

      factor = Rational(cc.factor)**power
      offset = Rational(cc.offset || 0)
      [factor, offset]
    end

    def base_factor(unit_reference, power)
      record = Unitsml::Unitsdb.units.find_by_id(unit_reference.id)
      raise Errors::ConversionError, "unknown conversion target" unless record

      record_factor(record, power)
    end

    def prefix_factor_from_reference(reference)
      return Rational(1) if reference.nil?

      record = Unitsml::Unitsdb.prefixes.find_by_id(reference.id)
      return Rational(1) unless record

      Rational(record.base)**record.power
    end

    def node_power(numerator)
      return 1 if numerator.nil?

      numerator.raw_value.to_s.to_r
    end

    def sqrt_rational(rational)
      root = Integer.sqrt(rational.numerator)
      den = Integer.sqrt(rational.denominator)
      if root * root == rational.numerator && den * den == rational.denominator
        Rational(root, den)
      else
        raise Errors::ConversionError,
              "square root of #{rational} is not rational"
      end
    end

    # Dimension-only decomposition (no factors): the same entry shape
    # Utility.units2dimensions returns, for units that canonical data can
    # reduce but the legacy decomposition cannot. nil when any unit has
    # no path.
    def dimension_entries(formula)
      entries = []
      collect_units(formula.value).each do |unit|
        dims = unit_dimensions(
          unit.unit_instance,
          node_power(unit.power_numerator),
          [],
        )
        return nil if dims.nil?

        entries.concat(dims)
      end
      summed = Hash.new(0)
      symbols = {}
      entries.each do |entry|
        summed[entry[:dimension]] += entry[:exponent]
        symbols[entry[:dimension]] ||= entry[:symbol]
      end
      summed.map do |dimension, exponent|
        { dimension: dimension, symbol: symbols[dimension], exponent: exponent }
      end
    end

    def collect_units(value)
      value.flat_map do |node|
        case node
        when Unit then [node]
        when Formula then collect_units(node.value)
        when Fenced then collect_units([node.value])
        when Sqrt then node.value.is_a?(Unit) ? [node.value] : []
        else []
        end
      end
    end

    def unit_dimensions(record, power, visited)
      return nil if record.nil? || visited.include?(record.object_id)

      visited = visited + [record.object_id]
      sym = record.symbols&.first&.id
      if (u2d = Unitsml::Utility::U2D[sym])
        return [{ dimension: u2d[:dimension], symbol: u2d[:symbol],
                  exponent: power }]
      end

      if (cc = record.canonical_conversion)
        dims = []
        cc.root_units.each do |root|
          target = Unitsml::Unitsdb.units.find_by_id(root.unit_reference.id)
          sub = unit_dimensions(target, (root.power || 1) * power, visited)
          return nil if sub.nil?

          dims.concat(sub)
        end
        return dims
      end

      chains = record.si_derived_bases
      chains = record.root_units if chains.nil? || chains.empty?
      return nil if chains.nil? || chains.empty?

      dims = []
      chains.each do |base|
        target = Unitsml::Unitsdb.units.find_by_id(base.unit_reference.id)
        sub = unit_dimensions(target, (base.power || 1) * power, visited)
        return nil if sub.nil?

        dims.concat(sub)
      end
      dims
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Layout/LineLength, Lint/DuplicateBranch, Lint/ElseLayout
  end
end
