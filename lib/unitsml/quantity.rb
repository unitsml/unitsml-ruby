# frozen_string_literal: true

module Unitsml
  # A quantity: a magnitude plus a unit identity, with unit-aware
  # arithmetic (unitsml-ruby#82 R-A1/A2/A4-skeleton/A5).
  #
  # Dimensions come from the parsed unit expression via UnitsDB; every
  # operation checks them. Scale legality (R-A4) gates multiplication
  # and division on non-ratio scales; the classification is pluggable
  # per quantity until the unitsdb scale-legality data lands (#130).
  class Quantity
    attr_reader :value, :formula, :scale, :kind

    # Distinguishes an omitted unit keyword from an explicit nil.
    ABSENT = Object.new.freeze
    private_constant :ABSENT

    # unit: accepts a String (parsed, like unit_expression:), a Unit, a
    # Formula (kept as-is, never reparsed) or nil (a pure number).
    # unit_expression: remains the String-only spelling; give only one.
    # kind: an optional data-declared quantity kind (a UnitsDB quantity
    # identifier or name, a QuantityKind, or :primary for the primary
    # quantity of a single unit). Untyped quantities (kind nil) keep the
    # dimension-only gating.
    def initialize(value:, unit: ABSENT, unit_expression: ABSENT,
                   scale: nil, kind: nil)
      unless unit.equal?(ABSENT) || unit_expression.equal?(ABSENT)
        raise ArgumentError, "give only one of unit: or unit_expression:"
      end

      @value = value
      @formula = build_formula(unit.equal?(ABSENT) ? unit_expression : unit)
      # The scale derives from the unitsdb scale_reference of the units in
      # the expression (degC is continuous_interval); an explicit argument
      # (the :difference typing of subtraction) overrides it.
      @scale = (scale || derived_scale).to_sym
      @kind = resolve_kind(kind)
    end

    # Canonical dimension identity; "1" (dimensionless) for pure numbers.
    def dimension_id
      @dimension_id ||= begin
        list = dimension_list
        # A fractional vector (m^(1/2)) has no unitsdb dimension identity;
        # none is asserted for it.
        if list && !fractional_vector?
          Utility.dim_id(list) || "1"
        end
      end
    end

    # rubocop:disable Metrics/AbcSize, Layout/LineLength
    # Base-dimension exponents summed across the composed expression —
    # V (L²MT⁻³I⁻¹) times A (I¹) merges to the watt vector L²MT⁻³.
    def dimension_vector
      # sqrt subtrees are not admitted: the parser overwrites the leaf
      # exponents under a sqrt with 0.5 (sqrt(m) and sqrt(m^2) yield the
      # same tree) and leaves composite radicands unhalved, so the tree
      # does not determine the vector (#82 roots, deferred).
      return nil if formula && sqrt_tree?(formula.value)
      return fractional_dimension_vector if fractional_leaves?

      list = raw_dimension_list
      return nil if list.nil?

      vector = list.each_with_object(Hash.new(0)) do |entry, acc|
        exponent = entry[:exponent]
        exponent = exponent.raw_value if exponent.respond_to?(:raw_value)
        acc[entry[:dimension]] += exponent.to_i
      end
      vector.delete_if { |_, exponent| exponent.zero? }
      vector
    end

    # Normalized unit expression text; the value's to_s for pure numbers.
    def norm_text
      formula&.norm_text || value.to_s
    end

    # Units compose structurally through Compose::Builder (the same engine
    # as Unit#* and Unit#/); nothing is reparsed from text. A Numeric is a
    # scalar; a bare Unit, Dimension or Formula operand is a magnitude-1
    # Quantity (Compose.quantity_operand).
    def *(other)
      return scalar_product(other) if Compose.type?(Numeric, other)

      other = Compose.quantity_operand(other)
      scale_ratio_gate!(other, "multiplication")
      Quantity.new(value: value * other.value,
                   unit: compose(formula, other.formula, "*"))
    end

    # rubocop:disable-next Metrics/AbcSize
    def /(other)
      if Compose.type?(Numeric, other)
        gate_zero!(other)
        gate_scaling!
        # scaling keeps the scale typing: a scaled difference stays a
        # difference (gate_scaling! admits only ratio and difference)
        return Quantity.new(value: exact_quotient(value, other),
                            unit: copied_formula, scale: scale, kind: kind)
      end

      other = Compose.quantity_operand(other)
      scale_ratio_gate!(other, "division")
      if other.value.zero?
        raise Errors::IndeterminateResultError,
              "division by a zero quantity is indeterminate"
      end

      Quantity.new(value: exact_quotient(value, other.value),
                   unit: compose(formula, other.formula, "/"))
    end

    # R-A4: differences are legal on both ratio and interval scales;
    # only the dimension identity must match. An operand in another unit
    # is first converted into this quantity's unit with convert_to (exact;
    # a difference operand skips the affine addends): 1 km + 1 m is
    # 1001/1000 km, not 2 km.
    def +(other)
      quantity_kind!(other)
      gate_dimension!(other)
      # differences sum to a difference (5 K + 5 K of difference converts
      # to 10 K, never 283.15 K)
      both_differences = [scale, other.scale].all?(:difference)
      sum_scale = both_differences ? :difference : nil
      Quantity.new(value: value + aligned_value(other), unit: copied_formula,
                   scale: sum_scale, kind: kind || other.kind)
    end

    def -(other)
      quantity_kind!(other)
      gate_dimension!(other)
      # A difference of two quantities is difference-typed: its conversion
      # skips the affine addends (20 degC - 15 degC converts to 5 K, not
      # 278.15 K). Subtracting a difference from an absolute value shifts
      # that value and keeps its scale (20 degC - 5 K of difference is
      # 15 degC, which converts to 288.15 K).
      result_scale = if other.scale == :difference && scale != :difference
                       scale
                     else
                       :difference
                     end
      Quantity.new(value: value - aligned_value(other), unit: copied_formula,
                   scale: result_scale, kind: kind || other.kind)
    end

    # R-A3: convert this quantity to another (dimension-compatible) unit
    # using unitsdb canonical_conversion data, or conversion definitions
    # supplied by the caller (definitions: a hash of unit ids/symbols to
    # Conversion::Definition or Float64ConversionFrom instances) where
    # given. Exact rational arithmetic throughout; the returned value is
    # a Rational when a conversion was applied.
    def convert_to(target_expression, definitions: nil)
      target_formula = if target_expression.is_a?(Formula)
                         target_expression
                       else
                         Unitsml.parse(target_expression)
                       end
      gate_target = Quantity.new(value: 0,
                                 unit_expression: target_formula.norm_text)
      gate_dimension!(gate_target)

      src = Conversion.to_canonical(formula, definitions: definitions)
      dst = Conversion.to_canonical(target_formula, definitions: definitions)
      converted = if scale == :difference
                    # differences carry no affine addends
                    (Rational(value) * src.factor) / dst.factor
                  else
                    ((Rational(value) * src.factor) + src.offset - dst.offset) / dst.factor
                  end

      # a converted difference is still a difference
      Quantity.new(value: converted, unit_expression: target_formula.norm_text,
                   scale: scale == :difference ? :difference : nil,
                   kind: kind)
    end

    def ==(other)
      other.is_a?(Quantity) && value == other.value &&
        dimension_vector == other.dimension_vector && kinds_compatible?(other)
    end

    # The primary quantity of this quantity's unit, selected by the UnitsDB
    # primary flag (never positional order); nil for pure numbers and
    # composite expressions, which name no single unit record.
    def primary_kind
      record = single_unit_record
      record && QuantityKind.primary_for(record)
    end
    # rubocop:enable Metrics/AbcSize, Layout/LineLength

    private

    # The other operand's magnitude in this quantity's unit. Same-unit and
    # pure-number operands are taken as-is (no conversion, value types
    # kept); otherwise convert_to applies the exact canonical conversion.
    def aligned_value(other)
      return other.value if formula.nil? || other.formula.nil?
      return other.value if formula.norm_text == other.formula.norm_text

      other.convert_to(formula).value
    end

    # Integer / Integer is exact (1 m / 2 is 1/2 m, not 0 m); an exact
    # integral quotient stays an Integer. Other numerics divide natively.
    def exact_quotient(dividend, divisor)
      unless dividend.is_a?(Integer) && divisor.is_a?(Integer)
        return dividend / divisor
      end

      quotient = Rational(dividend, divisor)
      quotient.denominator == 1 ? quotient.numerator : quotient
    end

    def sqrt_tree?(nodes)
      Array(nodes).any? do |node|
        case node
        when Sqrt then true
        when Formula then sqrt_tree?(node.value)
        when Fenced then sqrt_tree?([node.value])
        else false
        end
      end
    end

    def leaf_units(nodes)
      Array(nodes).flat_map do |node|
        case node
        when Unit then [node]
        when Formula then leaf_units(node.value)
        when Fenced then leaf_units([node.value])
        else []
        end
      end
    end

    # Exact exponent of a parsed power ("1/2", "(1/2)", "-1"): an Integer
    # when integral, otherwise a Rational.
    def exact_exponent(power)
      return 1 if power.nil?

      power = power.value while power.is_a?(Fenced)
      power = power.raw_value if power.respond_to?(:raw_value)
      exact = case power
              when Integer, Rational then Rational(power)
              when Float then Rational(power.to_s)
              else Rational(power.to_s.delete("() "))
              end
      exact.denominator == 1 ? exact.numerator : exact
    rescue ArgumentError, ZeroDivisionError
      raise Errors::InvalidPowerError.new(value: power, reason: :invalid_number)
    end

    def fractional_leaves?
      return false unless formula

      leaf_units(formula.value).any? do |unit|
        exact_exponent(unit.power_numerator).is_a?(Rational)
      end
    end

    def fractional_vector?
      dimension_vector&.values&.any?(Rational) || false
    end

    # Fractional leaf powers (m^(1/2), J^(1/2)) scale each leaf's exact
    # unitsdb decomposition; nil when any leaf has no decomposition path.
    def fractional_dimension_vector
      vector = Hash.new(0)
      leaf_units(formula.value).each do |unit|
        dims = Conversion.unit_dimensions(
          unit.unit_instance, exact_exponent(unit.power_numerator), []
        )
        return nil if dims.nil?

        dims.each { |entry| vector[entry[:dimension]] += entry[:exponent] }
      end
      vector.transform_values! do |exponent|
        exponent = Rational(exponent)
        exponent.denominator == 1 ? exponent.numerator : exponent
      end
      vector.delete_if { |_, exponent| exponent.zero? }
      vector
    end

    # The scale of a quantity is the scale of the units it composes: any
    # interval-scaled unit (degC per unitsdb scale_reference) makes the
    # quantity interval-scaled.
    def derived_scale
      interval_units? ? :interval : :ratio
    end

    def interval_units?
      return false unless formula

      extract_units(formula.value).any? { |unit| unit_interval?(unit) }
    end

    def unit_interval?(unit)
      record = unit.unit_instance
      record&.scale_reference&.id.to_s.include?("interval")
    end

    # Base dimensions in canonical DIMS_VECTOR order; nil when all
    # exponents cancel (dimensionless).
    def dimension_list
      return nil if dimension_vector.nil?

      merged = Utility::DIMS_VECTOR.filter_map do |dimension|
        exponent = dimension_vector[dimension]
        next if exponent.zero?

        { dimension: dimension, exponent: exponent }
      end
      merged.empty? ? nil : merged
    end

    def raw_dimension_list
      return [] unless formula

      Utility.units2dimensions(extract_units(formula.value)) ||
        Conversion.dimension_entries(formula)
    end

    # Formula#units renders XML; the dimension identity needs the raw
    # decomposition, so extract it the same way Formula does internally.
    # rubocop:disable-next Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
    def extract_units(formula)
      formula.each_with_object([]) do |term, units_arr|
        case term
        when Unit
          units_arr << term.dup
        when Formula
          units_arr.concat(extract_units(term.value.dup))
        when Sqrt
          next unless term.value.is_a?(Unit)

          sqrt_unit = term.value.dup
          sqrt_unit.power_numerator = Number.new("0.5")
          units_arr << sqrt_unit
        when Fenced
          units_arr.concat(extract_units(term.value.value.dup))
        end
      end
    end

    # R-A4: ratio-scale operations are specified errors on non-ratio
    # quantities. Differences and comparisons remain legal on both.
    # Scalar multiplication/division scales the magnitude: legal on
    # ratio scales, a specified error on non-ratio ones.
    def gate_scaling!
      # A difference of interval-scaled values is ratio-scaled: scaling a
      # difference is meaningful (2 x 5 K = 10 K of difference); scaling an
      # absolute interval value is not.
      return if %i[ratio difference].include?(scale)

      raise Errors::ScaleOperationError,
            "scaling is not legal on a #{scale} scale quantity"
    end

    def scale_ratio_gate!(other, operation)
      # Only absolute interval-scaled values are barred from * and /: a
      # difference is ratio-scaled (scaling or dividing it is meaningful),
      # so difference/ratio combinations compose freely.
      return if scale != :interval && other.scale != :interval

      raise Errors::ScaleOperationError,
            "#{operation} is not legal between #{scale} and " \
            "#{other.scale} scale quantities"
    end

    def quantity_kind!(other)
      unless other.is_a?(Quantity)
        raise ArgumentError, "expected a Unitsml::Quantity, got #{other.class}"
      end
      return if kinds_compatible?(other)

      raise Errors::QuantityKindMismatchError,
            "#{kind.id} (#{kind.name}) and #{other.kind.id} " \
            "(#{other.kind.name}) are not interchangeable: no shared " \
            "equivalence class"
    end

    # Both typed: same quantity or same declared equivalence class. An
    # untyped operand keeps the dimension-only gating.
    def kinds_compatible?(other)
      kind.nil? || other.kind.nil? || kind.compatible?(other.kind)
    end

    def resolve_kind(source)
      return nil if source.nil?

      resolved = if source == :primary
                   primary_kind || raise(
                     Errors::UnknownQuantityKindError,
                     "#{norm_text.inspect} names no single unit with a " \
                     "primary quantity",
                   )
                 else
                   QuantityKind.resolve(source)
                 end
      check_kind_dimension!(resolved)
      resolved
    end

    def check_kind_dimension!(resolved)
      ours = dimension_id
      theirs = resolved.dimension_id
      return if ours.nil? || theirs.nil? || ours == theirs

      raise Errors::DimensionMismatchError,
            "quantity kind #{resolved.id} has dimension #{theirs}, the unit " \
            "#{norm_text.inspect} has #{ours}"
    end

    # The UnitsDB record of a formula that is one unit at power 1 (a prefix
    # is allowed: km is still a length unit).
    def single_unit_record # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      return nil unless formula

      terms = formula.value.grep_v(Extender)
      return nil unless terms.size == 1 && terms.first.is_a?(Unit)

      unit = terms.first
      power = unit.power_numerator
      power = power.raw_value if power.respond_to?(:raw_value)
      return nil unless power.nil? || power.to_s == "1"

      unit.unit_instance
    end

    def gate_dimension!(other)
      ours = gating_vector
      theirs = other.gating_vector
      # Unknown dimensions (units without a decomposition path) defer the
      # legality decision to the conversion layer.
      return if ours.nil? || theirs.nil?
      return if ours == theirs

      raise Errors::DimensionMismatchError,
            "dimension mismatch: #{ours.inspect} vs #{theirs.inspect}"
    end

    protected

    # The UnitsDB dimension vector, or, for a unit without a decomposition
    # path, the dimensions an active caller register declares for it. A
    # register makes such a unit convertible, so it must also make it
    # dimension-checked: otherwise 2 cwt (US) + 3 m would succeed.
    def gating_vector
      vector = dimension_vector
      return vector unless vector.nil?

      record = single_unit_record
      register = Conversion.current_register
      entry = record && register&.entry_for(record)
      entry&.vector
    end

    private

    def scalar_product(number)
      gate_scaling!
      # a scaled difference stays a difference: its conversion must keep
      # skipping the affine addends
      Quantity.new(value: value * number, unit: copied_formula, scale: scale,
                   kind: kind)
    end

    def gate_zero!(other)
      return unless other.zero?

      raise Errors::IndeterminateResultError,
            "division by a zero quantity is indeterminate"
    end

    def build_formula(source)
      case source
      when ABSENT, nil then nil
      when String then Unitsml.parse(source)
      when Unit then Compose::Builder.from_terms([source])
      when Formula then source
      else raise Errors::InvalidUnitEntryError.new(value: source, field: :unit)
      end
    end

    def copied_formula
      Compose::Builder.copy_formula(formula)
    end

    def compose(left, right, operator)
      Compose::Builder.quantity_product(left, right, operator)
    end
  end
end
