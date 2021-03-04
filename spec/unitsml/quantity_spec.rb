require "spec_helper"

RSpec.describe Unitsml::Quantity do
  describe ".find_quantity" do
    subject(:find_quantity) { described_class.find_quantity(ascii: unit_symbol) }

    context 'when existing symbol' do
      let(:unit_symbol) { "NISTq48" }

      it 'returns instance of Unitsml::Unit' do
        expect(find_quantity).to(be_instance_of(described_class))
        expect(find_quantity.id).to(eq(unit_symbol))
        expect(find_quantity.units.first).to(be_instance_of(Unitsml::Unit))
      end
    end

    context 'when non existing symbol' do
      let(:unit_symbol) { :random_name }

      it 'returns nil' do
        expect(find_quantity).to(be_nil)
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