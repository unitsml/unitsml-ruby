# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Unit do
  context "with complete UnitsDB short names" do
    Unitsml::Unitsdb.units.units.filter_map(&:short).each do |short|
      it "resolves #{short.inspect} identically in the parser and Unit.new" do
        formula = Unitsml.parse(short)
        expected = described_class.new(canonical_symbol(short))

        expect(formula.value).to eq([expected])
        expect(described_class.new(short)).to eq(expected)
        expect(formula.norm_text).to eq(short)
      end
    end

    {
      "pascal" => "Pa", "farad" => "F", "carat" => "ct", "katal" => "kat",
      "minute" => "min", "decade" => "dec", "ampere" => "A", "yard" => "yd"
    }.each do |short, canonical|
      it "renders #{short} as its unit rather than an accidental composition" do
        formula = Unitsml.parse(short)
        expected = Unitsml.parse(canonical)

        expect(formula.to_mathml).to eq(expected.to_mathml)
        expect(formula.to_xml).to eq(expected.to_xml)
      end
    end

    it "renders every element of a compound UnitsDB MathML fragment" do
      math = Moxml.parse(Unitsml.parse("meter_per_second").to_mathml).root
      row = math.elements.first

      expect(math.elements.size).to eq(1)
      expect(row.name).to eq("mrow")
      expect(row.elements.map(&:name)).to eq(%w[mrow mo mrow])
    end

    ["gal (UK)", "gal (US)"].each do |symbol|
      it "keeps the complete #{symbol} symbol ahead of the gal short name" do
        expect(Unitsml.parse(symbol).value).to eq([described_class.new(symbol)])
      end
    end

    it "preserves explicit multiplication such as pas*cal" do
      formula = Unitsml.parse("pas*cal")

      expect(formula.value.first).to eq(described_class.new("as", prefix: "p"))
      expect(formula.to_mathml).not_to eq(Unitsml.parse("pascal").to_mathml)
    end

    it "keeps rad's symbol meaning ahead of the radiation short name" do
      parsed = Unitsml.parse("rad").value.first

      expect(parsed.unit_name).to eq("rad")
      expect(parsed.unit_instance).to eq(Unitsml::Unitsdb.units.find_by_symbol_id("rad"))
      expect(parsed.unit_instance.short).not_to eq("rad")
    end

    %w[karc_degree kiloarc_degree xarc_degree arc_degree_extra].each do |input|
      it "does not resolve a short name inside #{input.inspect}" do
        expect { Unitsml.parse(input) }.to raise_error(Unitsml::Errors::ParseError)
        expect { described_class.new(input) }.to raise_error(Unitsml::Errors::UnknownUnitError)
      end
    end

    %w[name symbol quantity multiplier].each do |attribute|
      it "preserves #{attribute} and the original expression text" do
        formula = Unitsml.parse("unitsml(arc_degree, #{attribute}: metre)")

        expect(formula.explicit_value).to eq(attribute.to_sym => "metre")
        expect(formula.norm_text).to eq("arc_degree")
        expect(formula.value.first.unit_name).to eq("deg")
      end
    end
  end

  def canonical_symbol(short)
    units = Unitsml::Unitsdb.units
    return short if units.find_by_symbol_id(short)

    units.units.find { |unit| unit.short == short }.symbols.first.id
  end
end
