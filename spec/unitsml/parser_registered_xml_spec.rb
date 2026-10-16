# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe Unitsml::Parser do
  let(:namespaces) { { "u" => "https://schema.unitsml.org/unitsml/1.0" } }

  it "exports every root of a newly accepted registered-symbol product" do
    formula = described_class.new("unitsml(dB*m)").parse
    document = Nokogiri::XML("<records>#{formula.to_xml}</records>")
    roots = document.xpath("//u:EnumeratedRootUnit", namespaces)
    expect(roots.map { |root| [root["unit"], root["prefix"]] })
      .to eq([["bel", "d"], ["meter", nil]])
    expect(formula.value.first).to eq(Unitsml::Unit.new("dB"))
  end

  it "exports a legal XML ID for a newly accepted fractional power" do
    formula = described_class.new("unitsml(dB^(1/2))").parse
    document = Nokogiri::XML("<records>#{formula.to_xml}</records>")
    expect(document.at_xpath("/records/u:Unit", namespaces)["xml:id"])
      .to eq("EncodedUnit_555f6442312f32")
  end
end
