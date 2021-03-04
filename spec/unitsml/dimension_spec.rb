require "spec_helper"

RSpec.describe Unitsml::Dimension do
  describe ".find_dimension" do
    subject(:find_dimension) { described_class.find_dimension(ascii: dimension_symbol) }

    context 'when existing symbol' do
      let(:dimension_symbol) { :NISTd1 }

      it 'returns instance of Unitsml::Dimension' do
        expect(find_dimension).to(be_instance_of(Unitsml::Dimension))
        expect(find_dimension.id).to(eq("NISTd1"))
      end
    end

    context 'when non existing symbol' do
      let(:dimension_symbol) { :random_name }

      it 'returns nil' do
        expect(find_dimension).to(be_nil)
      end
    end
  end

  describe ".from_yaml" do
    subject(:from_yaml) { described_class.from_yaml(yaml_path) }

    let(:yaml_path) { fixtures_path('dimensions_test.yaml') }

    it "loads symbols files and uses it for lookup" do
      expect { from_yaml }.to change { described_class.symbols.length }.to(3)
      expect(described_class.symbols.map(&:id)).to(eq(%w[NISTd1 NISTd2 NISTd3]))
    end
  end
end