# frozen_string_literal: true

RSpec.describe Unitsml::Unitsdb::Database do
  describe ".from_db" do
    context "when not running on opal" do
      before do
        stub_const("RUBY_ENGINE", "ruby")
        allow(Unitsdb::Database)
          .to receive(:from_db).and_return(:loaded_database)
      end

      it "delegates to the parent database loader" do
        result = described_class.from_db("/tmp/unitsdb",
                                         context: :unitsml_ruby)

        expect(result).to eq(:loaded_database)
        expect(Unitsdb::Database).to have_received(:from_db).with(
          "/tmp/unitsdb", context: :unitsml_ruby
        )
      end
    end

    context "when running on opal" do
      before do
        stub_const("RUBY_ENGINE", "opal")
        described_class.remove_instance_variable(:@opal_payload) if
          described_class.instance_variable_defined?(:@opal_payload)
      end

      it "raises a clear error when the bundled payload is missing" do
        expect do
          described_class.from_db("/does/not/matter", context: :unitsml_ruby)
        end.to raise_error(Unitsml::Errors::OpalPayloadNotBundledError,
                           /not bundled/)
      end

      it "loads the bundled Opal payload" do
        described_class.load_opal_payload({ "units" => [] })
        allow(described_class).to receive(:from_hash).and_return(:database)

        result = described_class.from_db("/does/not/matter", context: :unitsml_ruby)

        expect(result).to eq(:database)
        expect(described_class).to have_received(:from_hash).with(
          { "units" => [] },
          register: :unitsml_ruby,
        )
      end
    end
  end

  describe Unitsml::Unitsdb, ".database" do
    let(:context) { Struct.new(:id).new(:unitsml_ruby) }

    before do
      described_class.instance_variable_set(:@database, nil)
      allow(Unitsml::Configuration).to receive(:context).and_return(context)
    end

    after do
      described_class.instance_variable_set(:@database, nil)
    end

    context "when running on opal and unitsdb-ruby exposes a database loader" do
      before do
        stub_const("RUBY_ENGINE", "opal")
        allow(Unitsdb).to receive(:database).and_return(:unitsdb_database)
      end

      it "uses the unitsdb-ruby loader with the UnitsML context" do
        expect(described_class.database).to eq(:unitsdb_database)
        expect(Unitsdb).to have_received(:database).with(
          context: :unitsml_ruby,
        )
      end
    end

    context "when unitsdb-ruby exposes a database loader" do
      before do
        stub_const("RUBY_ENGINE", "ruby")
        allow(Unitsdb).to receive(:database).and_return(:unitsdb_database)
      end

      it "uses the unitsdb-ruby loader with the UnitsML context" do
        expect(described_class.database).to eq(:unitsdb_database)
        expect(Unitsdb).to have_received(:database).with(
          context: :unitsml_ruby,
        )
      end
    end

    context "when unitsdb-ruby cannot load its packaged data directory" do
      before do
        stub_const("RUBY_ENGINE", "ruby")
        allow(Unitsdb).to receive(:database).and_raise(
          Unitsdb::Errors::DatabaseNotFoundError,
        )
        allow(described_class)
          .to receive(:database_path)
          .and_return("/tmp/fallback-unitsdb")
        allow(Unitsml::Unitsdb::Database)
          .to receive(:from_db)
          .and_return(:fallback_database)
      end

      it "falls back to the UnitsML database wrapper with the same context" do
        expect(described_class.database).to eq(:fallback_database)
        expect(Unitsml::Unitsdb::Database).to have_received(:from_db).with(
          "/tmp/fallback-unitsdb",
          context: :unitsml_ruby,
        )
      end
    end
  end
end
