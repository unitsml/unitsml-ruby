require "spec_helper"

RSpec.describe Unitsml::Unit do
  describe ".find_unit" do
    subject(:find_unit) { described_class.find_unit(ascii: unit_symbol) }

    context 'when existing symbol' do
      let(:unit_symbol) { "mL" }

      it 'returns instance of Unitsml::Unit' do
        expect(find_unit).to(be_instance_of(Unitsml::Unit))
        expect(find_unit.short).to(eq("milliliter"))
        expect(find_unit.symbols.first).to(be_instance_of(Unitsml::UnitSymbol))
        expect(find_unit.to_latex).to(eq("\\ensuremath{\\mathrm{mL}}\\ensuremath{\\mathrm{ml}}"))
      end
    end

    context 'when non existing symbol' do
      let(:unit_symbol) { :random_name }

      it 'returns nil' do
        expect(find_unit).to(be_nil)
      end
    end
  end

  describe ".from_yaml" do
    subject(:from_yaml) { described_class.from_yaml(yaml_path) }

    let(:yaml_path) { fixtures_path('units_test.yaml') }

    it "loads symbols files and uses it for lookup" do
      expect { from_yaml }.to change { described_class.symbols.length }.to(2)
      expect(described_class.symbols.map(&:id)).to(eq(%w[test1 test2]))
    end
  end
end