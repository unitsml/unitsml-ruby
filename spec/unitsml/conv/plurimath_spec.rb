RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse.to_plurimath }

  context "Unitsml example contains prefix and units" do
    let(:exp) { "unitsml(mm*s^-2)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbol.new("mm"),
          "normal"
        ),
        Plurimath::Math::Symbol.new("&#x22c5;"),
        Plurimath::Math::Function::Power.new(
          Plurimath::Math::Formula.new([
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbol.new("s"),
              "normal"
            )
          ]),
          Plurimath::Math::Formula.new([
            Plurimath::Math::Symbol.new("&#x2212;"),
            Plurimath::Math::Number.new("2")
          ])
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains dimension only" do
    let(:exp) { "unitsml(dim_L)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::SansSerif.new(
          Plurimath::Math::Symbol.new("L"),
          "sans-serif",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains prefix only" do
    let(:exp) { "unitsml(k-)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Symbol.new("k"),
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains unit only" do
    let(:exp) { "unitsml(g)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Function::G.new,
          "normal",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end
end
