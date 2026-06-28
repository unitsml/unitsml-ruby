# frozen_string_literal: true

module Unitsml
  module Unitsdb
    # Shared lookup helpers for Unitsml collection wrappers. Each host
    # collection (Units, Prefixes, Dimensions) keeps its own public
    # find_by_* API; this module owns the two scanning shapes that the
    # host implementations previously duplicated.
    module Finders
      # Find the first item in `collection` where `item.<field> == value`.
      def find_first_in(collection, field:, value:)
        collection.find { |item| item.public_send(field) == value }
      end

      # Find the first item in `collection` where `item.<via>` contains
      # an element whose `<field>` equals `value`. Used for collections
      # of items that expose a nested list of identifiers or symbols.
      def find_first_through(collection, via:, field:, value:)
        collection.find do |item|
          item.public_send(via).any? do |inner|
            inner.public_send(field) == value
          end
        end
      end
    end
  end
end
