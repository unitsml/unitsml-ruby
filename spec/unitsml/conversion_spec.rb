# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Conversion do
  describe "R-A3: conversion application" do
    it "converts an affine scale exactly (0 degC = 273.15 K)" do
      quantity = Unitsml::Quantity.new(value: 0, unit_expression: "degC")

      converted = quantity.convert_to("K")

      expect(converted.value).to eq(Rational(27315, 100))
      expect(converted.formula.norm_text).to eq("K")
    end

    it "converts 100 degC to 373.15 K" do
      quantity = Unitsml::Quantity.new(value: 100, unit_expression: "degC")

      expect(quantity.convert_to("K").value).to eq(Rational(37315, 100))
    end

    it "round-trips 32 degF through kelvin exactly" do
      quantity = Unitsml::Quantity.new(value: 32, unit_expression: "degF")

      expect(quantity.convert_to("K").value).to eq(Rational(27315, 100))
    end

    it "converts imperial lengths through the canonical factor" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "mi")

      expect(quantity.convert_to("m").value).to eq(Rational(1609344, 1000))
    end

    it "applies prefix factors (1 km = 1000 m)" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "km")

      expect(quantity.convert_to("m").value).to eq(1000)
    end

    it "applies pressure factors (2 bar = 200000 Pa)" do
      quantity = Unitsml::Quantity.new(value: 2, unit_expression: "bar")

      expect(quantity.convert_to("Pa").value).to eq(200_000)
    end

    it "converts derived compositions (1 kWh = 3600000 J)" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "kWh")

      expect(quantity.convert_to("J").value).to eq(3_600_000)
    end

    it "converts composites with inversions (1 mi/h in m/s)" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "mi/h")

      expect(quantity.convert_to("m/s").value).to eq(Rational(1609344,
                                                              1000) / 3600)
    end

    it "rejects dimension-incompatible targets" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "mi")

      expect { quantity.convert_to("s") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
    end

    it "rejects affine units raised to powers" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "degC^2")

      expect { quantity.convert_to("K^2") }
        .to raise_error(Unitsml::Errors::ConversionError)
    end

    it "rejects units without a canonical path" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "kn")

      expect { quantity.convert_to("m/s") }
        .to raise_error(Unitsml::Errors::ConversionError)
    end
  end

  describe "prefix and power scaling (unitsml-ruby#92)" do
    it "squares prefixed units: 1 km2 = 1 000 000 m2" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "km^2")

      expect(quantity.convert_to("m^2").value).to eq(Rational(1_000_000))
    end

    it "does not double-exponentiate the ft2 canonical factor" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "ft^2")

      expect(quantity.convert_to("m^2").value).to eq(Rational(145_161,
                                                              1_562_500))
    end

    it "scales prefixes with derived-unit powers: 1 cm3 = 1e-6 m3" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "cm^3")

      expect(quantity.convert_to("m^3").value).to eq(Rational(1, 1_000_000))
    end
  end

  describe "difference typing (unitsml-ruby#92)" do
    it "converts a degC difference to kelvin without the affine addend" do
      high = Unitsml::Quantity.new(value: 20, unit_expression: "degC")
      low = Unitsml::Quantity.new(value: 15, unit_expression: "degC")

      difference = (high - low).convert_to("K")

      expect(difference.value).to eq(Rational(5))
    end

    it "derives the interval scale from the unitsdb scale_reference" do
      quantity = Unitsml::Quantity.new(value: 20, unit_expression: "degC")

      expect(quantity.scale).to eq(:interval)
    end

    it "keeps the ratio scale for ratio units" do
      quantity = Unitsml::Quantity.new(value: 1, unit_expression: "m")

      expect(quantity.scale).to eq(:ratio)
    end

    it "marks differences as difference-typed" do
      high = Unitsml::Quantity.new(value: 20, unit_expression: "degC")
      low = Unitsml::Quantity.new(value: 15, unit_expression: "degC")

      expect((high - low).scale).to eq(:difference)
    end

    it "refuses scaling an interval-scaled quantity" do
      quantity = Unitsml::Quantity.new(value: 20, unit_expression: "degC")

      expect { quantity * 2 }
        .to raise_error(Unitsml::Errors::ScaleOperationError)
    end
  end
end
