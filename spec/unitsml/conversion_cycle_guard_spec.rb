# frozen_string_literal: true

require "spec_helper"

# Minimal stand-ins for UnitsDB unit records with root_units chains.
module CycleGuardFixtures
  Ident = Struct.new(:type, :id)
  Ref = Struct.new(:id)
  Root = Struct.new(:power, :prefix_reference, :unit_reference)
  Sym = Struct.new(:id)
  Record = Struct.new(:identifiers, :symbols, :canonical_conversion,
                      :si_derived_bases, :root_units, :unit_system_reference)

  def self.record(id, roots)
    Record.new([Ident.new("nist", id)], [Sym.new("sym-#{id}")], nil, nil,
               roots.map { |target| Root.new(1, nil, Ref.new(target)) }, [])
  end
end

RSpec.describe Unitsml::Conversion do
  let(:records) { {} }

  before do
    allow(Unitsml::Unitsdb.units).to receive(:find_by_id)
      .and_wrap_original do |original, id|
        records.fetch(id) { original.call(id) }
      end
  end

  # Seconds taken by the block; any exception it raises is returned too.
  def elapsed
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    begin
      yield
      error = nil
    rescue StandardError => e
      error = e
    end
    [Process.clock_gettime(Process::CLOCK_MONOTONIC) - start, error]
  end

  describe "cycle guard" do
    it "refuses a unit whose root is itself, quickly" do
      records["X1"] = CycleGuardFixtures.record("X1", ["X1"])
      seconds, error = elapsed do
        described_class.record_factor(records["X1"], 1)
      end
      expect(error).to be_a(Unitsml::Errors::ConversionError)
      expect(error.message).to match(/cyclic unit definition.*X1.*->.*X1/)
      expect(seconds).to be < 1
    end

    it "refuses a two-unit cycle when resolving factors, quickly" do
      records["Y1"] = CycleGuardFixtures.record("Y1", ["Y2"])
      records["Y2"] = CycleGuardFixtures.record("Y2", ["Y1"])
      seconds, error = elapsed do
        described_class.record_factor(records["Y1"], 2)
      end
      expect(error.message).to match(/Y1.*->.*Y2.*->.*Y1/)
      expect(seconds).to be < 1
    end

    it "refuses a two-unit cycle when resolving dimensions, quickly" do
      records["Z1"] = CycleGuardFixtures.record("Z1", ["Z2"])
      records["Z2"] = CycleGuardFixtures.record("Z2", ["Z1"])
      seconds, error = elapsed do
        described_class.unit_dimensions(records["Z2"], 1, [])
      end
      expect(error.message).to match(/Z2.*->.*Z1.*->.*Z2/)
      expect(seconds).to be < 1
    end

    it "still converts acyclic chains and reuses the result" do
      values = Array.new(2) do
        Unitsml::Quantity.new(value: 1, unit: "kW*h").convert_to("J").value
      end
      expect(values).to eq([3_600_000, 3_600_000])
    end

    # UnitsDB gram-force (NISTu196) lists kilo x itself as its root unit and
    # kilopond (NISTu73) roots on it: both used to recurse without bound.
    %w[gf kp].each do |unit|
      it "fails fast on #{unit} -> N over the gram-force self-reference" do
        seconds, error = elapsed do
          Unitsml::Quantity.new(value: 1, unit: unit).convert_to("N")
        end
        expect(error).to be_a(Unitsml::Errors::ConversionError)
        expect(error.message).to include("NISTu196")
        expect(seconds).to be < 1
      end
    end
  end
end
