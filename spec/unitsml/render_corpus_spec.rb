# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass, RSpec/LeakyLocalVariable, RSpec/BeforeAfterAll, Layout/LineLength, RSpec/ExampleLength

require "canon/rspec_matchers"

# Replays the shared unitsml render corpus
# (github.com/unitsml/unitsml-testsuite, corpora/renders) — the same
# oracle unitsml-ts replays. Point CORPUS_DIR at a checkout of the
# testsuite repository; the CI workflow does this automatically.
RSpec.describe "unitsml-testsuite render corpus" do
  corpus_dir = ENV.fetch("CORPUS_DIR", nil)
  corpus_file = corpus_dir && File.join(corpus_dir, "expected-renders.json")

  before(:all) do
    unless corpus_file
      skip "CORPUS_DIR not set — clone unitsml/unitsml-testsuite and point " \
           "CORPUS_DIR at corpora/renders to enable the shared replay"
    end
    skip "no corpus at #{corpus_file}" unless corpus_file && File.exist?(corpus_file)
  end

  it "matches the frozen renders for every corpus case" do
    skip "CORPUS_DIR not set" unless corpus_file && File.exist?(corpus_file)

    corpus = JSON.parse(File.read(corpus_file))
    failures = []
    corpus.fetch("cases").each do |case_entry|
      input = case_entry.fetch("input")
      case case_entry.fetch("kind")
      when "ruby_error"
        next
      when "render"
        expected = case_entry.fetch("renders")
        formula = Unitsml::Parser.new(input).parse
        begin
          expect(formula.norm_text).to eq(expected.fetch("norm_text"))
          expect(formula.to_asciimath).to eq(expected.fetch("asciimath"))
          expect(formula.to_xml)
            .to be_xml_equivalent_to(expected.fetch("xml"))
        rescue RSpec::Expectations::ExpectationNotMetError => e
          failures << "#{input.inspect}: #{e.message.lines.first&.strip}"
        end
      else
        failures << "#{input.inspect}: unknown kind #{case_entry['kind'].inspect}"
      end
    end

    expect(failures).to eq([])
  end
end
