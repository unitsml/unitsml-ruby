# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "unitsml/opal/payload_generator"

RSpec.describe Unitsml::Opal::PayloadGenerator do
  let(:unitsdb_data_dir) do
    File.join(Gem.loaded_specs.fetch("unitsdb").full_gem_path, "data")
  end

  let(:real_database_hash) do
    Unitsdb::Database.from_db(unitsdb_data_dir).to_hash
  end

  describe "#call" do
    subject(:source) { described_class.new.call }

    it "is marked frozen_string_literal: true" do
      expect(source.lines.first).to eq("# frozen_string_literal: true\n")
    end

    it "documents that the file is auto-generated" do
      expect(source).to include("AUTO-GENERATED")
    end

    it "registers the payload via load_opal_payload" do
      expect(source)
        .to include("Unitsml::Unitsdb::Database.load_opal_payload(")
    end

    it "freezes the payload hash" do
      expect(source).to match(/\.freeze\)\n\z/)
    end

    it "produces a hash that reproduces the source database" do
      parsed = eval(PayloadHelper.extract_payload_hash_literal(source)) # rubocop:disable Security/Eval
      expect(parsed).to eq(real_database_hash)
    end
  end

  describe "#write_to" do
    it "writes #call to the given path and returns the path" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "database_payload.rb")
        returned = described_class.new.write_to(path)

        expect(returned).to eq(path)
        expect(File.read(path)).to eq(described_class.new.call)
      end
    end
  end

  describe "DEFAULT_OUTPUT_PATH" do
    it "points at lib/unitsml/opal/database_payload.rb" do
      expect(described_class::DEFAULT_OUTPUT_PATH)
        .to end_with("lib/unitsml/opal/database_payload.rb")
    end
  end
end
