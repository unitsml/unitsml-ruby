# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Unit do
  describe "#to_mathml" do
    it "joins parsed token collections before prefix concatenation" do
      unit = described_class.new("m", nil, prefix: instance_double(Unitsml::Prefix))
      parsed_unit = instance_double("ParsedUnitSymbol", value: ["m"])
      updated_value = instance_double("UpdatedMathmlValue")

      allow(unit).to receive(:unit_symbols).and_return(
        instance_double("UnitSymbol", mathml: '<mi mathvariant="normal">m</mi>'),
      )
      allow(unit).to receive(:mml_v4_from_xml).with("mi", '<mi mathvariant="normal">m</mi>')
        .and_return(parsed_unit)
      allow(unit.prefix).to receive(:to_mathml).with(hash_including(parent: parsed_unit)).and_return("m")
      allow(unit).to receive(:mml_v4_with_content).with(parsed_unit, "mm").and_return(updated_value)

      expect(unit.to_mathml({})).to eq(method_name: :mi, value: updated_value)
    end
  end
end
