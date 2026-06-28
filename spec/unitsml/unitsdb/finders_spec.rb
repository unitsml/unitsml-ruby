# frozen_string_literal: true

require "spec_helper"

# Lightweight value objects that satisfy the Finders interface without
# pulling in real Unitsdb models. Defined at file top-level so they
# stay stable across the suite.
FinderTestItem = Struct.new(:id, :name, :identifiers, keyword_init: true)
FinderTestIdentifier = Struct.new(:id, :type, keyword_init: true)

RSpec.describe Unitsml::Unitsdb::Finders do
  let(:host_class) do
    Class.new do
      include Unitsml::Unitsdb::Finders
    end
  end

  let(:host) { host_class.new }
  let(:collection) do
    [
      FinderTestItem.new(
        id: "outer-1",
        name: "first",
        identifiers: [FinderTestIdentifier.new(id: "NISTu1", type: "nist")],
      ),
      FinderTestItem.new(
        id: "outer-2",
        name: "second",
        identifiers: [
          FinderTestIdentifier.new(id: "NISTu2", type: "nist"),
          FinderTestIdentifier.new(id: "u:meter", type: "unitsml"),
        ],
      ),
    ]
  end

  describe "#find_first_in" do
    it "returns the first item where item.<field> == value" do
      found = host.find_first_in(collection, field: :id, value: "outer-2")
      expect(found.name).to eq("second")
    end

    it "returns nil when no item matches" do
      found = host.find_first_in(collection, field: :id, value: "missing")
      expect(found).to be_nil
    end
  end

  describe "#find_first_through" do
    it "finds via a nested list element matching field" do
      found = host.find_first_through(collection,
                                      via: :identifiers,
                                      field: :id,
                                      value: "u:meter")
      expect(found.name).to eq("second")
    end

    it "returns nil when no nested element matches" do
      found = host.find_first_through(collection,
                                      via: :identifiers,
                                      field: :id,
                                      value: "nope")
      expect(found).to be_nil
    end
  end
end
