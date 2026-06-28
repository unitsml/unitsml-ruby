# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Errors::UnsupportedPayloadTypeError do
  it "is a BaseError" do
    expect(described_class).to be < Unitsml::Errors::BaseError
  end

  it "mentions the offending class in the message" do
    error = described_class.new(Hash)

    expect(error.message).to include("Hash")
    expect(error.message).to include("PayloadGenerator")
  end
end
