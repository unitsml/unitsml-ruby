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
    mapped = mapper.apply({ "unit" => terminal_slice("m", 0) })
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

  describe "edition-2 named nodes" do
    it "strips the structural names the wrap adds" do
      v1 = { "unit" => terminal_slice("m", 1) }
      v2 = v1.merge("lparen" => terminal_slice("(", 0),
                    "rparen" => terminal_slice(")", 2),
                    "hyphen" => terminal_slice("-", 3),
                    "end_guard" => nil)
      expect(mapper.apply(v2)).to eq(mapper.apply(v1))
      expect(mapper.apply(v2)).to be_a(Unitsml::Unit)
    end

    it "maps a fenced int_exp whose edition-2 tree carries the named fences" do
      # slashed_number_int_exp's bare-fence arm: the fences are rule
      # references, not authored captures, so edition 2 names them and
      # the strip leaves exactly what v1 surfaced.
      tree = { "lparen" => terminal_slice("(", 1),
               "int_exp" => { "unit" => terminal_slice("s", 2) },
               "rparen" => terminal_slice(")", 3) }
      expect(mapper.apply(tree)).to eq(Unitsml::Unit.new("s"))
    end
  end

  def terminal_slice(value, offset)
    { "value" => value, "offset" => offset, "length" => value.length,
      "line" => 1, "column" => offset + 1 }
  end
end
