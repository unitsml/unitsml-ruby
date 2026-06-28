# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::PrefixAdapter do
  describe ".wrap" do
    context "with nil" do
      it "returns a null adapter" do
        adapter = described_class.wrap(nil)

        expect(adapter).to be_null
        expect(adapter.base).to be_nil
        expect(adapter.power).to be_nil
        expect(adapter.symbolid).to be_nil
      end
    end

    context "with a Unitsml::Prefix instance" do
      it "wraps it directly and exposes symbolid/base/power" do
        prefix = Unitsml::Prefix.new("m") # milli

        adapter = described_class.wrap(prefix)

        expect(adapter).not_to be_null
        expect(adapter.raw).to eq(prefix)
        expect(adapter.base).to eq(prefix.base)
        expect(adapter.power).to eq(prefix.power)
        expect(adapter.symbolid).to eq(prefix.symbolid)
      end
    end

    context "with a String name" do
      it "resolves the name to a Unitsml::Prefix when known" do
        adapter = described_class.wrap("m")

        expect(adapter).not_to be_null
        expect(adapter.raw).to be_a(Unitsml::Prefix)
        expect(adapter.raw.prefix_name).to eq("m")
      end

      it "returns a null adapter for an unknown name" do
        adapter = described_class.wrap("not-a-real-prefix")

        expect(adapter).to be_null
      end
    end

    context "with an already-adapted value" do
      it "returns the same adapter" do
        prefix = Unitsml::Prefix.new("m")
        adapter = described_class.wrap(prefix)

        expect(described_class.wrap(adapter)).to equal(adapter)
      end
    end

    context "with an unrecognized type" do
      it "returns a null adapter" do
        adapter = described_class.wrap(Object.new)

        expect(adapter).to be_null
      end
    end
  end

  describe "#prefix_name" do
    it "returns prefix_name when raw is a Unitsml::Prefix" do
      prefix = Unitsml::Prefix.new("m")

      expect(described_class.wrap(prefix).prefix_name).to eq("m")
    end
  end
end
