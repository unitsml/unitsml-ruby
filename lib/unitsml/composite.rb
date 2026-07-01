# frozen_string_literal: true

module Unitsml
  # Programmatic keyword builder behind Unitsml.compose. It is a helper, NOT a
  # Formula subclass: #to_formula materialises the composed root Formula, so the
  # rendered object's class stays Formula. Entries mirror what the parser
  # accepts - units or dimensions, never a mix (Formula.from_terms enforces it).
  class Composite
    def initialize(units:, quantity: nil, name: nil, multiplier: nil)
      @units = units.is_a?(Hash) ? [units] : Array(units)
      @quantity = quantity
      @name = name
      @multiplier = multiplier
    end

    def to_formula
      Formula.from_terms(@units.map { |entry| coerce_entry(entry) },
                         quantity: @quantity, name: @name,
                         multiplier: @multiplier)
    end

    private

    def coerce_entry(entry)
      case entry
      when Unit, Dimension then entry
      when Hash then build_unit(entry)
      when String, Symbol then build_reference(entry.to_s)
      when nil then validate_reference(nil)
      else raise ArgumentError, "invalid unit entry: #{entry.inspect}"
      end
    end

    def build_unit(entry)
      Unit.new(validate_reference(entry[:unit]), entry[:power],
               prefix: entry[:prefix])
    end

    # A dim_* reference builds a Dimension (as the parser would); anything else
    # resolves as a unit and fails fast on an unknown reference.
    def build_reference(reference)
      reference = validate_reference(reference)
      return Dimension.new(reference) if dimension_reference?(reference)

      Unit.new(reference)
    end

    def validate_reference(reference)
      string = reference.to_s
      return string unless string.strip.empty?

      raise Errors::UnknownUnitError.new(value: reference)
    end

    def dimension_reference?(reference)
      Unitsdb.dimensions.parsables.key?(reference)
    end
  end
end
