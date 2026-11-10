# frozen_string_literal: true

require "spec_helper"

# Unit-aware evaluation regressions (unitsml-ruby#82 R-A2/R-A3/R-A4): exact
# unlike-unit sums and differences, absolute-minus-difference scale and
# offsets, exact Integer division and exact fractional dimension vectors.
RSpec.describe Unitsml::Quantity do
  def q(unit, value = 1, **options)
    described_class.new(value: value, unit_expression: unit, **options)
  end

  def summary(quantity)
    [quantity.value, quantity.norm_text, quantity.scale]
  end

  describe "unlike-unit sums and differences" do
    it "converts the right operand into the left operand's unit exactly" do
      expect(summary(q("km") + q("m")))
        .to eq([Rational(1001, 1000), "km", :ratio])
      expect(summary(q("km") - q("m")))
        .to eq([Rational(999, 1000), "km", :difference])
      expect((q("mi") + q("km")).value).to eq(1 + Rational(125_000, 201_168))
      expect(((q("kV", 10) * q("A", 5)) + q("W", 50)).value)
        .to eq(Rational(1001, 20))
    end

    it "keeps same-unit arithmetic unconverted" do
      expect((q("m", 1) + q("m", 2)).value).to be(3)
      expect((q("m", 1.5) + q("m", 2)).value).to be(3.5)
    end

    it "subtracts absolute temperatures in different units at the endpoints" do
      difference = q("degC", 20) - q("K", Rational(5763, 20))
      expect(summary(difference)).to eq([5, "degC", :difference])
      expect(difference.convert_to("K").value).to eq(5)
    end

    it "still refuses a dimension mismatch" do
      expect { q("V") + q("s") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
      expect { q("m^(1/2)") + q("m") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
    end
  end

  describe "absolute minus difference" do
    let(:difference) { q("degC", 20) - q("degC", 15) }

    it "keeps the absolute scale and applies offsets at the endpoints" do
      shifted = q("degC", 20) - difference
      expect(summary(shifted)).to eq([15, "degC", :interval])
      expect(shifted.convert_to("K").value).to eq(Rational(5763, 20))
    end

    it "converts a difference operand without affine addends" do
      shifted = q("degC", 20) - difference.convert_to("K")
      expect(summary(shifted)).to eq([15, "degC", :interval])
      expect(summary(q("K", 300) - difference)).to eq([295, "K", :ratio])
    end

    it "adds a difference to an absolute value and sums differences" do
      expect(summary(q("degC", 20) + difference.convert_to("K")))
        .to eq([25, "degC", :interval])
      summed = difference + difference
      expect(summed.scale).to eq(:difference)
      expect(summed.convert_to("K").value).to eq(10)
    end
  end

  describe "Integer division" do
    it "is exact for Integer magnitudes" do
      expect((q("m", 1) / 2).value).to eql(Rational(1, 2))
      expect((q("m", 1) / q("s", 2)).value).to eql(Rational(1, 2))
      expect((q("m", 10) / 2).value).to be(5)
      expect((q("m", 1.0) / 2).value).to be(0.5)
    end
  end

  describe "fractional dimension algebra" do
    it "keeps fractional exponents exact" do
      expect(q("m^(1/2)").dimension_vector).to eq("Length" => Rational(1, 2))
      expect((q("m^(1/2)") * q("m^(1/2)")).dimension_vector)
        .to eq("Length" => 1)
      expect((q("J^(1/2)") * q("J^(1/2)")).dimension_vector)
        .to eq(q("J").dimension_vector)
    end
  end
end
