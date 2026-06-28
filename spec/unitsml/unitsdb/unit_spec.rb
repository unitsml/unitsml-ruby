# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Unitsdb::Unit do
  describe "#en_name" do
    it "returns the value of the English name" do
      unit = described_class.new(
        names: [
          Unitsdb::LocalizedString.new(value: "meter", lang: "en"),
          Unitsdb::LocalizedString.new(value: "mètre", lang: "fr"),
        ],
      )

      expect(unit.en_name).to eq("meter")
    end

    it "returns nil when no English name is present" do
      unit = described_class.new(
        names: [Unitsdb::LocalizedString.new(value: "mètre", lang: "fr")],
      )

      expect(unit.en_name).to be_nil
    end
  end

  describe "#nist_id" do
    it "returns the id of the NIST identifier" do
      unit = described_class.new(
        identifiers: [
          Unitsdb::Identifier.new(id: "NISTu1", type: "nist"),
          Unitsdb::Identifier.new(id: "u:meter", type: "unitsml"),
        ],
      )

      expect(unit.nist_id).to eq("NISTu1")
    end

    it "returns nil when no NIST identifier is present" do
      unit = described_class.new(
        identifiers: [
          Unitsdb::Identifier.new(id: "u:meter", type: "unitsml"),
        ],
      )

      expect(unit.nist_id).to be_nil
    end
  end

  describe "#dimension_url" do
    it "resolves the dimension id through the first quantity reference" do
      unit = described_class.new(
        quantity_references: [
          Unitsdb::QuantityReference.new(id: "NISTq1", type: "nist"),
        ],
      )

      # NISTq1 (length) is seeded in the bundled unitsdb data and
      # points at NISTd1 (the Length dimension).
      expect(unit.dimension_url).to eq("NISTd1")
    end

    it "returns nil when quantity_references is empty" do
      unit = described_class.new(quantity_references: [])

      expect(unit.dimension_url).to be_nil
    end
  end
end
