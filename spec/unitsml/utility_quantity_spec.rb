# frozen_string_literal: true

require "spec_helper"

# Quantity-engine fix: resolve quantities by name/short (not only by id),
# emit a canonical NIST xml:id + the record's quantityType, and reference the
# emitted <Dimension> for composites. Scoped to the explicit-quantity path so
# the auto-emitted single-unit quantities stay byte-identical.
RSpec.describe "Unitsml quantity engine" do # rubocop:disable RSpec/DescribeClass
  describe "Unitsml::Unitsdb::Quantities#find_by_name" do
    subject(:quantities) { Unitsml::Unitsdb.quantities }

    it "resolves an English name to its record" do
      expect(quantities.find_by_name("radiance")&.short).to eq("radiance")
    end

    it "is case-insensitive" do
      expect(quantities.find_by_name("Radiance")&.short).to eq("radiance")
    end

    it "returns nil for blank input" do
      expect(quantities.find_by_name("")).to be_nil
      expect(quantities.find_by_name(nil)).to be_nil
    end

    it "returns nil for an unknown name" do
      expect(quantities.find_by_name("bogus")).to be_nil
    end
  end

  describe "Unitsml::Utility.quantity_instance" do
    it "resolves by NIST id" do
      record = Unitsml::Utility.quantity_instance("NISTq89")
      expect(record&.short).to eq("radiance")
    end

    it "falls back to name resolution" do
      record = Unitsml::Utility.quantity_instance("radiance")
      expect(record&.short).to eq("radiance")
    end

    it "returns nil for a nil id" do
      expect(Unitsml::Utility.quantity_instance(nil)).to be_nil
    end
  end

  describe "composite <Quantity> for an explicit quantity" do
    let(:by_name) do
      Unitsml.parse("W*m^-1*sr^-1, quantity: radiance").to_xml
    end

    it "emits a canonical <Quantity> (NIST id, type, dimensionURL)" do
      expect(by_name).to include('xml:id="NISTq89"')
      expect(by_name).to include('quantityType="derived"')
      expect(by_name).to include('dimensionURL="#D_LMT-3"')
      expect(by_name).to include(
        '<QuantityName xml:lang="en">radiance</QuantityName>',
      )
    end

    it "resolves by case-insensitive name, NIST id, or unitsml id alike" do
      %w[Radiance NISTq89 q:radiance].each do |ref|
        xml = Unitsml.parse("W*m^-1*sr^-1, quantity: #{ref}").to_xml
        expect(xml).to eq(by_name)
      end
    end
  end

  describe "regression: no explicit quantity given" do
    it "keeps an auto-emitted single-unit <Quantity> as base" do
      hz = Unitsml.parse("Hz").to_xml
      expect(hz).to include('xml:id="NISTq45"')
      expect(hz).to include('quantityType="base"')
      expect(hz).to include('dimensionURL="#NISTd24"')
    end

    it "emits no <Quantity> without a single quantity reference" do
      expect(Unitsml.parse("W").to_xml).not_to include("<Quantity")
      expect(Unitsml.parse("rad").to_xml).not_to include("<Quantity")
    end
  end
end
