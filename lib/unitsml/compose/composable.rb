# frozen_string_literal: true

module Unitsml
  module Compose
    # Multiplicative composition mixin for units, dimensions and formulas. `*`
    # combines two operands; `/` combines with the right-hand side inverted.
    # The fluent aliases (#unit/#dimension) chain the same way, and
    # #quantity/#name/#multiplier attach render metadata. Everything is
    # non-mutating and returns a fresh root Formula (assembly lives in
    # Compose::Builder). Included by Unit, Dimension and Formula only.
    module Composable
      def *(other)
        build_formula(other, "*")
      end

      def /(other)
        build_formula(other, "/")
      end

      # Fluent sugar over `*`: `unit("m", -1)` == `self * Unit.new("m", -1)`,
      # so a chain reads like the operator DSL, e.g.
      #   Unitsml::Unit.new("W").unit("m", -1).unit("sr", -1)
      def unit(reference, power = nil, prefix: nil)
        self * Unit.new(Compose.unit_ref(reference), Compose.power(power),
                        prefix: Compose.prefix_ref(prefix))
      end

      def dimension(reference, power = nil)
        self * Dimension.new(Compose.dimension_ref(reference),
                             Compose.power(power))
      end

      # Append an explicit separator glyph ("*", "/" or "//") exactly as a
      # parsed string would carry it. Glyph-only by design: nothing is negated
      # or transformed — powers are always stated explicitly (the parser's
      # division inference belongs to parsing, not to this builder). The next
      # chained term joins without an implicit "*". To mirror parse("W/m"),
      # write: unit_w.extender("/").unit("m", -1).
      def extender(symbol)
        Builder.append_extender(composable_terms,
                                Compose.extender_sym(symbol))
      end
      alias ext extender

      # Attach render metadata. These come AFTER the units/dimensions: each
      # #unit/#dimension (like `*`) builds a fresh root Formula and does not
      # carry earlier metadata forward, so metadata set before another term is
      # dropped.
      def quantity(value)
        Builder.attach_metadata(self, quantity: value)
      end

      def name(value)
        Builder.attach_metadata(self, name: value)
      end

      def multiplier(value)
        Builder.attach_metadata(self, multiplier: value)
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
        # An Extender operand is an explicit separator, not a term to combine:
        # `w * Extender.new("/")` appends the glyph just like `w.extender("/")`
        # (the operator itself is irrelevant — the Extender carries the glyph).
        return extender(other) if Compose.type?(Extender, other)

        Builder.build_product(composable_terms, operand_terms(other), operator)
      end

      # Only a Unit, Dimension or Formula is composable; anything else fails
      # fast here rather than exploding deeper inside Builder.
      def operand_terms(other)
        return other.composable_terms if composable?(other)

        raise Errors::InvalidUnitEntryError.new(value: other, field: :operand)
      end

      def composable?(other)
        Compose.type_any?([Unit, Dimension, Formula], other)
      end
    end
  end
end
