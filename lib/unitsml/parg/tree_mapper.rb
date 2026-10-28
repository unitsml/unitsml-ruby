# frozen_string_literal: true

module Unitsml
  module Parg
    # Maps asciiunits artifact parse trees (capture-named hashes whose leaves
    # are {value, offset, ...} slices) onto the same object model the Parslet
    # Transform produces. Dispatch is on the exact key set of each node
    # (sorted), bottom-up, mirroring rule-for-rule the Transform rules in
    # unitsml/transform.rb.
    class TreeMapper
      # Edition-2 artifacts (parsanol capture edition 2) name every
      # uncaptured rule reference; these four are the names this grammar
      # gains — the fence punctuation, the sign-suffix hyphen and the
      # zero-width guard — none of which the v1 trees ever surfaced and
      # none of which are authored capture names. Stripping them in the
      # normalize pass keeps the dispatch table reading the same shapes
      # for both editions, so this mapper works against artifacts baked
      # before and after the asciiunits edition-2 flip.
      STRUCTURAL_NAMES = %w[lparen rparen hyphen end_guard].freeze

      def apply(tree)
        map(normalize(tree))
      end

      private

      # The artifact runtime hands back symbol-keyed hashes with parsanol
      # Slice leaves; the mapper works on string keys and stringified leaves.
      def normalize(node)
        case node
        when Hash
          node.to_h { |key, value| [key.to_s, normalize(value)] }
            .except(*STRUCTURAL_NAMES)
        when Array then node.map { |value| normalize(value) }
        else node
        end
      end

      # The case below is a dispatch table mirroring unitsml/transform.rb
      # rule-for-rule; splitting it would obscure the 1:1 parity contract.
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def map(node)
        return node unless node.is_a?(Hash)

        node = node.transform_values do |value|
          value.is_a?(Hash) ? map(value) : value
        end
        case node.keys.map(&:to_s).sort
        when %w[dimension] then Dimension.new(text(node["dimension"]))
        when %w[dimension extender power_numerator sequence]
          Formula.new(
            [Dimension.new(text(node["dimension"]), node["power_numerator"]),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[dimension extender sequence]
          Formula.new(
            [Dimension.new(text(node["dimension"])),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[dimension power_numerator]
          Dimension.new(text(node["dimension"]), node["power_numerator"])
        when %w[extender first_set second_set]
          Formula.new(
            [node["first_set"], Extender.new(text(node["extender"])),
             node["second_set"]],
          )
        when %w[extender implicit_extended sequence]
          Formula.new(
            [node["implicit_extended"], Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[extender int_exp sequence]
          Formula.new(
            [node["int_exp"], Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[extender power_numerator sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"]), node["power_numerator"]),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[extender power_numerator prefix sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"]), node["power_numerator"],
                      prefix: Prefix.new(text(node["prefix"]))),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[extender prefix sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"]),
                      prefix: Prefix.new(text(node["prefix"]))),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[extender sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"])),
             Extender.new(text(node["extender"])),
             node["sequence"]],
          )
        when %w[first_int_exp_set second_int_exp_set]
          Formula.new(
            [set_to_fence(node["first_int_exp_set"]),
             set_to_fence(node["second_int_exp_set"])],
          )
        when %w[first_int_exp_set second_set]
          Formula.new(
            [set_to_fence(node["first_int_exp_set"]), node["second_set"]],
          )
        when %w[first_set second_int_exp_set]
          Formula.new(
            [node["first_set"], set_to_fence(node["second_int_exp_set"])],
          )
        when %w[first_set second_set]
          Formula.new([node["first_set"], node["second_set"]])
        when %w[implicit_extended] then node["implicit_extended"]
        when %w[int_exp] then node["int_exp"]
        when %w[int_exp sequence]
          Formula.new([node["int_exp"], node["sequence"]])
        when %w[integer] then Number.new(text(node["integer"]))
        when %w[close_paren integer open_paren]
          Fenced.new(text(node["open_paren"]),
                     Number.new(text(node["integer"])),
                     text(node["close_paren"]))
        when %w[close_paren int_exp open_paren]
          Fenced.new(text(node["open_paren"]), node["int_exp"],
                     text(node["close_paren"]))
        when %w[power_numerator unit]
          Unit.new(text(node["unit"]), node["power_numerator"])
        when %w[power_numerator prefix unit]
          Unit.new(text(node["unit"]), node["power_numerator"],
                   prefix: Prefix.new(text(node["prefix"])))
        when %w[prefix sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"]),
                      prefix: Prefix.new(text(node["prefix"]))),
             node["sequence"]],
          )
        when %w[sequence sqrt]
          Formula.new(
            [Sqrt.new(node["sqrt"]), node["sequence"]],
          )
        when %w[sequence unit]
          Formula.new(
            [Unit.new(text(node["unit"])), node["sequence"]],
          )
        when %w[implicit_extended sequence]
          Formula.new(
            [node["implicit_extended"], node["sequence"]],
          )
        when %w[prefix] then Prefix.new(text(node["prefix"]))
        when %w[prefix unit]
          Unit.new(text(node["unit"]), prefix: Prefix.new(text(node["prefix"])))
        when %w[sqrt] then Sqrt.new(node["sqrt"])
        when %w[unit] then Unit.new(text(node["unit"]))
        else
          # The Parslet Transform leaves unmatched key combinations as raw
          # hashes with symbol keys (e.g. {sqrt:, sequence:}); mirror that.
          # Terminal slices (identifiable by their "value" key) keep their
          # string keys.
          node.key?("value") ? node : node.transform_keys(&:to_sym)
        end
      end

      def text(slice)
        slice.is_a?(Hash) ? slice.fetch("value") : slice.to_s
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def set_to_fence(set)
        return set if set.is_a?(Fenced)

        Fenced.new("(", set, ")")
      end
    end
  end
end
