# frozen_string_literal: true

RSpec.describe Unitsml::Unitsdb::Database do
  def with_replaced_constant(owner, constant_name, value)
    had_constant = owner.const_defined?(constant_name, false)
    original_value = owner.const_get(constant_name) if had_constant

    owner.send(:remove_const, constant_name) if had_constant
    owner.const_set(constant_name, value)

    yield
  ensure
    owner.send(:remove_const, constant_name) if owner.const_defined?(constant_name, false)
    owner.const_set(constant_name, original_value) if had_constant
  end

  describe ".from_db" do
    context "when not running on opal" do
      it "delegates to the parent database loader" do
        with_replaced_constant(Object, :RUBY_ENGINE, "ruby") do
          allow(::Unitsdb::Database).to receive(:from_db).and_return(:loaded_database)

          result = described_class.from_db("/tmp/unitsdb", context: :unitsml_ruby)

          expect(result).to eq(:loaded_database)
          expect(::Unitsdb::Database).to have_received(:from_db).with("/tmp/unitsdb", context: :unitsml_ruby)
        end
      end
    end

    context "when running on opal" do
      it "raises a clear error when the bundled payload is missing" do
        with_replaced_constant(Object, :RUBY_ENGINE, "opal") do
          expect do
            described_class.from_db("/does/not/matter", context: :unitsml_ruby)
          end.to raise_error(Unitsml::Errors::OpalPayloadNotBundledError, /not bundled/)
        end
      end
    end
  end
end
