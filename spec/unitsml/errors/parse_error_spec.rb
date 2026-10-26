# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Errors::ParseError do
  it "is a BaseError" do
    expect(described_class).to be < Unitsml::Errors::BaseError
  end

  it "is what Unitsml.parse raises for text that is not UnitsML" do
    expect { Unitsml.parse("zz") }.to raise_error(described_class) do |error|
      expect(error.text).to eq("zz")
      expect(error.message).to include('"zz"')
      expect(error.cause).to be_a(Parsanol::ParseFailed)
    end
  end

  it "leaves valid input parsing as before" do
    expect(Unitsml.parse("m*s^-2")).to be_a(Unitsml::Formula)
  end
end
