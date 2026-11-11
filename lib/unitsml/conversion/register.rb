# frozen_string_literal: true

module Unitsml
  module Conversion
    # A validated caller register: per-unit factors (and affine offsets)
    # to the canonical SI composition, supplied by the caller rather than
    # read from UnitsDB. WORK-PACKAGES F02: "Use data or validated caller
    # registers for factors/addends; preserve exact arithmetic and source
    # provenance."
    #
    # Entry: { "unit" => id or symbol, "factor" => exact decimal/rational
    # String, "offset" => optional exact String, "dimensions" => { base
    # dimension name => exponent String } }. Semantics match the UnitsDB
    # canonical_conversion: value_SI = value * factor + offset.
    #
    # Validation fails explicitly (InvalidUnitRegisterError): unknown
    # fields, non-String or non-exact numbers, a factor that is not
    # positive, declared dimensions that differ from the unit's own, and an
    # entry that disagrees with the register's canonical_conversion for
    # the same unit (the 1e-9 relative tolerance used by Conversion#agree!).
    # An unknown unit raises UnknownUnitError. A later entry for the same
    # unit replaces an earlier one.
    #
    # A register applies only inside Conversion.with_register; it never
    # persists past the block.
    class Register
      FIELDS = %w[unit factor offset dimensions].freeze
      EXACT = %r{\A[+-]?(?:\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|\d+/\d+)\z}
      Entry = Struct.new(:record, :factor, :offset, keyword_init: true)

      attr_reader :entries

      def initialize(entries)
        unless entries.is_a?(Array)
          raise Errors::InvalidUnitRegisterError,
                "a register is an Array of entries, got #{entries.class}"
        end

        @entries = {}
        entries.each do |raw|
          entry = build_entry(raw)
          @entries[identity(entry.record)] = entry
        end
      end

      def entry_for(record)
        @entries[identity(record)]
      end

      def empty?
        @entries.empty?
      end

      private

      def identity(record)
        record.identifiers.to_a.map { |i| "#{i.type}:#{i.id}" }.sort.join("|")
      end

      def build_entry(raw) # rubocop:disable Metrics/AbcSize
        unless raw.is_a?(Hash)
          raise Errors::InvalidUnitRegisterError,
                "a register entry is a Hash, got #{raw.class}"
        end

        raw = raw.transform_keys(&:to_s)
        extra = raw.keys - FIELDS
        unless extra.empty?
          raise Errors::InvalidUnitRegisterError,
                "unknown register entry field(s) #{extra.sort.inspect}"
        end

        record = resolve_unit(raw["unit"])
        factor = exact(raw["factor"], "factor")
        unless factor.positive?
          raise Errors::InvalidUnitRegisterError,
                "register factor must be positive, got #{raw['factor']}"
        end

        offset = raw.key?("offset") ? exact(raw["offset"], "offset") : 0r
        check_dimensions!(record, raw["dimensions"])
        check_canonical!(record, factor, offset)
        Entry.new(record: record, factor: factor, offset: offset)
      end

      def resolve_unit(name)
        unless name.is_a?(String) && !name.strip.empty?
          raise Errors::InvalidUnitRegisterError,
                "register unit must be a non-empty String"
        end

        record = Unitsdb.units.find_by_id(name) ||
          Unitsdb.units.find_by_name(name)
        return record if record

        raise Errors::UnknownUnitError.new(value: name)
      end

      def exact(value, field)
        unless value.is_a?(String) && EXACT.match?(value)
          raise Errors::InvalidUnitRegisterError,
                "register #{field} must be an exact decimal or rational " \
                "String, got #{value.inspect}"
        end

        Rational(value)
      end

      # The declared dimensions must name the unit's own UnitsDB dimension:
      # both are resolved to a dimension identity through Utility.dim_id and
      # the unit's primary quantity, so no expression is reparsed.
      def check_dimensions!(record, declared) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        unless declared.is_a?(Hash) && !declared.empty?
          raise Errors::InvalidUnitRegisterError,
                "register dimensions must be a non-empty Hash"
        end

        list = declared.filter_map do |name, exponent|
          value = exact(exponent.to_s, "dimension exponent")
          next if value.zero?

          unless value.denominator == 1
            raise Errors::InvalidUnitRegisterError,
                  "register dimension exponents must be integers"
          end

          { dimension: name.to_s, exponent: value.to_i }
        end
        wanted = registered_dimension_id(list)
        actual = unit_dimension_id(record)
        return if actual && wanted == actual

        raise Errors::InvalidUnitRegisterError,
              "register dimensions #{declared.inspect} (#{wanted.inspect}) " \
              "differ from the unit's dimension #{actual.inspect}"
      end

      # Only dimensions the register itself names; an unnamed vector has no
      # identity to compare and is refused.
      def registered_dimension_id(list)
        vector = Utility::DIMS_VECTOR.map do |name|
          list.find { |d| d[:dimension] == name }&.dig(:exponent)
        end.join(":")
        Unitsdb.dimensions.find_by_vector(vector)&.id&.to_s
      end

      def unit_dimension_id(record)
        QuantityKind.primary_for(record)&.dimension_id ||
          (record.respond_to?(:dimension_url) && record.dimension_url)
      end

      def check_canonical!(record, factor, offset) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        cc = record.canonical_conversion
        return unless cc

        canonical = [Rational(cc.factor), Rational(cc.offset || 0)]
        agreed = canonical.zip([factor, offset]).all? do |ours, theirs|
          delta = (ours - theirs).abs
          delta.zero? || delta <= ours.abs / Rational(10**9)
        end
        return if agreed

        raise Errors::InvalidUnitRegisterError,
              "register entry (#{factor}, #{offset}) disagrees with the " \
              "canonical conversion (#{canonical[0]}, #{canonical[1]}) for " \
              "#{record.symbols.to_a.first&.id.inspect}"
      end
    end
  end
end
