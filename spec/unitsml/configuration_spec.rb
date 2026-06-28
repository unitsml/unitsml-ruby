# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Configuration do
  describe ".register_model" do
    context "with a Unitsdb::* subclass" do
      it "registers the model under the given id" do
        klass = Class.new(Unitsdb::Unit)
        described_class.register_model(klass, id: :test_unit)

        expect(described_class.registered_models[:test_unit]).to eq(klass)
      ensure
        described_class.registered_models.delete(:test_unit)
      end
    end

    context "with a class that is not a Unitsdb::* subclass" do
      it "raises InvalidModelError" do
        expect do
          described_class.register_model(Class.new(Object), id: :bad)
        end.to raise_error(Unitsml::Errors::InvalidModelError, /UnitsML model/)
      end
    end

    context "with a non-class argument" do
      it "raises InvalidModelError" do
        expect do
          described_class.register_model("not a class", id: :bad)
        end.to raise_error(Unitsml::Errors::InvalidModelError)
      end
    end
  end

  describe ".build_context" do
    it "produces a context whose id matches CONTEXT_ID" do
      context = described_class.context(force_populate: true)

      expect(context.id).to eq(described_class::CONTEXT_ID)
    end

    it "is idempotent across calls" do
      first = described_class.context(force_populate: true)
      second = described_class.context(force_populate: true)

      expect(second.id).to eq(first.id)
    end
  end

  describe ".unitsdb_model_subclass?" do
    it "returns true for a Unitsdb::* subclass" do
      expect(described_class.unitsdb_model_subclass?(Class.new(Unitsdb::Unit)))
        .to be(true)
    end

    it "returns false for a plain Ruby class" do
      expect(described_class.unitsdb_model_subclass?(Class.new(Object)))
        .to be(false)
    end

    it "returns false for a non-class" do
      expect(described_class.unitsdb_model_subclass?(Object.new))
        .to be(false)
    end
  end
end
