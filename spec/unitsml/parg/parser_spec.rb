# frozen_string_literal: true

require "spec_helper"

corpus_path = File.expand_path(
  "../../../vendor/asciiunits/corpora/unitsml/inputs.txt", __dir__
)
CORPUS_INPUTS = File.readlines(corpus_path, chomp: true)
  .reject { |line| line.empty? || line.start_with?("#") }
  .map { |line| line.split("\t", 2)[1] }
  .freeze
FORMATS = %i[to_xml to_mathml to_latex to_asciimath to_unicode].freeze

RSpec.describe Unitsml::Parg::Parser do
  around do |example|
    Unitsml::Configuration.parser = :parg
    example.run
  ensure
    Unitsml::Configuration.parser = :parslet
  end

  it "is selectable through Unitsml.parse" do
    expect(Unitsml.parse("mm*s^-2")).to be_a(Unitsml::Formula)
  end

  describe "render parity with the Parslet parser" do
    CORPUS_INPUTS.each do |input|
      context "with #{input.inspect}" do
        specify "both engines agree on every format" do
          parslet = formula_from(Unitsml::Parser, input)
          parg = formula_from(described_class, input)
          expect(parg.nil?).to eq(parslet.nil?)
          expect_same_rendering(parg, parslet) unless parslet.nil?
        end
      end
    end

    it "rejects exactly what the Parslet parser rejects" do
      CORPUS_INPUTS.each do |input|
        parslet_raises = raise?(Unitsml::Parser, input)
        parg_raises = raise?(described_class, input)
        expect(parg_raises).to eq(parslet_raises), input.inspect
      end
    end
  end

  describe "formula details" do
    it "marks prefix-only expressions as only_instance" do
      formula = described_class.new("p-").parse
      expect(formula.value.first.only_instance).to be(true)
    end

    it "carries explicit values from unitsml(...) attributes" do
      formula = described_class.new("unitsml(cal_th/cm^2, name: langley)").parse
      expect(formula.explicit_value).to eq(name: "langley")
    end

    it "normalizes the unicode minus like the Parslet parser" do
      expect(described_class.new("cm^−2").parse.to_xml)
        .to eq(Unitsml::Parser.new("cm^−2").parse.to_xml)
    end
  end

  def formula_from(parser_class, input)
    parser_class.new(input).parse
  rescue StandardError
    nil
  end

  def expect_same_rendering(parg_formula, parslet_formula)
    FORMATS.each do |format|
      expect(rendered(parg_formula, format))
        .to eq(rendered(parslet_formula, format))
    end
  end

  # Some structures crash rendering on both engines alike (upstream
  # behavior); an identical raise class is parity too.
  def rendered(formula, format)
    formula.public_send(format)
  rescue StandardError => e
    ["raise", e.class.name]
  end

  def raise?(parser_class, input)
    parser_class.new(input).parse
    false
  rescue StandardError
    true
  end
end
