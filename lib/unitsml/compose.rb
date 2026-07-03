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

    module_function

    # A unit reference just needs to be non-blank; Unit.new then fail-fasts on
    # an unresolvable (or dim_*) name. Rejects nil/"" (which Unit.new would let
    # through as its internal empty sentinel and crash at render).
    def unit_ref(reference)
      string = reference.to_s
      return string unless string.strip.empty?

      raise Errors::UnknownUnitError.new(value: reference)
    end

    # Validate a dimension reference (Dimension.new does not), so the keyword
    # form and the fluent #dimension chain both fail fast with the same
    # Errors::UnknownDimensionError instead of crashing at render.
    def dimension_ref(reference)
      string = reference.to_s
      return string if Unitsdb.dimensions.parsables.key?(string)

      raise Errors::UnknownDimensionError.new(value: reference)
    end

    # A prefix supplied as a Prefix object is reduced to its name so Unit.new
    # validates it; other values (String/Symbol/nil) pass through.
    def prefix_ref(prefix)
      prefix.is_a?(Prefix) ? prefix.prefix_name : prefix
    end

    # A Number power must still be a parser-valid exponent (integer or n/m,
    # optionally signed / double-slashed); a decimal ("0.5") or garbage ("abc")
    # has no parsed equivalent and is rejected. Other types (Integer/Rational/
    # Float/nil) are validated by Builder during assembly.
    def power(value)
      return value unless value.is_a?(Number)
      return value if value.raw_value.match?(%r{\A-?\d+(//?-?\d+)?\z})

      raise Errors::InvalidPowerError.new(value: value,
                                          reason: :non_integer_float)
    end
  end
end
