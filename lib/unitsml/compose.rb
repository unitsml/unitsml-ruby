# frozen_string_literal: true

module Unitsml
  # Programmatic composite-unit construction: the operator DSL (Composable) and
  # the Unitsml.compose keyword form (Composite), both assembled by Builder into
  # a plain root Formula. Kept in its own namespace so the composition machinery
  # does not leak into the core Unit/Dimension/Formula classes.
  module Compose
    autoload :Builder, "unitsml/compose/builder"
    autoload :Composable, "unitsml/compose/composable"
    autoload :Composite, "unitsml/compose/composite"
    autoload :TermTree, "unitsml/compose/term_tree"

    module_function

    # Validate a dimension reference (Dimension.new does not), so the keyword
    # form and the fluent #dimension chain both fail fast with the same
    # Errors::UnknownDimensionError instead of crashing at render.
    def dimension_ref(reference)
      string = reference.to_s
      return string if Unitsdb.dimensions.parsables.key?(string)

      raise Errors::UnknownDimensionError.new(value: reference)
    end
  end
end
