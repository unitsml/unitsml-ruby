# frozen_string_literal: true

module Unitsml
  module Xml
    # Owns the canonical post-processing applied to XML emitted by
    # Unitsml::Model::* before it is returned to callers. Previously
    # inlined as repeated `.gsub` chains at six call sites in
    # Unitsml::Utility — this module is the single source of truth.
    #
    # The chain has two logical phases:
    #   1. Decode XML entities that lutaml-model emitted but UnitsML
    #      consumers expect as raw characters (`&lt;` → `<`, etc.).
    #   2. Re-encode Unicode mathematical symbols (minus, dot operator)
    #      as numeric character references for downstream XML consumers
    #      that aren't guaranteed UTF-8 clean transport.
    module Formatter
      ENTITY_DECODINGS = {
        "&lt;" => "<",
        "&gt;" => ">",
        "&amp;" => "&",
      }.freeze

      UNIT_SYMBOL_ENCODINGS = {
        "−" => "&#x2212;",
        "⋅" => "&#x22c5;",
      }.freeze

      module_function

      # Full post-processing for UnitsML <Unit> XML: entity decode
      # followed by Unicode → numeric-reference encoding.
      def format_unit(xml)
        decoded = decode_entities(xml)
        encode_unit_symbols(decoded)
      end

      # Minimal post-processing for <Prefix> XML: only the ampersand
      # decode is needed (UnitsML prefix symbols never contain the
      # other reserved characters or Unicode math symbols).
      def format_prefix(xml)
        unfrozen(xml).force_encoding("UTF-8").gsub("&amp;", "&")
      end

      def decode_entities(xml)
        buffer = unfrozen(xml).force_encoding("UTF-8")
        ENTITY_DECODINGS.reduce(buffer) do |acc, (from, to)|
          acc.gsub(from, to)
        end
      end

      def encode_unit_symbols(xml)
        UNIT_SYMBOL_ENCODINGS.reduce(xml) do |buffer, (from, to)|
          buffer.gsub(from, to)
        end
      end

      def unfrozen(xml)
        xml.frozen? ? xml.dup : xml
      end
      private_class_method :unfrozen
    end
  end
end
