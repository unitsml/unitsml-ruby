# frozen_string_literal: true

require "spec_helper"

# Rendering must use the unit's primary quantity reference (UnitsDB schema
# 2.2.0 `primary` flag), not the first entry in YAML order. For rad the first
# entry is NISTd98's quantity, while the primary is plane angle (NISTd9).
RSpec.describe "Primary quantity reference rendering" do # rubocop:disable RSpec/DescribeClass
  it "derives the unit dimension from the primary reference (rad)" do
    xml = Unitsml.parse("rad").to_xml

    expect(xml).to match(%r{<Dimension [^>]*xml:id="NISTd9"})
    expect(xml).not_to include("NISTd98")
  end

  it "lets an explicit caller-supplied quantity win over the primary" do
    xml = Unitsml::Utility.quantity("J", "NISTq152")

    expect(xml).to include('xml:id="NISTq152"')
    expect(xml).not_to include('xml:id="NISTq17"')
  end
end
