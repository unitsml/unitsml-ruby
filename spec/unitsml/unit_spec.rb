require "spec_helper"

RSpec.describe Unitsml::Unit do
  describe ".find_unit" do
    subject(:find_unit) { described_class.find_unit(ascii: unit_symbol) }

    context 'when existing symbol' do
      let(:unit_symbol) { :NISTu1 }

      it 'returns instance of Unitsml::Unit' do
        expect(find_unit).to(be_instance_of(Unitsml::Unit))
        expect(find_unit.short).to(eq("meter"))
      end
    end

    context 'when non existing symbol' do
      let(:unit_symbol) { :random_name }

      it 'returns nil' do
        expect(find_unit).to(be_nil)
      end
    end
  end
end