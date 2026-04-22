# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Unit do
  describe "#to_mathml" do
    let(:mathml) { '<mi mathvariant="normal">m</mi>' }
    let(:prefix) { instance_double(Unitsml::Prefix) }
    let(:unit) { described_class.new("m", nil, prefix: prefix) }
    let(:parsed_unit) { instance_double(ParsedUnitSymbol, value: ["m"]) }
    let(:updated_value) { instance_double(UpdatedMathmlValue) }

    before do
      stub_const("ParsedUnitSymbol", Class.new)
      stub_const("UpdatedMathmlValue", Class.new)
      stub_const("UnitSymbol", Class.new)

      allow(unit).to receive(:unit_symbols).and_return(unit_symbol)
      allow(unit).to receive(:mml_v4_from_xml).with("mi", mathml)
        .and_return(parsed_unit)
      allow(prefix).to receive(:to_mathml)
        .with(hash_including(parent: parsed_unit))
        .and_return("m")
      allow(unit).to receive(:mml_v4_with_content)
        .with(parsed_unit, "mm")
        .and_return(updated_value)
    end

    def unit_symbol
      instance_double(UnitSymbol, mathml: mathml)
    end

    it "joins parsed token collections before prefix concatenation" do
      expect(unit.to_mathml({})).to eq(method_name: :mi, value: updated_value)
    end
  end
end
