# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Quantity do
  describe "R-A1: quantity construction" do
    it "constructs from any UnitsDB unit expression" do
      q = described_class.new(value: 10, unit_expression: "kV")

      expect(q.value).to eq(10)
      expect(q.formula).to be_a(Unitsml::Formula)
    end

    it "constructs a pure number without a unit" do
      expect(described_class.new(value: 5).dimension_id).to be_nil
    end
  end

  describe "R-A2: dimension algebra" do
    it "multiplies kV and A into the watt class" do
      kv = described_class.new(value: 10, unit_expression: "kV")
      a = described_class.new(value: 5, unit_expression: "A")
      w = described_class.new(value: 50, unit_expression: "W")

      expect(kv * a).to eq(w)
    end

    it "raises a typed mismatch on V + s" do
      v = described_class.new(value: 1, unit_expression: "V")
      s = described_class.new(value: 1, unit_expression: "s")

      expect { v + s }.to raise_error(Unitsml::Errors::DimensionMismatchError)
    end

    it "divides into composed units" do
      j = described_class.new(value: 12, unit_expression: "J")
      s = described_class.new(value: 4, unit_expression: "s")

      expect(j / s).to eq(described_class.new(value: 3, unit_expression: "J/s"))
    end
  end

  describe "R-A4: the scale law (skeleton gate)" do
    it "rejects multiplication on an interval-scale quantity" do
      c = described_class.new(value: 10, unit_expression: "m", scale: :interval)

      expect { c * 2 }.to raise_error(Unitsml::Errors::ScaleOperationError)
    end

    it "allows differences on interval scales" do
      a = described_class.new(value: 10, unit_expression: "m", scale: :interval)
      b = described_class.new(value: 4, unit_expression: "m", scale: :interval)

      expect((a - b).value).to eq(6)
    end
  end

  describe "R-A5: result taxonomy" do
    it "maps division by a zero quantity to the indeterminate class" do
      m = described_class.new(value: 1, unit_expression: "m")
      zero = described_class.new(value: 0, unit_expression: "s")

      expect { m / zero }
        .to raise_error(Unitsml::Errors::IndeterminateResultError)
    end
  end

  describe "arithmetic" do
    it "adds like quantities" do
      a = described_class.new(value: 3, unit_expression: "m")
      b = described_class.new(value: 2, unit_expression: "m")

      expect((a + b).value).to eq(5)
    end

    it "keeps the composed expression through chained operations" do
      a = described_class.new(value: 3, unit_expression: "m")
      b = described_class.new(value: 2, unit_expression: "s")

      expect((a / b).norm_text).to eq("m/s")
    end
  end
end
