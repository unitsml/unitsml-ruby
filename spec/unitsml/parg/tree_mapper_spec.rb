# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Parg::TreeMapper do
  subject(:mapper) { described_class.new }

  it "maps a prefixed unit" do
    tree = { "prefix" => "m", "unit" => "m" }
    expect(mapper.apply(tree)).to eq(Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("m")))
  end

  it "maps an extended chain into nested formulas" do
    tree = { "unit" => "m", "extender" => "*",
             "sequence" => { "unit" => "s",
                             "power_numerator" => { "integer" => "-2" } } }
    expect(mapper.apply(tree)).to eq(chain_formula)
  end

  def chain_formula
    Unitsml::Formula.new(
      [Unitsml::Unit.new("m"), Unitsml::Extender.new("*"),
       Unitsml::Unit.new("s", Unitsml::Number.new("-2"))],
    )
  end

  it "keeps terminal slices as string-keyed hashes" do
    slice = { "value" => "m", "offset" => 0, "length" => 1 }
    mapped = mapper.apply({ "unit" => slice })
    expect(mapped).to be_a(Unitsml::Unit)
    expect(mapped.unit_name).to eq("m")
  end

  it "maps a sqrt followed by a sequence into a formula" do
    tree = { "sqrt" => { "unit" => "m" }, "sequence" => { "unit" => "s" } }
    mapped = mapper.apply(tree)
    expect(mapped).to be_a(Unitsml::Formula)
    expect(mapped.value.first).to be_a(Unitsml::Sqrt)
    expect(mapped.value.last).to be_a(Unitsml::Unit)
  end
end
