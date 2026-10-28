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

    def initialize(value:, unit_expression: nil, scale: :ratio)
      @value = value
      @formula = unit_expression && Unitsml.parse(unit_expression)
      @scale = scale.to_sym
    end

    # Canonical dimension identity; "1" (dimensionless) for pure numbers.
    def dimension_id
      @dimension_id ||= begin
        list = dimension_list
        list && (Utility.dim_id(list) || "1")
      end
    end

    # Base-dimension exponents summed across the composed expression —
    # V (L²MT⁻³I⁻¹) times A (I¹) merges to the watt vector L²MT⁻³.
    def dimension_vector
      vector = raw_dimension_list.each_with_object(Hash.new(0)) do |entry, acc|
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

    def *(other)
      if other.is_a?(Numeric)
        gate_scaling!
        return Quantity.new(value: value * other, unit_expression: norm_text)
      end

      scale_ratio_gate!(other, "multiplication")
      Quantity.new(value: value * other.value,
                   unit_expression: compose(self, other, "*"))
    end

    # rubocop:disable Metrics/AbcSize
    def /(other)
      if other.is_a?(Numeric)
        gate_zero!(other)
        gate_scaling!
        return Quantity.new(value: value / other, unit_expression: norm_text)
      end

      scale_ratio_gate!(other, "division")
      if other.value.zero?
        raise Errors::IndeterminateResultError,
              "division by a zero quantity is indeterminate"
      end

      Quantity.new(value: value / other.value,
                   unit_expression: compose(self, other, "/"))
    end
    # rubocop:enable Metrics/AbcSize

    # R-A4: differences are legal on both ratio and interval scales;
    # only the dimension identity must match.
    def +(other)
      quantity_kind!(other)
      gate_dimension!(other)
      Quantity.new(value: value + other.value, unit_expression: norm_text)
    end

    def -(other)
      quantity_kind!(other)
      gate_dimension!(other)
      Quantity.new(value: value - other.value, unit_expression: norm_text)
    end

    # R-A3: convert this quantity to another (dimension-compatible) unit
    # using the unitsdb canonical_conversion data. Exact rational
    # arithmetic throughout; the returned value is a Rational when a
    # conversion was applied.
    def convert_to(target_expression)
      target_formula = target_expression.is_a?(Formula) ? target_expression : Unitsml.parse(target_expression)
      gate_dimension!(Quantity.new(value: 0, unit_expression: target_formula.norm_text))

      src = Conversion.to_canonical(formula)
      dst = Conversion.to_canonical(target_formula)
      converted = (Rational(value) * src.factor + src.offset - dst.offset) / dst.factor

      Quantity.new(value: converted, unit_expression: target_formula.norm_text)
    end

    def ==(other)
      other.is_a?(Quantity) && value == other.value &&
        dimension_vector == other.dimension_vector
    end

    private

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
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
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
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

    # R-A4: ratio-scale operations are specified errors on non-ratio
    # quantities. Differences and comparisons remain legal on both.
    # Scalar multiplication/division scales the magnitude: legal on
    # ratio scales, a specified error on non-ratio ones.
    def gate_scaling!
      return if scale == :ratio

      raise Errors::ScaleOperationError,
            "scaling is not legal on a #{scale} scale quantity"
    end

    def scale_ratio_gate!(other, operation)
      return if scale == :ratio && other.scale == :ratio

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
      return if dimension_vector == other.dimension_vector

      raise Errors::DimensionMismatchError,
            "dimension mismatch: #{dimension_vector.inspect} " \
            "vs #{other.dimension_vector.inspect}"
    end

    def gate_zero!(other)
      return unless other.zero?

      raise Errors::IndeterminateResultError,
            "division by a zero quantity is indeterminate"
    end

    def compose(left, right, operator)
      "#{left.norm_text}#{operator}#{right.norm_text}"
    end
  end
end
