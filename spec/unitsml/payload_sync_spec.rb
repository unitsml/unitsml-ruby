# frozen_string_literal: true

require "spec_helper"
require "pathname"
require "unitsml/opal/payload_generator"

# Verifies that the committed lib/unitsml/opal/database_payload.rb is in
# sync with what the PayloadGenerator produces from the current unitsdb
# gem. Catches drift when unitsdb is bumped or its YAML data changes.
RSpec.describe "committed Opal database payload" do # rubocop:disable RSpec/DescribeClass
  let(:committed_payload_path) do
    Pathname.new(__dir__).join("..", "..", "lib", "unitsml", "opal").expand_path
      .join("database_payload.rb")
  end

  let(:committed_source) { File.read(committed_payload_path) }

  let(:generator_source) { Unitsml::Opal::PayloadGenerator.new.call }

  def extract_hash_literal(source)
    prefix = "Unitsml::Unitsdb::Database.const_set(:DATABASE, "
    suffix = ".freeze)\n"
    non_comment = source.each_line.reject do |line|
      line.start_with?("#") || line.strip.empty?
    end
    non_comment.join.delete_prefix(prefix).delete_suffix(suffix)
  end

  it "exists at lib/unitsml/opal/database_payload.rb" do
    expect(committed_payload_path).to exist
  end

  it "is marked frozen_string_literal: true" do
    expect(committed_source.lines.first)
      .to eq("# frozen_string_literal: true\n")
  end

  it "matches the generator output byte-for-byte" do
    expect(committed_source).to eq(generator_source)
  end

  it "round-trips through Unitsml::Unitsdb::Database.from_hash" do
    payload = eval(extract_hash_literal(committed_source)) # rubocop:disable Security/Eval
    reconstructed = Unitsml::Unitsdb::Database.from_hash(payload)

    expect(reconstructed).to be_a(Unitsml::Unitsdb::Database)
    expect(reconstructed.units.size).to be_positive
  end
end
