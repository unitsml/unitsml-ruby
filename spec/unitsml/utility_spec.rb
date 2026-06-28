# frozen_string_literal: true

require "spec_helper"

# Exercises combine_prefixes through the public Utility surface. The
# function returns one of three shapes:
#   - nil when both inputs are nil/unknown
#   - String (the resolved symbolid or UNKNOWN) when combining fails
#   - Unitsml::Prefix when combining succeeds
RSpec.describe Unitsml::Utility do
  subject(:result) { described_class.combine_prefixes(left, right) }

  before { Unitsml::Unitsdb.database }

  context "when both inputs are nil" do
    let(:left) { nil }
    let(:right) { nil }

    it { is_expected.to be_nil }
  end

  context "when only one input is present" do
    let(:left) { "m" }
    let(:right) { nil }

    it "returns the resolved symbolid" do
      expect(result).to eq("m")
    end
  end

  context "when combining prefixes of mismatched bases" do
    let(:left) { "k" } # kilo, base 10
    let(:right) { "Mi" } # mebi, base 2

    it "returns UNKNOWN" do
      expect(result).to eq(Unitsml::Utility::UNKNOWN)
    end
  end

  context "when combining produces a known prefix" do
    let(:left) { "k" } # kilo (10^3)
    let(:right) { "k" } # kilo (10^3) → 10^6 = mega

    it "returns the resolved Prefix" do
      expect(result).to be_a(Unitsml::Prefix)
      expect(result.prefix_name).to eq("M")
    end
  end

  context "when combining milli and kilo" do
    let(:left) { "m" }  # milli (10^-3)
    let(:right) { "k" } # kilo  (10^3) → 10^0 = unity

    it "combines to unity" do
      expect(result).to be_a(Unitsml::Prefix)
      expect(result.prefix_name).to eq("1")
    end
  end

  context "when combining produces a non-existent power" do
    let(:left) { "m" }  # milli (10^-3)
    let(:right) { "c" } # centi (10^-2) → 10^-5 (no SI prefix)

    it "returns UNKNOWN" do
      expect(result).to eq(Unitsml::Utility::UNKNOWN)
    end
  end
end
