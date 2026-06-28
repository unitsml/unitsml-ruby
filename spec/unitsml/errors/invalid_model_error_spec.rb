# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Errors::InvalidModelError do
  it "is a BaseError" do
    expect(described_class).to be < Unitsml::Errors::BaseError
  end

  it "mentions the offending class and its superclass in the message" do
    klass = Class.new(Unitsdb::Unit)
    def klass.name = "OffendingUnitClass"

    error = described_class.new(klass)

    expect(error.message).to include("OffendingUnitClass")
    expect(error.message).to include("Unitsdb::Unit")
  end
end
