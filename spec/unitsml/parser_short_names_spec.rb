# frozen_string_literal: true

require "spec_helper"
require "asciiunits"

RSpec.describe Unitsml::Parser do
  %w[kstatfarad kstatampere].each do |input|
    it "retains the legacy symbol composition in #{input}" do
      expect(Unitsml.parse(input).to_asciimath).to eq(input)
    end
  end

  it "refuses older artifacts that retain accidental unit meanings" do
    stub_const("Asciiunits::VERSION", "0.1.6")

    message = /require asciiunits >= 0.1.8; loaded 0.1.6/
    expect { described_class.send(:load_artifact) }
      .to raise_error(Unitsml::Errors::PargLoadError, message)
  end

  {
    "newton_meter^2" => "N^2*m^2",
    "newton_meter_second^2" => "N^2*m^2*s^2",
    "kilogram_force_second_squared_per_meter^2" => "kgf^2*s^4*m^-2",
    "cubic_meter_per_kilogram^2" => "m^6*kg^2",
    "newton_meter^-2" => "N^-2*m^-2",
    "sqrt(newton_meter)" => "N^1/2*m^1/2",
  }.each do |input, expected|
    it "applies the complete compound's power in #{input}" do
      parser = described_class.new(input)
      formula = parser.parse
      reference = Unitsml.parse(expected)

      expect(formula.to_asciimath).to eq(expected)
      expect(formula.to_mathml).to eq(reference.to_mathml)
      expect(formula.to_xml).to eq(reference.to_xml)
      expect([parser.text, formula.norm_text]).to eq([input, input])
    end
  end

  it "retains the full newton-metre squared dimension vector" do
    xml = Moxml.parse("<root>#{Unitsml.parse('newton_meter^2').to_xml}</root>")
    dimension = xml.root.elements.find { |element| element.name == "Dimension" }

    powers = dimension.elements.to_h do |element|
      [element.name, element["powerNumerator"]]
    end
    expect(powers)
      .to eq("Length" => "4", "Mass" => "2", "Time" => "-4")
  end

  %w[meter- roentgen- poise- nautical_mile- tesla- gilbert-
     unified_atomic_mass_unit- hour- day- are- one-].each do |input|
    it "preserves the parse error for #{input}" do
      message = "[unitsml] Error: cannot parse #{input.inspect} " \
                "as a UnitsML expression."
      expect { Unitsml.parse(input) }
        .to raise_error(Unitsml::Errors::ParseError, message)
    end
  end
end
