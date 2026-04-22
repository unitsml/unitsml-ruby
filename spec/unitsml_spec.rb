# frozen_string_literal: true

RSpec.describe Unitsml do
  it "has a version number" do
    expect(Unitsml::VERSION).not_to be_nil
  end

  it "parses a basic unit expression" do
    formula = described_class.parse("mm")
    expect(formula).to be_a(Unitsml::Formula)
    expect(formula.to_latex).to eq("m\\ensuremath{\\mathrm{m}}")
  end
end
