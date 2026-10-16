# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe Unitsml::Formula do
  let(:namespaces) { { "u" => "https://schema.unitsml.org/unitsml/1.0" } }

  def formula_for(input, terms, explicit_value: nil)
    values = terms.each_with_object([]) do |(name, power), output|
      output << Unitsml::Extender.new("*") unless output.empty?
      output << Unitsml::Unit.new(name, power && Unitsml::Number.new(power))
    end
    described_class.new(
      values,
      explicit_value: explicit_value,
      root: true,
      orig_text: input,
      norm_text: input,
    )
  end

  def records_for(formula)
    Nokogiri::XML("<records>#{formula.to_xml}</records>") do |config|
      config.strict.nonet
    end
  end

  def root_attributes(document)
    attributes = %w[unit prefix powerNumerator powerDenominator]
    document.xpath("//u:EnumeratedRootUnit", namespaces).map do |node|
      attributes.map { |key| node[key] }
    end
  end

  [
    ["dB*m", [["dB", nil], ["m", nil]],
     [["bel", "d", nil, nil], ["meter", nil, nil, nil]]],
    ["dB/s", [["dB", nil], ["s", "-1"]],
     [["bel", "d", nil, nil], ["second", nil, "-1", nil]]],
    ["m/dB", [["m", nil], ["dB", "-1"]],
     [["meter", nil, nil, nil], ["bel", "d", "-1", nil]]],
    ["dB^(1/2)*s", [["dB", "1/2"], ["s", nil]],
     [["bel", "d", "1", "2"], ["second", nil, nil, nil]]],
    ["dB^(-2/3)*s", [["dB", "-2/3"], ["s", nil]],
     [["bel", "d", "-2", "3"], ["second", nil, nil, nil]]],
  ].each do |input, terms, expected_roots|
    it "preserves the database roots and exact powers in #{input}" do
      formula = formula_for(input, terms)
      document = records_for(formula)
      expect(root_attributes(document)).to eq(expected_roots)
      expect(document.at_xpath("/records/u:Prefix", namespaces)["xml:id"])
        .to eq("NISTp10_-1")
      expect(formula.value.first.unit_name).to eq(terms.first.first)
      expect(formula.value.first.prefix).to be_nil
    end
  end

  it "retains registered identity and singleton root omission" do
    document = records_for(formula_for("dB", [["dB", nil]]))
    expect(document.at_xpath("/records/u:Unit", namespaces)["xml:id"])
      .to eq("U_NISTu155")
    expect(document.at_xpath("//u:RootUnits", namespaces)).to be_nil
    expect(document.at_xpath("/records/u:Quantity", namespaces)["xml:id"])
      .to eq("NISTq90")
  end

  it "retains the existing singleton power root omission" do
    document = records_for(formula_for("dB^2", [["dB", "2"]]))
    expect(document.at_xpath("/records/u:Unit", namespaces)["xml:id"])
      .to eq("U_dB2")
    expect(document.at_xpath("//u:RootUnits", namespaces)).to be_nil
  end

  it "encodes an invalid fractional ID deterministically" do
    document = records_for(formula_for("dB^(1/2)", [["dB", "1/2"]]))
    expect(document.at_xpath("/records/u:Unit", namespaces)["xml:id"])
      .to eq("EncodedUnit_555f6442312f32")
  end

  it "preserves valid Unicode and literal escape-looking Unit IDs" do
    expect(Unitsml::Utility.unit_id("μ")).to eq("U_μ")
    expect(Unitsml::Utility.unit_id("_x002F_")).to eq("U__x002F_")
    expect(Unitsml::Utility.unit_id("EncodedUnit_555f6442312f32"))
      .to eq("U_EncodedUnit_555f6442312f32")
  end

  it "rejects a collision with an explicit quantity ID" do
    quantity = { quantity: "EncodedUnit_555f6442312f32" }
    formula = formula_for("dB^(1/2)", [["dB", "1/2"]], explicit_value: quantity)
    expect { formula.to_xml }.to raise_error(ArgumentError, /collides/)
  end

  it "rejects a collision with a configured peer record ID" do
    identifier = Struct.new(:id).new("EncodedUnit_555f6442312f32")
    record = Struct.new(:identifiers).new([identifier])
    allow(Unitsml::Unitsdb.prefixes).to receive(:prefixes).and_return([record])
    expect { Unitsml::Utility.unit_id("dB^(1/2)") }
      .to raise_error(ArgumentError, /collides/)
  end

  it "multiplies a database root power by the exact expression power" do
    root = Unitsml::Unitsdb.units.find_by_symbol_id("dB").root_units.first
    allow(root).to receive(:power).and_return(2)
    formula = formula_for("dB^(1/3)*s", [["dB", "1/3"], ["s", nil]])
    emitted = root_attributes(records_for(formula)).first
    expect(emitted).to eq(%w[bel d 2 3])
    expect(formula.value.first.power_numerator.raw_value).to eq("1/3")
  end

  {
    "kcal_IT" => "table_kg_calorie",
    "kcal_th" => "thermo_kg_calorie",
  }.each do |symbol, canonical|
    it "preserves the independently enumerated prefixed root #{symbol}" do
      units = [Unitsml::Unit.new(symbol), Unitsml::Unit.new("s")]
      roots = Unitsml::Utility.rootunits(units).enumerated_root_unit
      expect(roots.map(&:unit)).to eq([canonical, "second"])
      expect(Unitsml::Utility.prefixes(units, {})).to eq("")
    end
  end

  it "rejects root powers outside the schema byte bounds without truncation" do
    formula = formula_for("dB^128*s", [["dB", "128"], ["s", nil]])
    expect { formula.to_xml }.to raise_error(RangeError, /bounds/)
  end
end
