RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse.to_plurimath }

  context "when plurimath is not required/installed" do
    let(:exp) { "unitsml(mm*s^-2)" }

    before do
      allow_any_instance_of(Unitsml::Formula).to receive(:require).with("plurimath").and_raise(LoadError)
    end

    it "raises an error when trying to use Plurimath" do
      expect { formula }.to raise_error(Unitsml::PlurimathLoadError)
    end
  end

  context "Unitsml example contains prefix and units" do
    let(:exp) { "unitsml(mm*s^-2)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("mm"),
          "normal"
        ),
        Plurimath::Math::Symbols::Cdot.new,
        Plurimath::Math::Function::Power.new(
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("s"),
            "normal"
          ),
          Plurimath::Math::Formula.new([
            Plurimath::Math::Symbols::Minus.new,
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
          Plurimath::Math::Symbols::Symbol.new("L"),
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
        Plurimath::Math::Symbols::Symbol.new("k"),
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
          Plurimath::Math::Symbols::Symbol.new("g"),
          "normal",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains 'um' crashing while LutaML-Model integration in Plurimath" do
    let(:exp) { "unitsml(um)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("&#xb5;m"),
          "normal",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end
end
