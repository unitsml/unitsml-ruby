# frozen_string_literal: true

module Unitsml
  module Compose
    # Single source of truth for the compose term-tree shape, so every traversal
    # (deep-copy, inversion, unit/dimension detection) is written once, not
    # re-encoded per traversal. The tree is:
    #   Array               -> each element is a node
    #   Formula             -> branch over its `value` array
    #   Fenced, Sqrt        -> branch over a single `value`
    #   Unit, Dimension,
    #   Extender, Number... -> leaf
    module TermTree
      module_function

      # Visit every leaf depth-first (branches are traversed, not yielded).
      # Returns the node unchanged — this is a walk for side effects on leaves.
      def each_leaf(node, &block)
        case node
        when Array then node.each { |child| each_leaf(child, &block) }
        when Formula, Fenced, Sqrt then each_leaf(node.value, &block)
        else yield node
        end
        node
      end

      # Rebuild the branch structure, replacing each leaf with the block's
      # result. Branches are always reconstructed, so the original is untouched.
      def map_leaves(node, &block)
        case node
        when Array then node.map { |child| map_leaves(child, &block) }
        when Formula then map_formula(node, &block)
        when Fenced
          Fenced.new(node.open_paren, map_leaves(node.value, &block),
                     node.close_paren)
        when Sqrt then Sqrt.new(map_leaves(node.value, &block))
        else yield node
        end
      end

      def map_formula(formula, &block)
        copy = formula.dup
        copy.value = map_leaves(formula.value, &block)
        copy
      end
    end
  end
end
