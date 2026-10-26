# frozen_string_literal: true

require "spec_helper"
require "digest"

# Quantity arithmetic composes units through Compose::Builder, the same
# structural engine as Unit#* and Unit#/, instead of concatenating and
# reparsing norm_text.
RSpec.describe Unitsml::Quantity do
  def q(unit, value = 1, **options)
    described_class.new(value: value, unit_expression: unit, **options)
  end

  def leaf_powers(quantity)
    leaves = []
    Unitsml::Compose::TermTree.each_leaf(quantity.formula.value) do |leaf|
      next unless leaf.is_a?(Unitsml::Unit)

      leaves << [leaf.unit_name, leaf.power_numerator&.raw_value]
    end
    leaves
  end

  describe "composition through the builder" do
    it "multiplies a composed quotient by a unit (W/m * s)" do
      result = q("W/m", 6) * q("s", 2)

      expect(result.value).to eq(12)
      expect(result.norm_text).to eq("W*m^(-1)*s")
      expect(leaf_powers(result)).to eq([["W", nil], ["m", "-1"], ["s", nil]])
      expect(result.dimension_vector)
        .to eq("Length" => 1, "Mass" => 1, "Time" => -2)
    end

    it "divides one quotient by another ((J/s) / (m/s))" do
      result = q("J/s", 6) / q("m/s", 2)

      expect(result.value).to eq(3)
      expect(result.norm_text).to eq("J*s^(-1)*m^(-1)*s")
      expect(leaf_powers(result))
        .to eq([["J", nil], ["s", "-1"], ["m", "-1"], ["s", nil]])
      expect(result.dimension_vector)
        .to eq("Length" => 1, "Mass" => 1, "Time" => -2)
    end

    it "keeps the simple quotient text" do
      expect((q("m") / q("s")).norm_text).to eq("m/s")
    end

    it "rejects mixing units and dimensions with the builder's typed error" do
      expect { q("dim_L") * q("m") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end
  end

  describe "unit: entry points" do
    let(:metre) { Unitsml::Unit.new("m") }

    it "treats String, Unit and Formula entries alike" do
      [described_class.new(value: 2, unit: "m"),
       described_class.new(value: 2, unit: metre),
       described_class.new(value: 2, unit: Unitsml.parse("m"))].each do |entry|
        expect(entry).to eq(q("m", 2))
        expect(entry.dimension_id).to eq(q("m", 2).dimension_id)
      end
    end

    it "keeps a Formula without reparsing it" do
      formula = metre / Unitsml::Unit.new("s")
      quantity = described_class.new(value: 1, unit: formula)

      expect(quantity.formula).to be(formula)
      expect(quantity.dimension_vector).to eq("Length" => 1, "Time" => -1)
    end

    it "accepts a composed Formula operand" do
      formula = Unitsml::Unit.new("W") / metre
      result = described_class.new(value: 6, unit: formula) * q("s", 2)

      expect(result.norm_text).to eq("W*m^(-1)*s")
      expect(result.dimension_vector)
        .to eq("Length" => 1, "Mass" => 1, "Time" => -2)
    end

    it "keeps the unit_expression: keyword" do
      expect(q("m").dimension_vector).to eq("Length" => 1)
    end

    it "treats an omitted or nil unit as a pure number" do
      [described_class.new(value: 3),
       described_class.new(value: 3, unit: nil),
       described_class.new(value: 3, unit_expression: nil)].each do |pure|
        expect(pure.formula).to be_nil
        expect(pure.norm_text).to eq("3")
      end
    end

    it "rejects both keywords, even when one is nil" do
      expect { described_class.new(value: 1, unit: "m", unit_expression: "m") }
        .to raise_error(ArgumentError)
      expect { described_class.new(value: 1, unit: nil, unit_expression: "m") }
        .to raise_error(ArgumentError)
      expect { described_class.new(value: 1, unit: "m", unit_expression: nil) }
        .to raise_error(ArgumentError)
    end

    it "rejects a direct Dimension or another object" do
      [Unitsml::Dimension.new("dim_L"), 42, :m].each do |bad|
        expect { described_class.new(value: 1, unit: bad) }
          .to raise_error(Unitsml::Errors::InvalidUnitEntryError,
                          /Invalid unit: .* expected a String, Unit or Formula/)
      end
    end

    def parser_error_class(source)
      q(source)
      nil
    rescue StandardError => e
      e.class
    end

    it "propagates the same parser error for both String keywords" do
      %w[foo xm].each do |source|
        error = parser_error_class(source)
        expect(error).not_to be_nil
        expect { described_class.new(value: 1, unit: source) }
          .to raise_error(error)
      end
    end
  end

  describe "gates" do
    it "keeps the scalar scale gates" do
      interval = q("K", 10, scale: :interval)

      expect { interval * 2 }.to raise_error(Unitsml::Errors::ScaleOperationError)
      expect { interval / 2 }.to raise_error(Unitsml::Errors::ScaleOperationError)
      expect { interval * q("s") }
        .to raise_error(Unitsml::Errors::ScaleOperationError)
      expect { q("s") / interval }
        .to raise_error(Unitsml::Errors::ScaleOperationError)
    end

    it "rejects zero Numeric and zero Quantity divisors" do
      expect { q("m") / 0 }
        .to raise_error(Unitsml::Errors::IndeterminateResultError)
      expect { q("m") / q("s", 0) }
        .to raise_error(Unitsml::Errors::IndeterminateResultError)
      expect { q("m") / q(nil, 0) }
        .to raise_error(Unitsml::Errors::IndeterminateResultError)
    end

    it "keeps the dimension gate and operand check on + and -" do
      expect { q("m") + q("s") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
      expect { q("m") - 1 }.to raise_error(ArgumentError)
    end

    it "keeps the existing ratio result scale for interval differences" do
      a = q("K", 10, scale: :interval)
      b = q("K", 2, scale: :interval)

      # Deferred (#82): the result scale is not derived from the operands.
      expect((a + b).scale).to eq(:ratio)
      expect((a - b).scale).to eq(:ratio)
      expect(((a + b) * 2).value).to eq(24)
    end
  end

  describe "pure numbers" do
    it "scales a pure number" do
      result = q(nil, 4) * 2

      expect([result.value, result.dimension_vector]).to eq([8, {}])
      expect(result.formula).to be_nil
    end

    it "composes with a pure number on either side" do
      expect((q(nil, 5) / q("s", 2)).dimension_vector).to eq("Time" => -1)
      expect((q("s", 4) / q(nil, 2)).dimension_vector).to eq("Time" => 1)
      expect((q(nil, 4) * q("s")).dimension_vector).to eq("Time" => 1)
      expect((q("s") * q(nil, 4)).norm_text).to eq("s")
    end

    it "inverts a lone divisor without a leading extender" do
      result = q(nil, 1) / q("s")

      expect(result.formula.value.first).to be_a(Unitsml::Unit)
      expect(result.norm_text).to eq("s^(-1)")
    end

    it "keeps pure products and quotients unitless" do
      expect((q(nil, 4) * q(nil, 2)).formula).to be_nil
      expect((q(nil, 4) / q(nil, 2)).value).to eq(2)
    end

    it "cancels like units into an empty vector" do
      expect((q("m", 6) / q("m", 2)).dimension_vector).to eq({})
    end
  end

  describe "chained arithmetic" do
    it "carries formulas through +, -, * and /" do
      speed = q("m", 10) / q("s", 2)
      summed = (speed + (q("m", 3) / q("s", 1))) - (q("m", 2) / q("s", 1))
      result = summed * q("s", 2) / 2

      expect(result.value).to eq(6)
      expect(result.dimension_vector).to eq("Length" => 1)
      expect(result.norm_text).to eq("m*s^(-1)*s")
    end
  end

  describe "operand isolation" do
    it "does not mutate either operand" do
      a = q("km^2", 4)
      b = q("s^((-2))", 2)
      before = [a.formula.to_xml, b.formula.to_xml, a.norm_text, b.norm_text]

      [a * b, a / b, b / a].each(&:dimension_vector)
      expect([a.formula.to_xml, b.formula.to_xml, a.norm_text, b.norm_text])
        .to eq(before)
    end

    it "gives scalar and additive results independent trees" do
      a = q("km^2", 4)
      b = q("km^2", 2)
      [a * 2, a / 2, a + b, a - b].each do |result|
        expect(result.formula).not_to be(a.formula)
        expect(result.norm_text).to eq("km^2")
      end
    end

    def scramble(formula)
      leaf = formula.value.first
      leaf.power_numerator = Unitsml::Number.new("9")
      leaf.prefix = Unitsml::Prefix.new("m")
      formula.norm_text.replace("changed")
      formula.value.clear
    end

    it "keeps the operand intact when a result changes in place" do
      a = q("km^2", 4)
      b = q("km^2", 2)
      leaf = a.formula.value.first
      [a * 2, a / 2, a + b, a - b].each { |result| scramble(result.formula) }
      expect(a.formula.value.first).to be(leaf)
      expect([leaf.power_numerator.raw_value, leaf.prefix_name, a.norm_text])
        .to eq(["2", "k", "km^2"])
    end

    def lexeme(power)
      power = power.value while power.is_a?(Unitsml::Fenced)
      power&.raw_value
    end

    def mutable_strings(formula)
      strings = []
      Unitsml::Compose::TermTree.each_leaf(formula.value) do |leaf|
        next unless leaf.is_a?(Unitsml::Unit)

        strings.push(leaf.unit_name, leaf.prefix&.prefix_name,
                     lexeme(leaf.power_numerator))
      end
      strings.compact.reject(&:frozen?)
    end

    def shared_strings(result, source)
      mutable_strings(result.formula).select do |string|
        source.any? { |original| original.equal?(string) }
      end
    end

    it "shares no mutable name or exponent strings with its operands" do
      a = q("km^((2))", 4)
      b = q("ms^-1", 2)
      source = mutable_strings(a.formula) + mutable_strings(b.formula)
      [a * b, a / b, b / a, a * 3, a + a].each do |result|
        expect(shared_strings(result, source)).to be_empty
      end
    end
  end

  describe "parser independence after operand setup (MRI stand-in)" do
    let(:formula) { Unitsml::Unit.new("m") / Unitsml::Unit.new("s") }

    before do
      formula
      allow(Unitsml).to receive(:parse).and_call_original
      allow(Unitsml::Parser).to receive(:artifact)
        .and_raise(Unitsml::Errors::PargLoadError.new("probe", "missing"))
    end

    it "builds and combines object operands without parsing" do
      a = described_class.new(value: 4, unit: formula)
      b = described_class.new(value: 2, unit: Unitsml::Unit.new("m"))
      results = [a * b, a / b, a * 2, a / 2, a + a, a - a]
      expect(results).to all(be_a(described_class))
      expect(results.map(&:formula)).to all(be_a(Unitsml::Formula))
      expect(Unitsml).not_to have_received(:parse)
    end

    it "still sends String entries to the parser" do
      expect { described_class.new(value: 1, unit: "m") }
        .to raise_error(Unitsml::Errors::PargLoadError)
      expect { described_class.new(value: 1, unit_expression: "m") }
        .to raise_error(Unitsml::Errors::PargLoadError)
    end
  end

  # On this base (#87 not merged) unknown text still fails in the parser.
  describe "unknown text through both String keywords" do
    it "raises the parser's failure for an unknown unit or prefix" do
      %w[foo xm].each do |source|
        expect { described_class.new(value: 1, unit: source) }
          .to raise_error(Parsanol::ParseFailed)
        expect { described_class.new(value: 1, unit_expression: source) }
          .to raise_error(Parsanol::ParseFailed)
      end
    end
  end

  # Before/after snapshot rows for Quantity. Fractional, root, dimension-leaf
  # and scale outputs are existing behavior deferred to #82: they are pinned
  # here so this change cannot alter them, not because they are correct.
  describe "baseline replay" do
    def xml_digest(xml)
      Digest::SHA256.hexdigest(xml)[0, 16]
    end

    def arithmetic_rows
      {
        ["W/m", "s", :*] =>
          ["W*m^(-1)*s", { "Length" => 1, "Mass" => 1, "Time" => -2 }],
        ["J/s", "m/s", :/] =>
          ["J*s^(-1)*m^(-1)*s", { "Length" => 1, "Mass" => 1, "Time" => -2 }],
        ["m", "W/m", :/] => ["m*W^(-1)*m", { "Mass" => -1, "Time" => 3 }],
        ["W", "m*s", :/] =>
          ["W*m^(-1)*s^(-1)", { "Length" => 1, "Mass" => 1, "Time" => -4 }],
        ["m", "s", :/] => ["m/s", { "Length" => 1, "Time" => -1 }],
      }
    end

    def recorded_vectors
      joule = { "Length" => 2, "Mass" => 1, "Time" => -2 }
      {
        "m^(1/2)" => { "Length" => 1 }, "J^(1/2)" => joule, "J" => joule,
        "dim_L*dim_M" => {}, "sqrt(m)" => {}, "sqrt(m^2)" => {},
        "sqrt(m*s)" => {}, "sqrt((m*s))" => {}, "s/sqrt(m)" => { "Time" => 1 },
        "sqrt(sqrt(m))" => {}, "sqrt(dim_L)" => {}
      }
    end

    def fenced_product_vectors
      {
        "m^((1/2))" => { "Length" => 1, "Time" => 1 },
        "m^(1/2)" => { "Length" => 1, "Time" => 1 },
        "m^-1" => { "Length" => -1, "Time" => 1 },
        "g^((((3))))" => { "Mass" => 3, "Time" => 1 },
        "m^((-2))" => { "Length" => -2, "Time" => 1 },
        "K^(((-1)))" => { "Time" => 1, "ThermodynamicTemperature" => -1 },
      }
    end

    it "matches the recorded arithmetic rows" do
      arithmetic_rows.each do |(left, right, operator), (text, vector)|
        result = q(left).public_send(operator, q(right))
        expect([result.value, result.norm_text, result.dimension_vector])
          .to eq([1, text, vector])
      end
    end

    it "keeps the recorded dimension vectors (deferred #82 roots/fractions)" do
      recorded_vectors.each do |source, vector|
        expect(q(source).dimension_vector).to eq(vector)
      end
      expect { q("1/sqrt(m)").dimension_vector }.to raise_error(NoMethodError)
    end

    it "keeps the recorded dimension ids and fractional product" do
      expect(q("m^(1/2)").dimension_id).to eq("NISTd1")
      expect(q("sqrt(m)").dimension_id).to be_nil
      expect((q("m^(1/2)") * q("m^(1/2)")).dimension_vector)
        .to eq("Length" => 2)
    end

    it "keeps the recorded dimension-leaf rows" do
      expect((q("dim_L") + q(nil, 2)).value).to eq(3)
      expect { q("dim_L") + q("m") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
      expect { q("dim_L") * q("m") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
      expect(xml_digest((q("dim_M") / q("dim_L")).formula.to_xml))
        .to eq("fadb9a9811d67de4")
    end

    it "keeps the recorded construction rows" do
      expect { described_class.new(value: 1, unitsml_expression: "m") }
        .to raise_error(ArgumentError)
    end

    it "keeps the recorded interval scale rows" do
      interval = ->(value) { q("K", value, scale: :interval) }

      expect((interval[10] + interval[2]).scale).to eq(:ratio)
      expect((interval[10] - interval[2]).scale).to eq(:ratio)
      expect(((interval[10] + interval[2]) * 2).value).to eq(24)
      expect { interval[10] * 2 }
        .to raise_error(Unitsml::Errors::ScaleOperationError)
    end

    it "keeps the recorded ratio scale rows" do
      interval = q("K", 2, scale: :interval)
      expect((q("K", 10) + interval).scale).to eq(:ratio)
      expect((q("m", 2) * q("s", 3)).scale).to eq(:ratio)
    end

    it "keeps the recorded fenced-power product vectors" do
      fenced_product_vectors.each do |source, vector|
        expect((q(source) * q("s")).dimension_vector).to eq(vector)
      end
    end

    it "keeps the recorded scalar rows" do
      { "m" => { "Length" => 1 }, "sqrt(m)" => {},
        "m^(1/2)" => { "Length" => 1 }, nil => {} }.each do |source, vector|
        result = q(source, 4) * 2
        expect([result.value, result.dimension_vector]).to eq([8, vector])
      end
    end

    it "keeps the recorded pure-number rows" do
      expect((q(nil, 5) / q("s", 2)).dimension_vector).to eq("Time" => -1)
      expect((q("s", 4) / q(nil, 2)).dimension_vector).to eq("Time" => 1)
      expect((q(nil, 4) * q(nil, 2)).dimension_vector).to eq({})
    end
  end
end
