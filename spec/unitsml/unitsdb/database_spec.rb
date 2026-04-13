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
      before { stub_const("RUBY_ENGINE", "opal") }

      it "raises a clear error when the bundled payload is missing" do
        expect do
          described_class.from_db("/does/not/matter", context: :unitsml_ruby)
        end.to raise_error(Unitsml::Errors::OpalPayloadNotBundledError,
                           /not bundled/)
      end
    end
  end
end
