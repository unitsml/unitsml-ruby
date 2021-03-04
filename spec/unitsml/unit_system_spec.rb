require "spec_helper"

RSpec.describe Unitsml::UnitSystem do
  describe ".find_unit_system_system" do
    subject(:find_unit_system) { described_class.find_unit_system(ascii: unit_symbol) }

    context 'when existing symbol' do
      let(:unit_symbol) { "SI_base" }

      it 'returns instance of Unitsml::UnitSystem' do
        expect(find_unit_system).to(be_instance_of(described_class))
        expect(find_unit_system.name).to(eq("SI"))
      end
    end

    context 'when non existing symbol' do
      let(:unit_symbol) { :random_name }

      it 'returns nil' do
        expect(find_unit_system).to(be_nil)
      end
    end
  end

  describe ".from_yaml" do
    subject(:from_yaml) { described_class.from_yaml(yaml_path) }

    let(:yaml_path) { fixtures_path("unit_systems_test.yaml") }

    it "loads symbols files and uses it for lookup" do
      expect { from_yaml }.to change { described_class.symbols.length }.to(2)
      expect(described_class.symbols.map(&:id)).to(eq(%w[test1 test2]))
    end
  end
end