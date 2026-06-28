# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Xml::Formatter do
  describe ".format_unit" do
    it "decodes XML entities into raw characters" do
      xml = "&lt;Unit&gt;named &amp; measured"

      expect(described_class.format_unit(xml))
        .to eq("<Unit>named & measured")
    end

    it "encodes Unicode minus as a numeric character reference" do
      xml = "x − y"

      expect(described_class.format_unit(xml)).to include("&#x2212;")
      expect(described_class.format_unit(xml)).not_to include("−")
    end

    it "encodes Unicode dot operator as a numeric character reference" do
      xml = "a ⋅ b"

      expect(described_class.format_unit(xml)).to include("&#x22c5;")
      expect(described_class.format_unit(xml)).not_to include("⋅")
    end

    it "forces the encoding to UTF-8" do
      xml = "plain".encode("US-ASCII")

      expect(described_class.format_unit(xml).encoding).to eq(Encoding::UTF_8)
    end

    it "preserves already-encoded numeric character references" do
      xml = "&#x2212;"

      expect(described_class.format_unit(xml)).to eq("&#x2212;")
    end
  end

  describe ".format_prefix" do
    it "decodes only the ampersand entity" do
      xml = "milli &amp; micro"

      expect(described_class.format_prefix(xml)).to eq("milli & micro")
    end

    it "leaves other entities untouched" do
      xml = "&lt;prefix&gt;"

      expect(described_class.format_prefix(xml)).to eq("&lt;prefix&gt;")
    end

    it "forces the encoding to UTF-8" do
      xml = "m".encode("US-ASCII")

      expect(described_class.format_prefix(xml).encoding).to eq(Encoding::UTF_8)
    end
  end

  describe ".decode_entities" do
    it "applies all three decodings in sequence" do
      xml = "a &lt; b &amp; c &gt; d"

      expect(described_class.decode_entities(xml)).to eq("a < b & c > d")
    end
  end

  describe ".encode_unit_symbols" do
    it "encodes both minus and dot operator" do
      xml = "− and ⋅"

      encoded = described_class.encode_unit_symbols(xml)
      expect(encoded).to include("&#x2212;")
      expect(encoded).to include("&#x22c5;")
    end
  end
end
