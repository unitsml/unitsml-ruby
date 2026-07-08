# frozen_string_literal: true

module Unitsml
  # Programmatic composite-unit construction: the operator DSL / fluent chain
  # (Composable), the Unitsml.compose keyword form (Composite), and the shared
  # assembly (Builder). The raw-input validators below are shared by BOTH the
  # keyword form and the fluent chain so a bad reference/power/prefix fails fast
  # with the same Errors::* class no matter which surface is used.
  module Compose
    autoload :Builder, "unitsml/compose/builder"
    autoload :Composable, "unitsml/compose/composable"
    autoload :Composite, "unitsml/compose/composite"
    autoload :TermTree, "unitsml/compose/term_tree"

    # The parser's grammar knows exactly these separators; anything else is a
    # display concern served by the render-time multiplier: option.
    EXTENDERS = ["*", "/", "//"].freeze

    module_function

    # A render name is embedded directly into <UnitName>, so it must be a plain
    # String/Symbol (or nil); a Hash/other serializes as garbage. Shared by the
    # compose build path and the render-option path (to_*(name:)).
    def validate_name!(name)
      return if type_any?([NilClass, String, Symbol], name)

      raise Errors::InvalidUnitEntryError.new(value: name, field: :name)
    end

    # A multiplier is a render separator: nil, a String, or :space/:nospace.
    # Reject anything else where it enters (compose metadata, or a
    # to_*(multiplier:) option) so a bad value fails as Errors::*, not later.
    def validate_multiplier!(multiplier)
      return if type_any?([NilClass, String], multiplier)
      return if %i[space nospace].include?(multiplier)

      raise Errors::InvalidUnitEntryError.new(value: multiplier,
                                              field: :multiplier)
    end

    # An explicit extender: an Extender object (reduced to its symbol), or a
    # glyph the parser could have produced ("*", "/" or "//"). Custom separators
    # belong to the multiplier: render option, not the Formula.
    def extender_sym(value)
      symbol = type?(Extender, value) ? value.symbol : value
      string = safe_string(symbol)
      return string if EXTENDERS.include?(string)

      raise Errors::InvalidUnitEntryError.new(value: symbol, field: :extender)
    end

    # A unit reference just needs to be non-blank; Unit.new then fail-fasts on
    # an unresolvable (or dim_*) name. Rejects nil/"" (which Unit.new would let
    # through as its internal empty sentinel and crash at render).
    def unit_ref(reference)
      string = safe_string(reference)
      return string if string && !string.strip.empty?

      raise Errors::UnknownUnitError.new(value: reference)
    end

    # Normalize and validate a dimension reference at the shared compose
    # boundary, so the keyword form, fluent #dimension chain, and Dimension.new
    # all fail fast with the same Errors::UnknownDimensionError behavior.
    def dimension_ref(reference)
      string = safe_string(reference)
      return string if string && Unitsdb.dimensions.parsables.key?(string)

      raise Errors::UnknownDimensionError.new(value: reference)
    end

    # A prefix supplied as a Prefix object is reduced to its name so Unit.new
    # validates it; other values (String/Symbol/nil) pass through.
    def prefix_ref(prefix)
      type?(Prefix, prefix) ? prefix.prefix_name : prefix
    end

    # A Number power must still be a parser-valid exponent (integer or n/m,
    # optionally signed / double-slashed); a decimal ("0.5") or garbage ("abc")
    # has no parsed equivalent and is rejected. Other types (Integer/Rational/
    # Float/nil) are validated by Builder during assembly.
    def power(value)
      return value unless type?(Number, value)
      return value if value.raw_value.match?(%r{\A-?\d+(//?-?\d+)?\z})

      raise Errors::InvalidPowerError.new(value: value,
                                          reason: :invalid_number)
    end

    # #to_s for a raw compose input without letting a pathological override (one
    # that raises, has no #to_s, or returns a non-String) escape as a
    # non-Errors::* exception; the caller treats nil as "not usable".
    def safe_string(value)
      string = value.to_s
      string if string.is_a?(String)
    rescue StandardError
      nil
    end

    # A raw Numeric exponent, rendered in the parser's string form (a whole
    # integer, or an n/m fraction from a Rational). A decimal (non-integer
    # Float) has no parser representation and is rejected — nothing beyond what
    # the parser accepts is introduced.
    def numeric_exponent_string(numeric)
      case numeric
      when Rational then rational_exponent_string(numeric)
      when Float then integer_float_string(numeric)
      else numeric.to_s # Integer (and any other whole Numeric)
      end
    end

    def rational_exponent_string(rational)
      rational.denominator == 1 ? rational.numerator.to_s : rational.to_s
    end

    def integer_float_string(float)
      unless float.finite? && float == float.to_i
        raise Errors::InvalidPowerError.new(value: float,
                                            reason: :non_integer_float)
      end

      float.to_i.to_s
    end

    # Class-membership test via Module#=== rather than #is_a?, so a compose
    # input that is a BasicObject (which has no #is_a?/#nil?) is rejected as a
    # typed Errors::* instead of the check itself raising a raw NoMethodError.
    def type?(klass, value)
      klass === value # rubocop:disable Style/CaseEquality
    end

    def type_any?(klasses, value)
      klasses.any? { |klass| type?(klass, value) }
    end
  end
end
