# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Unit do
  describe "#to_mathml" do
    subject(:result) { unit.to_mathml({}) }

    context "with a bare SI unit" do
      let(:unit) { described_class.new("m") }

      it "returns an mi method_name" do
        expect(result[:method_name]).to eq(:mi)
      end

      it "returns an Mml::V4::Mi value" do
        expect(result[:value]).to be_a(Mml::V4::Mi)
      end
    end

    context "with a prefixed unit (milli + meter)" do
      let(:prefix) { Unitsml::Prefix.new("m") }
      let(:unit) { described_class.new("m", nil, prefix: prefix) }

      it "returns an mi method_name" do
        expect(result[:method_name]).to eq(:mi)
      end

      it "returns an Mml::V4::Mi value carrying both prefix and unit content" do
        value = result[:value]
        expect(value).to be_a(Mml::V4::Mi)
        combined = Array(value.value).join
        expect(combined).to include("m")
      end
    end

    context "with a power numerator" do
      let(:unit) { described_class.new("m", Unitsml::Number.new("2")) }

      it "returns an msup method_name" do
        expect(result[:method_name]).to eq(:msup)
      end

      it "returns an Mml::V4::Msup value" do
        expect(result[:value]).to be_a(Mml::V4::Msup)
      end
    end
  end
end
