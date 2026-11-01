# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass, RSpec/LeakyLocalVariable, RSpec/BeforeAfterAll, RSpec/ExampleLength, Layout/LineLength, Metrics/MethodLength, Metrics/AbcSize

# Replays the shared unitsml conversion corpus
# (github.com/unitsml/unitsml-testsuite, corpora/conversions) — the same
# oracle unitsml-ts replays for conversion parity. Point
# CONVERSION_CORPUS_DIR at a checkout of the testsuite repository; the
# CI workflow does this automatically.
RSpec.describe "unitsml-testsuite conversion corpus" do
  corpus_dir = ENV.fetch("CONVERSION_CORPUS_DIR", nil)
  corpus_file = corpus_dir && File.join(corpus_dir, "expected-conversions.json")

  before(:all) do
    unless corpus_file
      skip "CONVERSION_CORPUS_DIR not set — clone unitsml/unitsml-testsuite " \
           "and point CONVERSION_CORPUS_DIR at corpora/conversions to " \
           "enable the shared replay"
    end
    skip "no corpus at #{corpus_file}" unless corpus_file && File.exist?(corpus_file)
  end

  def wrap_unit_xml(element_xml)
    Unitsml::Model::Unit.from_xml(<<~XML).conversions
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="corpus">
        <Conversions>#{element_xml}</Conversions>
      </Unit>
    XML
  end

  def definition_from(case_entry)
    model = wrap_unit_xml(case_entry.fetch("xml")).float64_conversion_from ||
      wrap_unit_xml(case_entry.fetch("xml")).special_conversion_from ||
      wrap_unit_xml(case_entry.fetch("xml")).wsdl_conversion_from
    Unitsml::Conversion::Definition.from_model(
      model,
      document_units: case_entry["document_units"] || {},
    )
  end

  def definitions_hash(case_entry)
    (case_entry["definitions"] || []).to_h do |entry|
      model = wrap_unit_xml(entry.fetch("xml")).float64_conversion_from
      [entry.fetch("key"), Unitsml::Conversion::Definition.new(model)]
    end
  end

  it "matches the frozen conversion vectors for every corpus case" do
    skip "CONVERSION_CORPUS_DIR not set" unless corpus_file && File.exist?(corpus_file)

    corpus = JSON.parse(File.read(corpus_file))
    failures = []
    corpus.fetch("cases").each do |case_entry|
      check_case(case_entry, failures)
    rescue RSpec::Expectations::ExpectationNotMetError => e
      failures << "#{case_entry['id']}: #{e.message.lines.first&.strip}"
    end

    expect(failures).to eq([])
  end

  def check_case(case_entry, failures)
    case case_entry.fetch("kind")
    when "convert", "difference"
      check_convert(case_entry, failures)
    when "definition"
      check_definition(case_entry, failures)
    when "resolve"
      check_resolve(case_entry, failures)
    when "error"
      check_error(case_entry, failures)
    else
      failures << "#{case_entry['id']}: unknown kind #{case_entry['kind'].inspect}"
    end
  end

  def check_convert(case_entry, failures)
    quantity = Unitsml::Quantity.new(value: Rational(case_entry.fetch("value")),
                                     unit_expression: case_entry.fetch("unit_expression"))
    if case_entry["kind"] == "difference"
      other = Unitsml::Quantity.new(value: Rational(case_entry.fetch("other_value")),
                                    unit_expression: case_entry.fetch("other_unit_expression"))
      quantity = quantity - other
    end
    result = quantity.convert_to(case_entry.fetch("target"),
                                 definitions: definitions_hash(case_entry))
    expected = Rational(case_entry.fetch("expected"))
    return if result.value == expected

    failures << "#{case_entry['id']}: expected #{expected}, got #{result.value}"
  end

  def check_definition(case_entry, failures) # rubocop:disable Metrics/CyclomaticComplexity
    definition = definition_from(case_entry)
    failures << "#{case_entry['id']}: exactness" if definition.exact? != case_entry.fetch("exact")
    (case_entry["lexical"] || {}).each do |name, expected|
      actual = definition.model.lexical_decimal(name.to_sym)
      failures << "#{case_entry['id']}: lexical #{name}: #{actual.inspect}" if actual != expected
    end
    case_entry.fetch("operations").each do |operation|
      input = Rational(operation.fetch("input"))
      actual = definition.public_send(operation.fetch("op"), input)
      expected = Rational(operation.fetch("expected"))
      next if actual == expected

      failures << "#{case_entry['id']}: #{operation['op']}(#{input}) = " \
                  "#{actual}, expected #{expected}"
    end
  end

  def check_resolve(case_entry, failures)
    definition = definition_from(case_entry)
    resolved = definition.resolve_initial_unit
    if (identity = case_entry["resolves_to"])
      return if resolved == identity

      failures << "#{case_entry['id']}: resolved #{resolved.inspect}, " \
                  "expected #{identity.inspect}"
    elsif (identifier = case_entry["resolves_to_identifier"])
      ids = resolved.identifiers.to_a.map(&:id)
      return if ids.include?(identifier)

      failures << "#{case_entry['id']}: resolved ids #{ids.inspect}, " \
                  "expected #{identifier.inspect}"
    end
  end

  def check_error(case_entry, failures)
    expected_error = Unitsml::Errors.const_get(case_entry.fetch("error"))
    begin
      run_error_operation(case_entry)
      failures << "#{case_entry['id']}: expected #{case_entry['error']}, " \
                  "nothing raised"
    rescue expected_error => e
      return if Regexp.new(case_entry.fetch("matches")).match?(e.message)

      failures << "#{case_entry['id']}: #{e.message.inspect} does not match " \
                  "#{case_entry['matches'].inspect}"
    rescue StandardError => e
      failures << "#{case_entry['id']}: expected #{case_entry['error']}, " \
                  "got #{e.class}: #{e.message.lines.first&.strip}"
    end
  end

  def run_error_operation(case_entry)
    if case_entry["operation"] == "canonical"
      Unitsml::Conversion.to_canonical(Unitsml.parse(case_entry.fetch("expression")),
                                       definitions: definitions_hash(case_entry))
    elsif case_entry["xml"]
      definition_from(case_entry).resolve_initial_unit
    else
      Unitsml::Quantity.new(value: Rational(case_entry.fetch("value")),
                            unit_expression: case_entry.fetch("unit_expression"))
        .convert_to(case_entry.fetch("target"),
                    definitions: definitions_hash(case_entry))
    end
  end
end
# rubocop:enable RSpec/DescribeClass, RSpec/LeakyLocalVariable, RSpec/BeforeAfterAll, RSpec/ExampleLength, Layout/LineLength, Metrics/MethodLength, Metrics/AbcSize
