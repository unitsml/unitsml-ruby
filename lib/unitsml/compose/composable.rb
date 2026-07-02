# frozen_string_literal: true

module Unitsml
  module Compose
    # Multiplicative composition mixin for units, dimensions and formulas. `*`
    # combines two operands; `/` combines with the right-hand side inverted.
    # Both are non-mutating and return a fresh root Formula (assembly lives in
    # Compose::Builder). Included by Unit, Dimension and Formula only.
    module Composable
      def *(other)
        build_formula(other, "*")
      end

      def /(other)
        build_formula(other, "/")
      end

      # The term list this operand contributes to a composition. A leaf
      # (Unit/Dimension) contributes itself; Formula overrides this to
      # contribute its already-interleaved value. Public so an operand can
      # supply its terms to the other side of `*`/`/`.
      def composable_terms
        [self]
      end

      private

      def build_formula(other, operator)
        Builder.build_product(composable_terms, operand_terms(other), operator)
      end

      # Only a Unit, Dimension or Formula is composable; anything else fails
      # fast here rather than exploding deeper inside Builder.
      def operand_terms(other)
        return other.composable_terms if composable?(other)

        raise Errors::InvalidUnitEntryError.new(value: other, field: :operand)
      end

      def composable?(other)
        other.is_a?(Unit) || other.is_a?(Dimension) || other.is_a?(Formula)
      end
    end
  end
end
