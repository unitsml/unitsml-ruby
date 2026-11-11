# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::QuantityKind do
  def quantity(value, unit, kind = nil)
    Unitsml::Quantity.new(value: value, unit: unit, kind: kind)
  end

  describe "data-declared kind compatibility (equivalence_class)" do
    it "adds work and heat: both are in the energy class" do
      sum = quantity(2, "J", "work") + quantity(3, "J", "NISTq19")
      expect(sum.value).to eq(5)
      expect(sum.kind.id).to eq("NISTq18")
    end

    it "subtracts energy from work: same class" do
      diff = quantity(5, "J", "NISTq18") - quantity(2, "J", "NISTq17")
      expect(diff.value).to eq(3)
    end

    it "converts operands of compatible kinds exactly (1 kW*h + 1 J)" do
      sum = quantity(1, "kW*h", "work") + quantity(1, "J", "energy")
      expect(sum.value).to eq(Rational(3_600_001, 3_600_000))
    end

    it "refuses torque + energy although both are L2MT-2" do
      expect { quantity(1, "N*m", "torque") + quantity(1, "J", "energy") }
        .to raise_error(Unitsml::Errors::QuantityKindMismatchError,
                        /NISTq184.*NISTq17/)
    end

    it "refuses torque - work" do
      expect { quantity(1, "N*m", "NISTq184") - quantity(1, "J", "work") }
        .to raise_error(Unitsml::Errors::QuantityKindMismatchError)
    end

    it "gates class-less kinds by identity only" do
      expect { quantity(1, "N*m", "torque") + quantity(1, "N*m", "NISTq60") }
        .to raise_error(Unitsml::Errors::QuantityKindMismatchError)
      expect((quantity(1, "N*m", "torque") + quantity(2, "N*m", "torque"))
        .value).to eq(3)
    end

    it "keeps dimension-only gating when an operand is untyped" do
      sum = quantity(1, "N*m", "torque") + quantity(1, "J")
      expect(sum.value).to eq(2)
      expect(sum.kind.id).to eq("NISTq184")
      expect((quantity(1, "J") + quantity(1, "J")).kind).to be_nil
    end

    it "treats incompatible kinds as unequal" do
      expect(quantity(1, "N*m", "torque")).not_to eq(quantity(1, "J", "energy"))
      expect(quantity(1, "J", "work")).to eq(quantity(1, "J", "NISTq19"))
      expect(quantity(1, "J")).to eq(quantity(1, "J", "work"))
    end

    it "keeps the kind through scaling and conversion, drops it on products" do
      work = quantity(1, "kW*h", "work")
      expect((work * 2).kind.id).to eq("NISTq18")
      expect((work / 2).kind.id).to eq("NISTq18")
      converted = work.convert_to("J")
      expect(converted.value).to eq(3_600_000)
      expect(converted.kind.id).to eq("NISTq18")
      expect((work * quantity(1, "s")).kind).to be_nil
    end

    it "refuses a kind whose dimension differs from the unit's" do
      expect { quantity(1, "Pa", "work") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError,
                        /NISTd15.*NISTd14/)
    end

    it "refuses an unknown kind" do
      expect { quantity(1, "J", "no-such-kind") }
        .to raise_error(Unitsml::Errors::UnknownQuantityKindError)
    end
  end

  describe "primary quantity selection" do
    it "selects the flagged primary, not the first reference" do
      record = Unitsml::Unitsdb.units.find_by_name("J")
      expect(record.quantity_references.first.id).not_to eq("NISTq17")
      expect(described_class.primary_for(record).id).to eq("NISTq17")
    end

    it "is independent of quantity reference order" do
      record = Unitsml::Unitsdb.units.find_by_name("Pa")
      refs = record.quantity_references.to_a
      fake = Struct.new(:quantity_references, :identifiers)
      results = [refs, refs.reverse, refs.rotate(3)].map do |order|
        described_class.primary_for(fake.new(order, record.identifiers)).id
      end
      expect(results.uniq).to eq(["NISTq15"])
    end

    it "takes a sole unflagged reference as the unit's quantity" do
      ref = Unitsdb::QuantityReference.new(id: "NISTq1", type: "nist")
      fake = Struct.new(:quantity_references, :identifiers)
      expect(described_class.primary_for(fake.new([ref],
                                                  [])).id).to eq("NISTq1")
    end

    it "fails explicitly on several references without a primary" do
      refs = %w[NISTq1 NISTq48].map do |id|
        Unitsdb::QuantityReference.new(id: id, type: "nist")
      end
      fake = Struct.new(:quantity_references, :identifiers)
      expect { described_class.primary_for(fake.new(refs, [])) }
        .to raise_error(Unitsml::Errors::PrimaryQuantityError, /none is marked/)
    end

    it "fails explicitly on more than one primary" do
      refs = %w[NISTq1 NISTq48].map do |id|
        Unitsdb::QuantityReference.new(id: id, type: "nist", primary: true)
      end
      fake = Struct.new(:quantity_references, :identifiers)
      expect { described_class.primary_for(fake.new(refs, [])) }
        .to raise_error(Unitsml::Errors::PrimaryQuantityError, /marks 2/)
    end

    it "never promotes a sole reference marked primary: false" do
      ref = Unitsdb::QuantityReference.new(id: "NISTq1", type: "nist",
                                           primary: false)
      fake = Struct.new(:quantity_references, :identifiers)
      expect { described_class.primary_for(fake.new([ref], [])) }
        .to raise_error(Unitsml::Errors::PrimaryQuantityError, /primary: false/)
    end

    it "takes a sole reference whose flag is absent" do
      ref = Unitsdb::QuantityReference.new(id: "NISTq1", type: "nist")
      expect(ref.primary).to be_nil
      fake = Struct.new(:quantity_references, :identifiers)
      expect(described_class.primary_for(fake.new([ref], [])).id)
        .to eq("NISTq1")
    end

    it "selects the true flag among explicit false siblings" do
      refs = [["NISTq1", false], ["NISTq48", true], ["NISTq95", false]]
        .map do |id, flag|
        Unitsdb::QuantityReference.new(id: id, type: "nist", primary: flag)
      end
      fake = Struct.new(:quantity_references, :identifiers)
      expect(described_class.primary_for(fake.new(refs, [])).id)
        .to eq("NISTq48")
    end

    it "leaves render selection on the first reference" do
      record = Unitsml::Unitsdb.units.find_by_name("J")
      first = record.quantity_references.first.id
      expect(Unitsml::Utility.send(:quantity_reference_id, record))
        .to eq(first)
      expect(first).not_to eq(described_class.primary_for(record).id)
    end

    it "derives a quantity's primary kind from its single unit" do
      expect(quantity(1, "kJ").primary_kind.id).to eq("NISTq17")
      expect(quantity(1, "J", :primary).kind.id).to eq("NISTq17")
      expect(quantity(1, "N*m").primary_kind).to be_nil
      expect { quantity(1, "N*m", :primary) }
        .to raise_error(Unitsml::Errors::UnknownQuantityKindError)
    end
  end
end
