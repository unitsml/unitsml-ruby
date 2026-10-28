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

      expect(quantity.convert_to("m/s").value).to eq(Rational(1609344, 1000) / 3600)
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
end
