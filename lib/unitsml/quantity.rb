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
    attr_reader :value, :formula, :scale

    # Distinguishes an omitted unit keyword from an explicit nil.
    ABSENT = Object.new.freeze
    private_constant :ABSENT

    # unit: accepts a String (parsed, like unit_expression:), a Unit, a
    # Formula (kept as-is, never reparsed) or nil (a pure number).
    # unit_expression: remains the String-only spelling; give only one.
    def initialize(value:, unit: ABSENT, unit_expression: ABSENT,
                   scale: nil)
      unless unit.equal?(ABSENT) || unit_expression.equal?(ABSENT)
        raise ArgumentError, "give only one of unit: or unit_expression:"
      end

      @value = value
      @formula = build_formula(unit.equal?(ABSENT) ? unit_expression : unit)
      # The scale derives from the unitsdb scale_reference of the units in
      # the expression (degC is continuous_interval); an explicit argument
      # (the :difference typing of subtraction) overrides it.
      @scale = (scale || derived_scale).to_sym
    end

    # Canonical dimension identity; "1" (dimensionless) for pure numbers.
    def dimension_id
      @dimension_id ||= begin
        list = dimension_list
        list && (Utility.dim_id(list) || "1")
      end
    end

    # rubocop:disable Metrics/AbcSize, Layout/LineLength
    # Base-dimension exponents summed across the composed expression —
    # V (L²MT⁻³I⁻¹) times A (I¹) merges to the watt vector L²MT⁻³.
    def dimension_vector
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
        return Quantity.new(value: value / other, unit: copied_formula)
      end

      other = Compose.quantity_operand(other)
      scale_ratio_gate!(other, "division")
      if other.value.zero?
        raise Errors::IndeterminateResultError,
              "division by a zero quantity is indeterminate"
      end

      Quantity.new(value: value / other.value,
                   unit: compose(formula, other.formula, "/"))
    end

    # R-A4: differences are legal on both ratio and interval scales;
    # only the dimension identity must match.
    def +(other)
      quantity_kind!(other)
      gate_dimension!(other)
      Quantity.new(value: value + other.value, unit: copied_formula)
    end

    def -(other)
      quantity_kind!(other)
      gate_dimension!(other)
      # A difference of two quantities is difference-typed: its conversion
      # skips the affine addends (20 degC - 15 degC converts to 5 K, not
      # 278.15 K).
      Quantity.new(value: value - other.value, unit: copied_formula,
                   scale: :difference)
    end

    # R-A3: convert this quantity to another (dimension-compatible) unit
    # using the unitsdb canonical_conversion data. Exact rational
    # arithmetic throughout; the returned value is a Rational when a
    # conversion was applied.
    def convert_to(target_expression)
      target_formula = if target_expression.is_a?(Formula)
                         target_expression
                       else
                         Unitsml.parse(target_expression)
                       end
      gate_target = Quantity.new(value: 0,
                                 unit_expression: target_formula.norm_text)
      gate_dimension!(gate_target)

      src = Conversion.to_canonical(formula)
      dst = Conversion.to_canonical(target_formula)
      converted = if scale == :difference
                    # differences carry no affine addends
                    (Rational(value) * src.factor) / dst.factor
                  else
                    ((Rational(value) * src.factor) + src.offset - dst.offset) / dst.factor
                  end

      Quantity.new(value: converted, unit_expression: target_formula.norm_text)
    end

    def ==(other)
      other.is_a?(Quantity) && value == other.value &&
        dimension_vector == other.dimension_vector
    end
    # rubocop:enable Metrics/AbcSize, Layout/LineLength

    private

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
    end

    def gate_dimension!(other)
      # Unknown dimensions (units without a decomposition path) defer the
      # legality decision to the conversion layer.
      return if dimension_vector.nil? || other.dimension_vector.nil?
      return if dimension_vector == other.dimension_vector

      raise Errors::DimensionMismatchError,
            "dimension mismatch: #{dimension_vector.inspect} " \
            "vs #{other.dimension_vector.inspect}"
    end

    def scalar_product(number)
      gate_scaling!
      Quantity.new(value: value * number, unit: copied_formula)
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
