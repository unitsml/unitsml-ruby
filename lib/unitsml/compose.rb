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
  end
end
