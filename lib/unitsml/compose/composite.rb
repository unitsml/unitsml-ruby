# frozen_string_literal: true

module Unitsml
  module Compose
    # Keyword builder behind Unitsml.compose. Resolves whether the request is a
    # unit or a dimension composition (never both), coerces each entry into a
    # domain object, and hands the list to Builder. A helper, not a Formula
    # subclass: #to_formula returns a plain root Formula. quantity/name/
    # multiplier are metadata passed straight through (the render layer ignores
    # what does not apply, e.g. quantity/name for a dimension composition).
    class Composite
      def initialize(units: nil, dimensions: nil,
                     quantity: nil, name: nil, multiplier: nil)
        @quantity = quantity
        @name = name
        @multiplier = multiplier
        classify(normalize(units), normalize(dimensions))
      end

      def to_formula
        Builder.from_terms(@entries.map { |entry| coerce_entry(entry) },
                           quantity: @quantity, name: @name,
                           multiplier: @multiplier)
      end

      private

      # A lone Hash is a single entry; nil is nothing; anything else is a list.
      def normalize(entries)
        return [] if entries.nil?

        entries.is_a?(Hash) ? [entries] : Array(entries)
      end

      # Exactly one of units:/dimensions: may be non-empty. Store the resolved
      # kind and its entries; both -> mix, neither -> empty.
      def classify(units, dimensions)
        # Presence is emptiness, not .any? — [nil] is a (bad) entry to reject,
        # not an empty list.
        has_units = !units.empty?
        has_dimensions = !dimensions.empty?

        if has_units && has_dimensions
          raise Errors::MixedTermsError.new(
            "[unitsml] Pass either units: or dimensions:, not both.",
          )
        elsif has_units
          @kind = :unit
          @entries = units
        elsif has_dimensions
          @kind = :dimension
          @entries = dimensions
        else
          raise Errors::EmptyCompositionError
        end
      end

      def coerce_entry(entry)
        case entry
        when Unit, Dimension then typed_entry(entry)
        when Hash then build_from_hash(entry)
        when String, Symbol then build_reference(entry.to_s)
        when nil then blank_reference
        else raise Errors::InvalidUnitEntryError.new(value: entry, field: @kind)
        end
      end

      # A pre-built object must match the composition's kind (a Dimension in
      # units:, or a Unit in dimensions:, is rejected). It is then rebuilt
      # through the same validated path as a Hash entry so its name, power and
      # prefix are normalized/validated — otherwise a Symbol name, an invalid
      # Number power, or an unresolved Prefix object slips through and crashes
      # (or renders non-parseably) at render time.
      def typed_entry(entry)
        unless entry.is_a?(expected_class)
          raise Errors::InvalidUnitEntryError.new(value: entry, field: @kind)
        end

        @kind == :dimension ? rebuild_dimension(entry) : rebuild_unit(entry)
      end

      def rebuild_unit(unit)
        Unit.new(require_reference(unit.unit_name),
                 require_power(unit.power_numerator),
                 prefix: prefix_ref(unit.prefix))
      end

      def rebuild_dimension(dimension)
        Dimension.new(require_dimension(dimension.dimension_name),
                      require_power(dimension.power_numerator))
      end

      def build_from_hash(entry)
        return build_dimension_hash(entry) if @kind == :dimension

        Unit.new(require_reference(entry[:unit]), require_power(entry[:power]),
                 prefix: prefix_ref(entry[:prefix]))
      end

      def build_dimension_hash(entry)
        if entry.key?(:prefix)
          raise Errors::InvalidUnitEntryError.new(value: entry, field: :prefix)
        end

        Dimension.new(require_dimension(entry[:dimension]),
                      require_power(entry[:power]))
      end

      def build_reference(reference)
        return Unit.new(require_reference(reference)) if @kind == :unit

        Dimension.new(require_dimension(reference))
      end

      # A unit reference just needs to be non-blank; Unit.new fail-fasts on an
      # unresolvable (or dim_*) name, which is what makes units: units-only.
      def require_reference(reference)
        string = reference.to_s
        return string unless string.strip.empty?

        raise Errors::UnknownUnitError.new(value: reference)
      end

      # A dimension reference is validated eagerly (Dimension.new does not),
      # keeping compose fail-fast like the parser.
      def require_dimension(reference)
        string = reference.to_s
        return string if Unitsdb.dimensions.parsables.key?(string)

        raise Errors::UnknownDimensionError.new(value: reference)
      end

      def blank_reference
        @kind == :dimension ? require_dimension(nil) : require_reference(nil)
      end

      # A user-supplied power wrapped in a Number must still be a parser-valid
      # exponent. This regex mirrors the grammar's `slashed_number`
      # (parse.rb: a signed integer, optionally `/` or `//` then a signed
      # integer), so forms like "1/-2" and "1//2" are accepted while a decimal
      # ("0.5") or non-numeric string has no parsed equivalent and is rejected.
      # Other power types are validated by Builder during assembly.
      def require_power(power)
        return power unless power.is_a?(Number)
        return power if power.raw_value.match?(%r{\A-?\d+(//?-?\d+)?\z})

        raise Errors::InvalidPowerError.new(value: power,
                                            reason: :non_integer_float)
      end

      # A prefix passed as a Prefix object is reduced to its name so Unit.new
      # validates it (a bad name raises UnknownPrefixError); an unvalidated
      # Prefix object would otherwise leak a NoMethodError at render.
      def prefix_ref(prefix)
        prefix.is_a?(Prefix) ? prefix.prefix_name : prefix
      end

      def expected_class
        @kind == :dimension ? Dimension : Unit
      end
    end
  end
end
