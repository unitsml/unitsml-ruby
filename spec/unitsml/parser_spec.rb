# frozen_string_literal: true

require "spec_helper"
require "asciiunits"
require "json"

ASCIIUNITS_CORPUS_PATH = File.join(Asciiunits::REPO_ROOT,
                                   "corpora/unitsml/inputs.txt")
CORPUS_INPUTS = File.readlines(ASCIIUNITS_CORPUS_PATH, chomp: true)
  .reject { |line| line.empty? || line.start_with?("#") }
  .map { |line| line.split("\t", 2)[1] }
  .freeze
EXPECTED_KINDS = JSON.parse(
  File.read(File.join(Asciiunits::REPO_ROOT,
                      "corpora/unitsml/expected-kinds.json")),
)["cases"].to_h { |case_row| [case_row["input"], case_row["kind"]] }.freeze

RSpec.describe Unitsml::Parser do
  it "is the engine behind Unitsml.parse" do
    expect(Unitsml.parse("mm*s^-2")).to be_a(Unitsml::Formula)
  end

  describe "conformance corpus replay" do
    CORPUS_INPUTS.each do |input|
      context "with #{input.inspect}" do
        specify "matches the frozen oracle kind" do
          expect(parse_result(input)).to eq(EXPECTED_KINDS.fetch(input)),
                                         input.inspect
        end
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

    it "normalizes the unicode minus" do
      expect(described_class.new("cm^−2").parse.to_xml)
        .to eq(described_class.new("cm^-2").parse.to_xml)
    end
  end

  def parse_result(input)
    described_class.new(input).parse
    "accept"
  rescue StandardError
    "reject"
  end
end
