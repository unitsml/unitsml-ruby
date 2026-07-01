# frozen_string_literal: true

module Unitsml
  # Multiplicative composition for units, dimensions and formulas. `*` combines
  # two operands; `/` combines with the right-hand side inverted. Both are
  # non-mutating and return a fresh root Formula (the real assembly lives in
  # Formula.build_product). Included by Unit, Dimension and Formula only.
  module Composable
    def *(other)
      Formula.build_product(composable_terms, other, "*")
    end

    def /(other)
      Formula.build_product(composable_terms, other, "/")
    end

    protected

    # A leaf (Unit/Dimension) contributes itself; Formula overrides this to
    # contribute its already-interleaved term list.
    def composable_terms
      [self]
    end
  end
end
