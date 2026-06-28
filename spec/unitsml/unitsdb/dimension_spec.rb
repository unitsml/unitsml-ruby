# frozen_string_literal: true

require "spec_helper"

def build_dimension_details(symbol:, power:)
  Unitsdb::DimensionDetails.new(
    symbol: symbol,
    power: power,
    symbols: [
      Unitsdb::SymbolPresentations.new(
        id: "dim_#{symbol}",
        ascii: symbol,
      ),
    ],
  )
end

RSpec.describe Unitsml::Unitsdb::Dimension do
  let(:identifiers) do
    [Unitsdb::Identifier.new(id: "NISTd1", type: "nist")]
  end

  def dimension_with_three_quantities
    length = build_dimension_details(symbol: "L", power: 1)
    mass = build_dimension_details(symbol: "M", power: 1)
    time = build_dimension_details(symbol: "T", power: 1)
    dimension = described_class.new(identifiers: identifiers)
    dimension.length = length
    dimension.mass = mass
    dimension.time = time
    [dimension, length, mass, time]
  end

  describe "quantity setters" do
    it "registers length, mass, and time quantities" do
      dimension = described_class.new(identifiers: identifiers)
      dimension.length = build_dimension_details(symbol: "L", power: 1)
      dimension.mass = build_dimension_details(symbol: "M", power: 1)
      dimension.time = build_dimension_details(symbol: "T", power: 1)

      expect(dimension.processed_keys)
        .to contain_exactly("length", "mass", "time")
    end

    it "exposes each quantity via a reader matching its setter" do
      dimension, length, mass, time = dimension_with_three_quantities
      expect(dimension.length).to eq(length)
      expect(dimension.mass).to eq(mass)
      expect(dimension.time).to eq(time)
    end

    it "ignores nil values without recording a processed key" do
      dimension = described_class.new(identifiers: identifiers)
      dimension.length = nil

      expect(dimension.length).to be_nil
      expect(dimension.processed_keys).to be_empty
    end

    it "handles every quantity key" do
      keys = described_class::QUANTITY_KEYS
      dimension = described_class.new(identifiers: identifiers)

      keys.each do |key|
        dimension.public_send("#{key}=",
                              build_dimension_details(symbol: "X", power: 1))
      end

      expect(dimension.processed_keys).to match_array(keys.map(&:to_s))
    end
  end

  describe "#dim_symbols" do
    it "collects the dim symbol ids across processed keys" do
      dimension = described_class.new(identifiers: identifiers)
      dimension.length = build_dimension_details(symbol: "L", power: 1)
      dimension.mass = build_dimension_details(symbol: "M", power: 1)

      expect(dimension.dim_symbols).to contain_exactly("dim_L", "dim_M")
    end
  end

  describe "#processed_symbol" do
    it "returns the symbol of the first processed quantity" do
      dimension = described_class.new(identifiers: identifiers)
      dimension.length = build_dimension_details(symbol: "L", power: 1)

      expect(dimension.processed_symbol).to eq("L")
    end
  end

  describe "#set_vector" do
    it "joins the powers of each dimension quantity in DIMS_VECTOR order" do
      dimension = described_class.new(identifiers: identifiers)
      dimension.length = build_dimension_details(symbol: "L", power: 1)
      dimension.mass = build_dimension_details(symbol: "M", power: 2)

      # DIMS_VECTOR order: ThermodynamicTemperature, AmountOfSubstance,
      # LuminousIntensity, ElectricCurrent, PlaneAngle, Length, Mass, Time
      # Unset dimensions contribute nil (blank).
      expect(dimension.set_vector).to eq(":::::1:2:")
    end
  end

  describe "#id" do
    it "returns the NIST identifier id" do
      dimension = described_class.new(identifiers: identifiers)

      expect(dimension.id).to eq("NISTd1")
    end

    it "returns nil when no NIST identifier is present" do
      dimension = described_class.new(
        identifiers: [Unitsdb::Identifier.new(id: "u:dim_1",
                                              type: "unitsml")],
      )

      expect(dimension.id).to be_nil
    end
  end
end
