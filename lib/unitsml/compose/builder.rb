# frozen_string_literal: true

module Unitsml
  module Compose
    # Assembles composed root Formulas for both the operator DSL (build_product)
    # and the keyword form (from_terms). Each leaf is REBUILT with its final
    # power computed up front (coerce, negate for division, drop an
    # inversion-produced ^1); the builder only READS operands and constructs
    # fresh objects, so it can never mutate a caller's operand and never runs an
    # in-place negation on shared state. Branch structure is rebuilt via
    # TermTree; leaf text lives on Unit/Dimension.
    module Builder
      class << self
        # Combine a left term list with the right operand's terms. The operator
        # glyph itself joins the two sides (like the parser: `a / b` keeps the
        # "/" and inverts b's power; `a * b` keeps "*"). An explicit trailing
        # extender on the left (from #extender) already is the join, so no glyph
        # is inserted after it — but `/` still inverts the right-hand side.
        def build_product(left_terms, right_terms, operator)
          left = build_terms(left_terms, invert: false)
          right = build_terms(right_terms, invert: operator == "/")
          joiner = left.last.is_a?(Extender) ? [] : [Extender.new(operator)]
          build_root_formula(left + joiner + right)
        end

        # Append an explicit (pre-validated) separator glyph to the term list,
        # exactly as the parser stores it. Glyph-only: no transformation.
        def append_extender(terms, symbol)
          left = build_terms(terms, invert: false)
          build_root_formula(left + [Extender.new(symbol)])
        end

        # Build a root Formula from an ordered list of unit/dimension operands,
        # interleaving multiplication between them.
        def from_terms(operands, quantity: nil, name: nil, multiplier: nil)
          terms = interleave(build_terms(operands, invert: false))
          build_root_formula(terms, build_metadata(quantity, name, multiplier))
        end

        # Return a Formula carrying the given render metadata (quantity/name/
        # multiplier). A Formula gets a copy with merged metadata; a lone
        # Unit/Dimension is wrapped into a root Formula. Backs the fluent
        # #quantity/#name/#multiplier chain methods.
        def attach_metadata(node, **extras)
          return from_terms([node], **extras) unless node.is_a?(Formula)

          added = build_metadata(extras[:quantity], extras[:name],
                                 extras[:multiplier])
          copy = node.dup
          copy.explicit_value = merge_metadata(node.explicit_value, added)
          copy
        end

        private

        def merge_metadata(existing, added)
          merged = (existing || {}).merge(added || {})
          merged.empty? ? nil : merged
        end

        # orig_text keeps the parser-style source text (and every renderer
        # keeps the original tree); norm_text is a flat, re-parseable leaf
        # list so a composed expression survives a parse round trip.
        def build_root_formula(terms, metadata = nil)
          reject_mixed_terms!(terms)
          Formula.new(terms, explicit_value: metadata, root: true,
                             orig_text: terms_text(terms),
                             norm_text: norm_leaves_text(terms))
        end

        # --- leaf reconstruction (via TermTree.map_leaves) -----------------

        # Rebuild every operand: map_leaves reconstructs branch wrappers and
        # each Unit/Dimension leaf is copied with a freshly built final power
        # (and a duplicated prefix). Non-leaf terms (Extender/Number) plain-dup.
        def build_terms(terms, invert:)
          TermTree.map_leaves(terms) { |leaf| rebuild_leaf(leaf, invert) }
        end

        def rebuild_leaf(leaf, invert)
          return leaf.dup unless leaf.is_a?(Unit) || leaf.is_a?(Dimension)

          copy = leaf.dup
          copy.power_numerator = final_power(leaf.power_numerator, invert)
          copy.prefix = leaf.prefix.dup if leaf.is_a?(Unit) && leaf.prefix
          copy
        end

        # The leaf's final exponent as a fresh Number (or nil). For division the
        # exponent is negated; a negation that resolves to +1 (dividing by a
        # ^-1 term) renders as no exponent, matching the parser, so it is
        # dropped. A non-inverted explicit ^1 is preserved.
        def final_power(power, invert)
          if power.is_a?(Fenced)
            return copy_fenced_power(power) unless invert

            raw = fenced_raw(power)
          else
            raw = power_string(power)
          end
          return raw && Number.new(raw) unless invert

          negated = negate_string(raw)
          negated == "1" ? nil : Number.new(negated)
        end

        # A parser-produced Fenced exponent (e.g. m^((1/2))): its innermost
        # lexeme, read through any number of nested wrappers.
        def fenced_raw(power)
          power.is_a?(Fenced) ? fenced_raw(power.value) : power_string(power)
        end

        # Deep copy of a non-inverted Fenced exponent, wrappers preserved.
        def copy_fenced_power(power)
          inner = power.value
          inner = inner.is_a?(Fenced) ? copy_fenced_power(inner) : inner.dup
          Fenced.new(power.open_paren, inner, power.close_paren)
        end

        # A builder-supplied power as a parser-style exponent string (or nil):
        # 1 -> "1", 1/2 -> "1/2", 2.0 -> "2". A non-integer Float is rejected
        # (the parser has no decimal exponent); an existing Number is read by
        # value, never shared.
        def power_string(power)
          case power
          when nil then nil
          when Number then power.raw_value
          when Integer then power.to_s
          when Rational then rational_string(power)
          when Float then float_string(power)
          else raise Errors::InvalidPowerError.new(value: power)
          end
        end

        def float_string(power)
          unless power.finite? && power == power.to_i
            raise Errors::InvalidPowerError.new(value: power,
                                                reason: :non_integer_float)
          end

          power.to_i.to_s
        end

        def rational_string(power)
          power.denominator == 1 ? power.numerator.to_s : power.to_s
        end

        # Negate an exponent string: nil (no exponent) -> "-1", else flip sign.
        def negate_string(raw)
          return "-1" if raw.nil?

          raw.start_with?("-") ? raw.delete_prefix("-") : "-#{raw}"
        end

        # --- unit/dimension mixing guard (via TermTree.each_leaf) ----------

        # Units and dimensions cannot share one expression (the XML serializer
        # would drop the unit block); a single walk collects the leaf kinds.
        def reject_mixed_terms!(terms)
          kinds = leaf_kinds(terms)
          return unless kinds.include?(Unit) && kinds.include?(Dimension)

          raise Errors::MixedTermsError
        end

        def leaf_kinds(terms)
          kinds = []
          TermTree.each_leaf(terms) do |leaf|
            kinds << leaf.class if leaf.is_a?(Unit) || leaf.is_a?(Dimension)
          end
          kinds
        end

        # --- text synthesis ------------------------------------------------

        # Reconstruct parser-style source text; leaf text lives on the domain
        # objects (Unit/Dimension#xml_postprocess_name) and branches wrap their
        # inner text. Recurses over the same tree shape as TermTree.
        def terms_text(term)
          case term
          when Array then term.map { |child| terms_text(child) }.join
          when Unit, Dimension then term.xml_postprocess_name
          when Extender then term.symbol
          else branch_text(term)
          end
        end

        # Flat norm_text: the simple Unit / Unit shape keeps its familiar
        # text (m/s); anything else lists every ordered leaf with its stored
        # power, joined by "*". Wrappers (Fenced/Sqrt/Formula) contribute only
        # their stored leaves; powers are copied lexically, never evaluated.
        def norm_leaves_text(terms)
          return simple_division_text(terms) if simple_division?(terms)

          leaves = []
          TermTree.each_leaf(terms) do |leaf|
            case leaf
            when Unit, Dimension then leaves << leaf_norm_text(leaf)
            when Number then leaves << leaf.raw_value
            end
          end
          leaves.join("*")
        end

        def simple_division?(terms)
          terms.size == 3 && terms[0].is_a?(Unit) &&
            terms[1].is_a?(Extender) && terms[1].symbol == "/" &&
            terms[2].is_a?(Unit) && terms[0].power_numerator.nil? &&
            terms[2].power_numerator.is_a?(Number) &&
            terms[2].power_numerator.raw_value == "-1"
        end

        def simple_division_text(terms)
          "#{unit_text(terms[0])}/#{unit_text(terms[2])}"
        end

        def unit_text(unit)
          "#{unit.prefix_name}#{unit.unit_name}"
        end

        def leaf_norm_text(leaf)
          name = leaf.is_a?(Unit) ? unit_text(leaf) : leaf.dimension_name
          power = leaf.power_numerator
          raw = power && decimal_as_fraction(fenced_raw(power))
          raw ? "#{name}^(#{raw})" : name
        end

        # A finite decimal lexeme (0.5) is not a parser exponent; write it as
        # the lexical fraction 5/10 by digit placement, with no Float math.
        def decimal_as_fraction(raw)
          return raw unless raw.match?(/\A-?\d+\.\d+\z/)

          sign = raw.start_with?("-") ? "-" : ""
          whole, fraction = raw.delete_prefix("-").split(".")
          numerator = "#{whole}#{fraction}".sub(/\A0+(?=\d)/, "")
          "#{sign}#{numerator}/#{10**fraction.size}"
        end

        def branch_text(term)
          case term
          when Fenced
            "#{term.open_paren}#{terms_text(term.value)}#{term.close_paren}"
          when Sqrt then "sqrt(#{terms_text(term.value)})"
          when Formula then terms_text(term.value)
          else ""
          end
        end

        # --- small helpers -------------------------------------------------

        def interleave(operands)
          operands.each_with_index.flat_map do |operand, index|
            index.zero? ? [operand] : [mul_extender, operand]
          end
        end

        def build_metadata(quantity, name, multiplier)
          Compose.validate_name!(name)
          Compose.validate_multiplier!(multiplier)
          metadata = { quantity: quantity, name: name,
                       multiplier: multiplier }.compact
          metadata.empty? ? nil : metadata
        end

        def mul_extender
          Extender.new("*")
        end
      end
    end
  end
end
