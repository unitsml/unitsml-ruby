require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(K/(kg*m))" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(m, quantity: NISTq103)" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(cal_th/cm^2, name: langley)" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(m, symbol: La)" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(cm*s^-2, symbol: cm cdot s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(cm*s^-2, multiplier: xx)" }

    it "returns parslet tree of parsed Unitsml string" do
      skip "Changes to implement yet"
    end
  end
end
