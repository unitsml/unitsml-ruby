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
    autoload :Definition, "unitsml/conversion/definition"
    autoload :Register, "unitsml/conversion/register"

    Result = Struct.new(:factor, :offset, keyword_init: true)

    module_function

    # The dispatch walkers mirror the grammar's case structure; the
    # branchiness is inherent and gated by the conformance suite.
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Layout/LineLength, Lint/DuplicateBranch, Lint/ElseLayout

    # Returns a Result for the parsed expression. definitions: an
    # optional hash of unit identifiers (register ids or symbols) to
    # Conversion::Definition (or Float64ConversionFrom model) instances;
    # a definition replaces the canonical factor/offset for its unit so
    # the two paths are never applied in sequence.
    def to_canonical(formula, definitions: nil)
      walk(formula, 1, definitions: definitions)
    end

    REGISTER_KEY = :unitsml_conversion_register

    # Applies a validated caller register (Conversion::Register, or the
    # Array of entries it validates) to every conversion inside the block,
    # including the operand alignment of Quantity#+ and #-. The register is
    # scoped to the block and the current thread; it never persists.
    def with_register(register)
      register = Register.new(register) unless register.is_a?(Register)
      previous = Thread.current[REGISTER_KEY]
      Thread.current[REGISTER_KEY] = register
      yield register
    ensure
      Thread.current[REGISTER_KEY] = previous
    end

    def current_register
      Thread.current[REGISTER_KEY]
    end

    def walk(node, sign, definitions: nil)
      case node
      when Formula
        # The parser already normalizes "/" and "//" by inverting the
        # following exponents (update_units_exponents), so the tree walks
        # multiplicatively with no sign tracking.
        node.value.reduce(Result.new(factor: Rational(1), offset: 0)) do |acc, part|
          next acc if part.is_a?(Extender)

          merge(acc, walk_with_sign(part, sign, definitions: definitions))
        end
      when Fenced
        walk(node.value, sign, definitions: definitions)
      when Sqrt
        sub = walk(node.value, sign, definitions: definitions)
        Result.new(factor: sqrt_rational(sub.factor), offset: sub.offset)
      when Extender
        Result.new(factor: Rational(1), offset: 0)
      when Unit
        unit_result(node, sign, definitions: definitions)
      when Dimension, Number_, Prefix
        Result.new(factor: Rational(1), offset: 0)
      else
        raise Errors::ConversionError, "cannot convert #{node.class} node"
      end
    end

    def walk_with_sign(part, sign, definitions: nil)
      result = walk(part, sign, definitions: definitions)
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

    def unit_result(unit, _sign, definitions: nil)
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

      # A supplied definition replaces the canonical factor/offset for its
      # unit — the two paths are never applied in sequence; when the
      # register also carries canonical data, the two must agree.
      definition = definition_for(record, definitions)
      entry = definition ? nil : current_register&.entry_for(record)
      if entry
        return register_result(entry, power, prefix_factor)
      end

      if power.denominator != 1
        return fractional_unit_result(record, definition, prefix_factor, power)
      end

      if definition
        def_factor, def_offset = definition_result(definition, power, record)
        return Result.new(factor: def_factor * (prefix_factor**power),
                          offset: def_offset)
      end

      # The prefix scales with the unit power: 1 km2 = 1 000 000 m2, not
      # 1 000 m2 — the prefix is as squared as the unit is.
      factor, offset = record_factor(record, power)
      factor *= prefix_factor**power
      Result.new(factor: factor, offset: offset)
    end

    # Resolve the complete ratio before taking a root. The record and prefix
    # factors can have irrational roots individually and a rational root
    # after multiplication (for example, the square root of a milligram).
    def fractional_unit_result(record, definition, prefix_factor, power)
      factor, offset = if definition
                         definition_result(definition, 1, record)
                       else
                         record_factor(record, 1)
                       end
      unless offset.zero?
        raise Errors::ConversionError, "affine unit raised to power #{power}"
      end

      base = factor * prefix_factor
      degree = power.denominator
      numerator = exact_integer_root(base.numerator, degree)
      denominator = exact_integer_root(base.denominator, degree)
      unless numerator && denominator
        raise Errors::InexactPowerError, "#{base} raised to #{power} is not rational"
      end

      Result.new(factor: Rational(numerator, denominator)**power.numerator,
                 offset: offset)
    end

    def exact_integer_root(value, degree)
      return if value.negative? && degree.even?

      magnitude = value.abs
      return value if magnitude <= 1
      return if degree > magnitude.bit_length

      lower = 1
      upper = 1 << ((magnitude.bit_length + degree - 1) / degree)
      root = (lower..upper).bsearch { |candidate| candidate**degree >= magnitude }
      return unless root**degree == magnitude

      value.negative? ? -root : root
    end

    # A caller register entry replaces the canonical factor/offset for its
    # unit, as a definition does. Affine entries (non-zero offset) are legal
    # only at power 1; a fractional power of a register entry is refused
    # rather than approximated.
    def register_result(entry, power, prefix_factor)
      if entry.offset != 0 && power != 1
        raise Errors::ConversionError, "affine unit raised to power #{power}"
      end
      if power.denominator != 1
        raise Errors::InexactPowerError,
              "a register entry at fractional power #{power} is not exact"
      end

      Result.new(factor: (entry.factor**power) * (prefix_factor**power),
                 offset: entry.offset)
    end

    # The definition supplied for this record, if any. Lookup keys are the
    # register ids and symbols of the record.
    def definition_for(record, definitions)
      return nil if definitions.nil? || definitions.empty?

      keys = record.identifiers.to_a.map(&:id) +
        record.symbols.to_a.map(&:id)
      entry = keys.filter_map { |key| definitions[key.to_s] }.first
      return nil if entry.nil?

      case entry
      when Definition then entry
      when Model::Units::Float64ConversionFrom then Definition.new(entry)
      else Definition.from_model(entry)
      end
    end

    # The definition expressed as a canonical SI-anchored Result for the
    # unit carrying it: value_SI = f_i((c / b)^p value - d) - f_i a + o_i,
    # where (f_i, o_i) is the initial unit's canonical Result. Affine
    # definitions (non-zero addends) are legal only at power 1; purely
    # multiplicative definitions power legally.
    def definition_result(definition, power, record)
      a = Rational(definition.model.lexical_decimal(:initial_addend))
      b = Rational(definition.model.lexical_decimal(:multiplicand))
      c = Rational(definition.model.lexical_decimal(:divisor))
      d = Rational(definition.model.lexical_decimal(:final_addend))
      if (a != 0 || d != 0) && power != 1
        raise Errors::ConversionError,
              "affine unit raised to power #{power}"
      end

      factor = (c / b)**power
      offset = a.zero? && d.zero? ? Rational(0) : (-(c / b) * d) - a
      initial = definition.initial_unit_record
      initial_factor, initial_offset = record_factor(initial, 1)
      computed = [initial_factor * factor, (initial_offset * factor) + offset]
      agree!(record, definition, power, computed)
      computed
    end

    # A definition and the register's canonical data describing the same
    # unit must agree; disagreement is a diagnostic, not a silent choice.
    # Both are taken at the same power. Canonical offsets are
    # decimal-truncated register data, so the comparison uses the
    # importer's 1e-9 relative tolerance.
    def agree!(record, definition, power, computed)
      return unless record.canonical_conversion

      factor, offset = record_factor(record, power)
      agreed = [factor, offset].zip(computed).all? do |ours, theirs|
        delta = (ours - theirs).abs
        delta.zero? || delta <= ours.abs / Rational(10**9)
      end
      return if agreed

      raise Errors::ConversionError,
            "conversion definition #{definition.model.id.inspect} " \
            "disagrees with canonical data for " \
            "#{record.symbols&.first&.id.inspect}: canonical " \
            "(#{factor}, #{offset}) vs definition (#{computed[0]}, " \
            "#{computed[1]})"
    end

    # [multiplicative factor, additive offset] for one unit record at the
    # given power. Cyclic derivations (e.g. a unit defined in terms of
    # itself) have no linear canonical conversion and raise.
    def record_identity(record)
      record.identifiers&.map { |i| "#{i.type}:#{i.id}" }&.sort&.join("|")
    end

    # Cycle guard: the derivation chain of one unit (si_derived_bases /
    # root_units) is followed with the path of unit identities already on
    # it. Reaching a unit already on the path is a cyclic definition in the
    # register data (gram-force NISTu196 lists kilo x itself as its root):
    # it has no linear canonical conversion, so it raises ConversionError
    # naming the cycle instead of recursing without bound.
    def guard_cycle!(record, path)
      identity = record_identity(record)
      return path + [identity] unless path.include?(identity)

      cycle = path[path.index(identity)..] + [identity]
      raise Errors::ConversionError,
            "cyclic unit definition in the register data: " \
            "#{cycle.map { |id| unit_label(id) }.join(' -> ')}"
    end

    def unit_label(identity)
      nist = identity.to_s.split("|").find { |part| part.start_with?("nist:") }
      id = nist&.delete_prefix("nist:")
      record = id && Unitsml::Unitsdb.units.find_by_id(id)
      symbol = record && record.symbols.to_a.first&.id
      symbol ? "#{symbol} (#{id})" : identity.to_s
    end

    # Cycle-free results are reused. The key includes the loaded database
    # object, so a reloaded or substituted database never sees stale values;
    # errors (cycles, missing paths) are never cached.
    MEMO_LIMIT = 4096

    def memoized(kind, record, power)
      memo = (@memo ||= {})
      key = [kind, Unitsml::Unitsdb.database.object_id,
             record_identity(record), power]
      return memo[key] if memo.key?(key)

      value = yield
      memo.clear if memo.size >= MEMO_LIMIT
      memo[key] = value.freeze
    end

    def record_factor(record, power, path = [])
      path = guard_cycle!(record, path)
      memoized(:factor, record, power) { record_factor_uncached(record, power, path) }
    end

    def record_factor_uncached(record, power, path)
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
        sub_factor, sub_offset = base_factor(base.unit_reference, base_power,
                                             path)
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

    def base_factor(unit_reference, power, path = [])
      record = Unitsml::Unitsdb.units.find_by_id(unit_reference.id)
      raise Errors::ConversionError, "unknown conversion target" unless record

      record_factor(record, power, path)
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

    # visited: the path of unit identities above this record (an Array; the
    # legacy callers pass []). A revisit is a cyclic definition and raises
    # ConversionError, as record_factor does.
    def unit_dimensions(record, power, visited)
      return nil if record.nil?

      path = guard_cycle!(record, visited)
      memoized(:dimensions, record, power) do
        unit_dimensions_uncached(record, power, path)
      end
    end

    def unit_dimensions_uncached(record, power, visited)
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
