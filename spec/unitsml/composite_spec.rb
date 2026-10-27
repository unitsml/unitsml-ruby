# frozen_string_literal: true

require "spec_helper"
require "digest"

# Composite-unit builder (issue #2): the operator DSL (Unit#* / Unit#/) and the
# Unitsml.compose keyword form, both producing a root Formula whose output
# equals the equivalent parsed string.
RSpec.describe "Unitsml composite builder" do # rubocop:disable RSpec/DescribeClass
  def unit(name, power = nil, prefix: nil)
    Unitsml::Unit.new(name, power, prefix: prefix)
  end

  # to_plurimath is intentionally excluded: exercising it loads the plurimath
  # gem process-wide, which pollutes the "plurimath not installed" spec.
  def all_formats
    %i[to_latex to_asciimath to_unicode to_html to_xml to_mathml]
  end

  describe "operator DSL" do
    it "keeps the / glyph and matches the parser for a single division" do
      formula = unit("W") / unit("m")
      parsed = Unitsml.parse("W/m")
      all_formats.each do |fmt|
        expect(formula.public_send(fmt)).to eq(parsed.public_send(fmt))
      end
    end

    it "chains division with / glyphs, like repeated explicit extenders" do
      formula = unit("W") / unit("m") / unit("sr")
      explicit = unit("W").ext("/").unit("m", -1).ext("/").unit("sr", -1)
      all_formats.each do |fmt|
        expect(formula.public_send(fmt)).to eq(explicit.public_send(fmt))
      end
    end

    it "returns a Formula, not a Unit" do
      expect(unit("W") / unit("m")).to be_a(Unitsml::Formula)
    end

    it "takes powers from the constructor (m/s^2)" do
      formula = unit("m") / unit("s", 2)
      parsed = Unitsml.parse("m/s^2")
      all_formats.each do |fmt|
        expect(formula.public_send(fmt)).to eq(parsed.public_send(fmt))
      end
    end

    it "does not mutate its operands" do
      squared = unit("s", 2)
      unit("m") / squared
      expect(squared.power_numerator).to eq(Unitsml::Number.new("2"))
    end

    it "raises when units and dimensions are mixed" do
      expect { unit("m") * Unitsml::Dimension.new("dim_L") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end
  end

  describe "Numeric operands (Quantity results)" do
    let(:metre) { unit("m") }
    let(:second) { unit("s") }
    let(:speed) { metre / second }
    let(:dim_l) { Unitsml::Dimension.new("dim_L") }

    def leaf_shape(node)
      leaves = []
      Unitsml::Compose::TermTree.each_leaf(node.value) do |leaf|
        name = case leaf
               when Unitsml::Unit then leaf.unit_name
               when Unitsml::Dimension then leaf.dimension_name
               end
        leaves << [name, leaf.power_numerator&.raw_value] if name
      end
      leaves
    end

    def summary(result)
      [result.class, result.value, leaf_shape(result.formula)]
    end

    it "multiplies a Unit by a number on either side" do
      expected = [Unitsml::Quantity, 5, [["m", nil]]]
      expect(summary(5 * metre)).to eq(expected)
      expect(summary(metre * 5)).to eq(expected)
    end

    it "multiplies a Formula by a number on either side" do
      expected = [Unitsml::Quantity, 5, [["m", nil], ["s", "-1"]]]
      expect(summary(5 * speed)).to eq(expected)
      expect(summary(speed * 5)).to eq(expected)
    end

    it "divides a number by a Unit or Formula, inverting stored powers" do
      expect(summary(5 / metre)).to eq([Unitsml::Quantity, 5, [["m", "-1"]]])
      expect(summary(5 / speed))
        .to eq([Unitsml::Quantity, 5, [["m", "-1"], ["s", nil]]])
    end

    it "divides a Unit or Formula by a number" do
      expect(summary(metre / 2.0)).to eq([Unitsml::Quantity, 0.5, [["m", nil]]])
      expect(summary(speed / 4.0))
        .to eq([Unitsml::Quantity, 0.25, [["m", nil], ["s", "-1"]]])
    end

    it "keeps the existing Quantity integer magnitude rule" do
      # Quantity#/ keeps Integer division for Integer magnitudes.
      expect((metre / 2).value).to eq(0)
      expect((speed / 3).value).to eq(0)
    end

    it "rejects a zero divisor" do
      [metre, speed].each do |operand|
        expect { operand / 0 }
          .to raise_error(Unitsml::Errors::IndeterminateResultError)
      end
    end

    it "coerces a number into [pure-number Quantity, magnitude-1 Quantity]" do
      number, operand = metre.coerce(5)
      expect([number.value, number.formula]).to eq([5, nil])
      expect([operand.value, leaf_shape(operand.formula)])
        .to eq([1, [["m", nil]]])
    end

    it "rejects a non-Numeric coerce argument with a typed :operand error" do
      ["5", nil, Object.new].each do |bad|
        expect { metre.coerce(bad) }.to raise_error(
          an_instance_of(Unitsml::Errors::InvalidUnitEntryError)
            .and(having_attributes(field: :operand, value: bad)),
        )
      end
    end

    it "keeps unit-only operands on the Formula DSL" do
      expect([metre * second, metre / second,
              metre * Unitsml::Extender.new("/")])
        .to all(be_a(Unitsml::Formula))
    end

    it "agrees with explicit Quantity construction when chained" do
      chained = (5 * metre) / second
      explicit = Unitsml::Quantity.new(value: 5, unit: metre) / second
      expect(summary(chained)).to eq(summary(explicit))
      expect(summary(chained))
        .to eq([Unitsml::Quantity, 5, [["m", nil], ["s", "-1"]]])
    end

    it "wraps a Dimension the same way (leaf shape only)" do
      expect(summary(5 * dim_l)).to eq([Unitsml::Quantity, 5, [["dim_L", nil]]])
      expect(summary(dim_l * 5)).to eq([Unitsml::Quantity, 5, [["dim_L", nil]]])
    end

    it "builds without parsing" do
      [metre, speed, dim_l]
      allow(Unitsml).to receive(:parse).and_call_original
      [5 * metre, metre * 5, 5 / speed, speed / 2.0, 5 * dim_l]
      expect(Unitsml).not_to have_received(:parse)
    end

    def numeric_results
      [5 * speed, speed * 5, 5 / speed, speed / 2.0, 5 * metre]
    end

    it "does not alias its operands" do
      expect(numeric_results.map(&:formula)).to all(satisfy { |formula|
        !formula.equal?(speed)
      })
    end

    it "does not mutate its operands when a result changes in place" do
      before = [leaf_shape(speed), speed.to_xml, metre.power_numerator]
      numeric_results.each { |result| result.formula.value.clear }
      expect([leaf_shape(speed), speed.to_xml, metre.power_numerator])
        .to eq(before)
    end
  end

  describe "Unitsml.compose" do
    let(:parsed) { Unitsml.parse("W*m^-1*sr^-1, quantity: radiance").to_xml }

    it "matches the parsed expression for mixed entry types" do
      formula = Unitsml.compose(
        units: ["W", { unit: "m", power: -1 }, { unit: "sr", power: -1 }],
        quantity: "radiance",
      )
      expect(formula.to_xml).to eq(parsed)
    end

    it "accepts pre-built Unit entries" do
      formula = Unitsml.compose(
        units: [Unitsml::Unit.new("W"), { unit: "m", power: -1 },
                { unit: "sr", power: -1 }],
        quantity: "radiance",
      )
      expect(formula.to_xml).to eq(parsed)
    end

    it "raises for an empty composition" do
      expect { Unitsml.compose(units: []) }
        .to raise_error(Unitsml::Errors::EmptyCompositionError)
      expect { Unitsml.compose }
        .to raise_error(Unitsml::Errors::EmptyCompositionError)
    end

    it "rejects a dim_* reference in units: (units-only)" do
      expect { Unitsml.compose(units: ["W", "dim_L"]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "raises when both units: and dimensions: are given" do
      expect { Unitsml.compose(units: ["W"], dimensions: ["dim_L"]) }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end

    it "raises for an unknown unit reference" do
      expect { Unitsml.compose(units: ["zzz"]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "rejects a pre-built Dimension in units:" do
      expect { Unitsml.compose(units: [Unitsml::Dimension.new("dim_L")]) }
        .to raise_error(Unitsml::Errors::InvalidUnitEntryError)
    end

    it "raises every compose failure under Errors::BaseError" do
      expect { Unitsml.compose(units: []) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml.compose(units: [{ unit: "m", power: 0.5 }]) }
        .to raise_error(Unitsml::Errors::BaseError)
    end
  end

  describe "Unitsml.compose dimensions" do
    it "composes pure dimensions like the parser" do
      formula = Unitsml.compose(dimensions: ["dim_L", "dim_M"])
      expect(formula.to_xml).to eq(Unitsml.parse("dim_L*dim_M").to_xml)
    end

    it "accepts a {dimension:, power:} hash like dim_L^2" do
      formula = Unitsml.compose(dimensions: [{ dimension: "dim_L", power: 2 }])
      expect(formula.to_xml).to eq(Unitsml.parse("dim_L^2").to_xml)
    end

    it "raises UnknownDimensionError for an unknown dimension" do
      expect { Unitsml.compose(dimensions: ["dim_bogus"]) }
        .to raise_error(Unitsml::Errors::UnknownDimensionError)
    end

    it "rejects a prefix on a dimension entry" do
      expect do
        Unitsml.compose(dimensions: [{ dimension: "dim_L", prefix: "k" }])
      end.to raise_error(Unitsml::Errors::InvalidUnitEntryError)
    end

    it "rejects a pre-built Unit in dimensions:" do
      expect { Unitsml.compose(dimensions: [Unitsml::Unit.new("W")]) }
        .to raise_error(Unitsml::Errors::InvalidUnitEntryError)
    end

    it "ignores quantity/name metadata for a dimension composition" do
      formula = Unitsml.compose(dimensions: ["dim_L"],
                                quantity: "length", name: "L")
      expect { formula.to_xml }.not_to raise_error
      expect(formula.to_xml).not_to include("<Quantity")
    end
  end

  describe "render-time metadata" do
    subject(:formula) { Unitsml::Unit.new("W") / Unitsml::Unit.new("m") }

    it "emits a Quantity passed to to_xml" do
      expect(formula.to_xml(quantity: "NISTq89")).to include('xml:id="NISTq89"')
    end

    it "ignores quantity/name for non-xml formats" do
      expect { formula.to_latex(quantity: "radiance", name: "x") }
        .not_to raise_error
    end

    it "lets a render option override parsed comma-metadata" do
      parsed = Unitsml.parse("kg*m, name: FROM_PARSE")
      expect(parsed.to_xml(name: "FROM_OPTION"))
        .to include(">FROM_OPTION</UnitName>")
    end

    it "applies a multiplier passed to a render method" do
      expect(formula.to_asciimath(multiplier: :nospace)).not_to include("*")
    end
  end

  describe "unit references" do
    it "rejects a short name (symbol ids only, like the parser)" do
      expect { Unitsml::Unit.new("watt") }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "fails fast on a nil reference (nil is not the internal sentinel)" do
      expect { Unitsml::Unit.new(nil) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
      expect { Unitsml::Unit.new("") }.not_to raise_error
    end
  end

  describe "power type validation (Unit/Dimension storage)" do
    it "rejects an unsupported power datatype at construction" do
      expect { Unitsml::Unit.new("m", "2") }
        .to raise_error(Unitsml::Errors::InvalidPowerError,
                        /Cannot store .+ as an exponent/)
      expect { Unitsml::Dimension.new("dim_L", "2") }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "rejects an unsupported power datatype via the setter" do
      unit = Unitsml::Unit.new("m")
      expect { unit.power_numerator = { x: 1 } }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "coerces a numeric power into a Unitsml::Number" do
      expect(Unitsml::Unit.new("m", 2).power_numerator)
        .to eq(Unitsml::Number.new("2"))
      expect(Unitsml::Dimension.new("dim_L", 2).power_numerator)
        .to eq(Unitsml::Number.new("2"))
    end

    it "stores a numeric power in the parser's exponent format" do
      # a Rational keeps its fraction form; whole values (incl. Float) reduce
      expect(Unitsml::Unit.new("m", Rational(1, 2)).power_numerator.raw_value)
        .to eq("1/2")
      expect(Unitsml::Unit.new("m", Rational(4, 2)).power_numerator.raw_value)
        .to eq("2")
      expect(Unitsml::Unit.new("m", 2.0).power_numerator.raw_value).to eq("2")
    end

    it "keeps a passed-in Number or Fenced exponent as-is" do
      number = Unitsml::Number.new("3")
      expect(Unitsml::Unit.new("m", number).power_numerator).to be(number)
      fenced = Unitsml::Fenced.new("(", Unitsml::Number.new("1/2"), ")")
      expect(Unitsml::Unit.new("m", fenced).power_numerator).to be(fenced)
      expect(Unitsml::Dimension.new("dim_L", fenced).power_numerator)
        .to be(fenced)
    end

    it "rejects a decimal power (no parser representation)" do
      expect { Unitsml::Unit.new("m", 0.5) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
      expect { Unitsml::Unit.new("m", 1.5) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "keeps the parser's Fenced exponent storable" do
      expect { Unitsml.parse("m^((1/2))").to_xml }.not_to raise_error
    end

    it "accepts a symbol reference" do
      expect(Unitsml::Unit.new(:W).unit_name).to eq("W")
    end

    it "raises for an unknown reference" do
      expect { Unitsml::Unit.new("zzz") }
        .to raise_error(Unitsml::Errors::UnknownUnitError, /zzz/)
    end

    it "validates a string prefix" do
      expect { Unitsml::Unit.new("m", prefix: "zz") }
        .to raise_error(Unitsml::Errors::UnknownPrefixError)
    end
  end

  describe "power coercion" do
    def latex_for(power)
      Unitsml.compose(units: [{ unit: "m", power: power }]).to_latex
    end

    it "mirrors parser exponent strings for valid powers" do
      expect(latex_for(2)).to eq(Unitsml.parse("m^2").to_latex)
      expect(latex_for(2.0)).to eq(Unitsml.parse("m^2").to_latex)
      expect(latex_for(Rational(2, 1))).to eq(Unitsml.parse("m^2").to_latex)
      expect(latex_for(Rational(1, 2))).to match(%r{\^1/2$})
      expect(latex_for(Unitsml::Number.new("3")))
        .to eq(Unitsml.parse("m^3").to_latex)
    end

    it "keeps an explicit exponent of 1, treats nil as no exponent" do
      expect(latex_for(1)).to eq(Unitsml.parse("m^1").to_latex)
      expect(latex_for(nil)).to eq(Unitsml.parse("m").to_latex)
    end

    it "rejects a non-integer Float power" do
      expect { latex_for(0.5) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end
  end

  describe "operand-safety (pure leaf construction)" do
    it "duplicates the prefix so operand and result never share it" do
      km = Unitsml::Unit.new("m", prefix: "k")
      original = km.prefix
      result = km * Unitsml::Unit.new("s")
      expect(km.prefix).to be(original)
      copied = result.value.first.prefix
      expect(copied).not_to be(original)
      expect(copied.prefix_name).to eq(original.prefix_name)
    end

    it "does not mutate a parsed sqrt operand it divides by" do
      op = Unitsml.parse("sqrt(m)")
      before = op.to_xml
      Unitsml::Unit.new("W") / op
      expect(op.to_xml).to eq(before)
    end

    it "composes a sqrt-dimension operand without mutating it" do
      op = Unitsml.parse("sqrt(dim_L)")
      before = op.to_xml
      Unitsml::Dimension.new("dim_M") * op
      expect(op.to_xml).to eq(before)
    end
  end

  describe "adversarial hardening (bug-hunt findings)" do
    it "rejects a fractional pre-built Number power like a Float" do
      half = Unitsml::Number.new("0.5")
      expect { Unitsml.compose(units: [{ unit: "m", power: half }]) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "still accepts an integer or fraction pre-built Number power" do
      three = Unitsml::Number.new("3")
      expect(Unitsml.compose(units: [{ unit: "m", power: three }]).to_latex)
        .to eq(Unitsml.parse("m^3").to_latex)
      half = Unitsml::Number.new("1/2")
      expect(Unitsml.compose(units: [{ unit: "m", power: half }]).to_latex)
        .to match(%r{\^1/2$})
    end

    it "fails fast on a pre-built Dimension with an unknown name" do
      expect { Unitsml.compose(dimensions: [Unitsml::Dimension.new("dim_bogus")]) }
        .to raise_error(Unitsml::Errors::UnknownDimensionError)
    end

    it "validates a pre-built Prefix object like a string prefix" do
      bad = Unitsml::Prefix.new("zz")
      expect { Unitsml.compose(units: [{ unit: "m", prefix: bad }]) }
        .to raise_error(Unitsml::Errors::UnknownPrefixError)
    end

    it "accepts a valid pre-built Prefix object" do
      k = Unitsml::Prefix.new("k")
      obj = Unitsml.compose(units: [{ unit: "m", prefix: k }])
      str = Unitsml.compose(units: [{ unit: "m", prefix: "k" }])
      expect(obj.to_xml).to eq(str.to_xml)
    end

    it "normalizes a pre-built Dimension with a Symbol name" do
      sym = Unitsml.compose(dimensions: [Unitsml::Dimension.new(:dim_L)])
      str = Unitsml.compose(dimensions: ["dim_L"])
      expect(sym.to_xml).to eq(str.to_xml)
    end

    it "validates a Prefix object at construction" do
      expect { Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("zz")) }
        .to raise_error(Unitsml::Errors::UnknownPrefixError)
      expect { Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new(BasicObject.new)) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "validates the power of a pre-built Unit entry" do
      bad = Unitsml::Unit.new("m", Unitsml::Number.new("abc"))
      expect { Unitsml.compose(units: [bad]) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "accepts slashed Number exponents the parser accepts" do
      %w[1/-2 1//2].each do |raw|
        pow = Unitsml::Number.new(raw)
        got = Unitsml.compose(units: [{ unit: "m", power: pow }]).to_latex
        expect(got).to eq(Unitsml.parse("m^(#{raw})").to_latex)
      end
    end

    it "composes a parsed fenced exponent without changing the operand" do
      operand = Unitsml.parse("m^((1/2))")
      before = operand.to_asciimath
      result = Unitsml::Unit.new("W") / operand
      expect(result.value.last.power_numerator.raw_value).to eq("-1/2")
      expect(operand.to_asciimath).to eq(before)
    end

    it "deep-copies a nested fenced exponent it does not invert" do
      operand = Unitsml.parse("g^((((3))))")
      original = operand.value.first.power_numerator
      copied = (operand * Unitsml::Unit.new("s")).value.first.power_numerator
      expect(copied).to be_a(Unitsml::Fenced)
      expect(copied).not_to be(original)
      expect(copied.value).not_to be(original.value)
    end

    it "renders a copied nested fenced exponent like the parser" do
      result = Unitsml.parse("g^((((3))))") * Unitsml::Unit.new("s")
      expect(result.to_asciimath)
        .to eq(Unitsml.parse("g^((((3))))*s").to_asciimath)
    end
  end

  describe "fluent chain (#unit / #dimension / metadata)" do
    it "chains units like the keyword form" do
      chained = Unitsml::Unit.new("W").unit("m", -1).unit("sr", -1)
      expect(chained.to_xml).to eq(Unitsml.parse("W*m^-1*sr^-1").to_xml)
    end

    it "matches the keyword form with metadata last" do
      base = Unitsml::Unit.new("W").unit("m", -1).unit("sr", -1)
      chained = base.quantity("radiance")
      keyword = Unitsml.compose(
        units: ["W", { unit: "m", power: -1 }, { unit: "sr", power: -1 }],
        quantity: "radiance",
      )
      expect(chained.to_xml).to eq(keyword.to_xml)
    end

    it "accepts a prefix in a chained unit" do
      chained = Unitsml::Unit.new("W").unit("m", prefix: "k")
      keyword = Unitsml.compose(units: ["W", { unit: "m", prefix: "k" }])
      expect(chained.to_xml).to eq(keyword.to_xml)
    end

    it "chains dimensions" do
      chained = Unitsml::Dimension.new("dim_L").dimension("dim_M")
      keyword = Unitsml.compose(dimensions: ["dim_L", "dim_M"])
      expect(chained.to_xml).to eq(keyword.to_xml)
    end

    it "guards a units/dimensions mix in the chain" do
      expect { Unitsml::Unit.new("W").dimension("dim_L") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end

    it "fails fast (BaseError) on an unknown dimension in the chain" do
      expect { Unitsml::Dimension.new("dim_L").dimension("dim_bogus") }
        .to raise_error(Unitsml::Errors::UnknownDimensionError)
    end

    it "validates a blank/nil ref in the chain like the keyword form" do
      w = Unitsml::Unit.new("W")
      expect { w.unit(nil) }.to raise_error(Unitsml::Errors::UnknownUnitError)
      expect { w.unit("") }.to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "validates power and prefix in a chained unit" do
      w = Unitsml::Unit.new("W")
      expect { w.unit("m", Unitsml::Number.new("abc")) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
      expect { w.unit("m", prefix: Unitsml::Prefix.new("zz")) }
        .to raise_error(Unitsml::Errors::UnknownPrefixError)
    end

    it "rejects a non-String/Symbol multiplier as a BaseError" do
      expect { Unitsml::Unit.new("W").unit("m").multiplier({ x: 1 }) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml.compose(units: ["W"], multiplier: { x: 1 }) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "rejects a non-String/Symbol name as a BaseError" do
      expect { Unitsml::Unit.new("W").name({ x: 1 }) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml.compose(units: ["W"], name: { x: 1 }) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "still accepts a valid multiplier" do
      expect { Unitsml::Unit.new("W").unit("m").multiplier("·") }
        .not_to raise_error
      expect { Unitsml::Unit.new("W").unit("m").multiplier(:nospace) }
        .not_to raise_error
    end

    it "attaches metadata to a single unit" do
      chained = Unitsml::Unit.new("W").quantity("radiance")
      keyword = Unitsml.compose(units: ["W"], quantity: "radiance")
      expect(chained).to be_a(Unitsml::Formula)
      expect(chained.to_xml).to eq(keyword.to_xml)
    end

    it "does not mutate the starting operand" do
      w = Unitsml::Unit.new("W")
      w.unit("m", -1)
      expect(w).to eq(Unitsml::Unit.new("W"))
    end

    it "drops metadata set before a later unit (metadata-last rule)" do
      dropped = Unitsml::Unit.new("W").quantity("radiance").unit("m", -1)
      plain = Unitsml::Unit.new("W").unit("m", -1)
      expect(dropped.to_xml).to eq(plain.to_xml)
    end
  end

  describe "explicit extenders (#extender / #ext)" do
    def expect_parity(built, string)
      parsed = Unitsml.parse(string)
      fmts = %i[to_latex to_asciimath to_unicode to_html to_xml to_mathml]
      fmts.each do |fmt|
        expect(built.public_send(fmt)).to eq(parsed.public_send(fmt)), fmt.to_s
      end
    end

    it "reproduces a parsed division byte-for-byte in every format" do
      built = Unitsml::Unit.new("W").extender("/").unit("m", -1)
      expect_parity(built, "W/m")
    end

    it "reproduces mixed separators (W*m/W) in every format" do
      built = Unitsml::Unit.new("W").ext("*").unit("m").ext("/").unit("W", -1)
      expect_parity(built, "W*m/W")
    end

    it "supports the double-slash extender" do
      built = Unitsml::Unit.new("m").ext("//").unit("s", -1)
      expect_parity(built, "m//s")
    end

    it "matches the parser's chained-division output" do
      built = Unitsml::Unit.new("W").ext("/").unit("m", -1).ext("/").unit("s")
      expect_parity(built, "W/m/s")
    end

    it "keeps dimensions glyph-only, like the parser" do
      built = Unitsml::Dimension.new("dim_M").ext("/").dimension("dim_L")
      expect_parity(built, "dim_M/dim_L")
    end

    it "lets the / operator negate after an explicit extender" do
      built = Unitsml::Unit.new("W").ext("/") / Unitsml::Unit.new("m")
      expect_parity(built, "W/m")
    end

    it "does not insert an implicit * after an explicit extender" do
      ascii = Unitsml::Unit.new("W").ext("/").unit("m", -1).to_asciimath
      expect(ascii).to eq("W/m^-1")
    end

    it "rejects any glyph outside the parser grammar" do
      w = Unitsml::Unit.new("W")
      ["x", "·", nil, ""].each do |bad|
        expect { w.ext(bad) }
          .to raise_error(Unitsml::Errors::InvalidUnitEntryError,
                          /render option/)
      end
      expect(w.ext(:*).unit("m").to_asciimath).to eq("W*m")
    end

    it "does not mutate an intermediate chain value" do
      partial = Unitsml::Unit.new("W") / Unitsml::Unit.new("m")
      before = partial.to_asciimath
      partial.unit("sr")
      expect(partial.to_asciimath).to eq(before)
    end

    it "leaves a dangling extender buildable but not renderable" do
      partial = Unitsml::Unit.new("W").ext("/")
      expect(partial.value.last).to be_a(Unitsml::Extender)
      # a dangling separator has no valid rendering...
      expect { partial.to_asciimath }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
      # ...but the chain can still be completed
      expect(partial.unit("m", -1).to_asciimath).to eq("W/m^-1")
    end

    it "rejects a rendered expression that ends in an extender" do
      %i[to_latex to_asciimath to_unicode to_html to_xml to_mathml
         to_plurimath].each do |fmt|
        expect { Unitsml::Unit.new("W").ext("/").public_send(fmt) }
          .to raise_error(Unitsml::Errors::MisplacedExtenderError)
      end
    end

    it "rejects two adjacent extenders" do
      expect { Unitsml::Unit.new("W").ext("/").ext("*").to_asciimath }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
      expect { (Unitsml::Unit.new("W") / Unitsml::Unit.new("m").ext("/")).to_xml }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
    end

    it "guards a misplaced extender nested inside a group" do
      inner = Unitsml::Formula.new([unit("m"), Unitsml::Extender.new("/")])
      nested = Unitsml::Formula.new([unit("W"), Unitsml::Extender.new("*"),
                                     inner], root: true)
      # to_xml (dimension/unit extraction) and the non-root to_mathml branch
      # both recurse structurally — the guard must reach the nested group.
      expect { nested.to_xml }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
      expect { nested.to_mathml }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
    end

    it "guards a bare separator wrapped in a group" do
      fenced = Unitsml::Fenced.new("(", Unitsml::Extender.new("/"), ")")
      sqrt = Unitsml::Sqrt.new(Unitsml::Extender.new("*"))
      [fenced, sqrt].each do |inner|
        f = Unitsml::Formula.new([unit("W"), inner], root: true)
        expect { f.to_asciimath }
          .to raise_error(Unitsml::Errors::MisplacedExtenderError)
      end
    end

    it "still guards a units/dimensions mix through an extender" do
      expect { Unitsml::Unit.new("W").ext("/").dimension("dim_L") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end

    it "accepts an Extender object as the glyph" do
      built = Unitsml::Unit.new("W").ext(Unitsml::Extender.new("/"))
      expect_parity(built.unit("m", -1), "W/m")
    end

    it "accepts an Extender object as an operator operand" do
      slash = Unitsml::Extender.new("/")
      built = Unitsml::Unit.new("W") * slash * Unitsml::Unit.new("m", -1)
      expect_parity(built, "W/m")
    end

    it "rejects an Extender object carrying an out-of-grammar glyph" do
      expect { Unitsml::Unit.new("W").ext(Unitsml::Extender.new("x")) }
        .to raise_error(Unitsml::Errors::InvalidUnitEntryError)
    end
  end

  describe "compose input hardening" do
    # Every failure through the compose surface must be an Errors::BaseError,
    # even for pathological inputs whose #to_s / #inspect raises or is absent.
    def hostile
      Class.new do
        def to_s = raise("boom")
        def inspect = raise("boom")
      end.new
    end

    def non_string_to_s
      Class.new { def to_s = 5 }.new
    end

    def hostile_inspect
      Class.new do
        def to_s = "ok"
        def inspect = BasicObject.new
      end.new
    end

    it "raises BaseError (never a raw exception) for a hostile extender" do
      expect { Unitsml::Unit.new("W").ext(hostile) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Unit.new("W").ext(BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a hostile unit/dimension reference" do
      expect { Unitsml::Unit.new("W").unit(hostile) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Dimension.new("dim_M").dimension(hostile) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a BasicObject operand of * or /" do
      expect { Unitsml::Unit.new("W") * BasicObject.new }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Unit.new("W") / BasicObject.new }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a reference whose #to_s returns a non-String" do
      bad = non_string_to_s
      expect { Unitsml::Unit.new("W").unit(bad) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml.compose(units: [{ unit: bad }]) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a BasicObject prefix or power" do
      expect { Unitsml::Unit.new("W").unit("s", prefix: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Unit.new("W").unit("s", BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Unit.new("m", BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for BasicObject render metadata" do
      formula = Unitsml::Unit.new("W") / Unitsml::Unit.new("m")
      expect { formula.name(BasicObject.new).to_xml }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { formula.multiplier(BasicObject.new).to_xml }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a BasicObject through the raw constructors" do
      expect { Unitsml::Unit.new(BasicObject.new).to_xml }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml::Dimension.new(BasicObject.new).to_xml }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError for a non-enumerable units:/dimensions: value" do
      expect { Unitsml.compose(units: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { Unitsml.compose(dimensions: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "silently drops a pathological quantity instead of leaking" do
      [BasicObject.new, non_string_to_s, hostile].each do |bad|
        expect { Unitsml.compose(units: ["W"], quantity: bad).to_xml }
          .not_to raise_error
      end
    end

    it "still resolves a valid quantity (String or Symbol)" do
      expect(Unitsml.compose(units: ["W"], quantity: "radiance").to_xml)
        .to include("Quantity")
      expect(Unitsml.compose(units: ["W"], quantity: :radiance).to_xml)
        .to include("Quantity")
    end

    it "raises BaseError for a hostile name:/multiplier: render option" do
      formula = Unitsml.compose(units: ["W", "m"])
      expect { formula.to_xml(name: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
      expect { formula.to_asciimath(multiplier: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
      # the same validation guards a parsed formula's render options
      expect { Unitsml.parse("W*m").to_xml(multiplier: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "validates render options on a non-root formula too" do
      nested = Unitsml::Formula.new(
        [unit("W"), Unitsml::Extender.new("*"), unit("m")], root: false
      )
      expect { nested.to_asciimath(multiplier: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises BaseError when an operand's #inspect returns a non-String" do
      expect { Unitsml::Unit.new("W") * hostile_inspect }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "raises UnknownDimensionError for an unknown or nil Dimension name" do
      expect { Unitsml::Dimension.new("dim_NOPE") }
        .to raise_error(Unitsml::Errors::UnknownDimensionError)
      expect { Unitsml::Dimension.new(nil) }
        .to raise_error(Unitsml::Errors::UnknownDimensionError)
    end

    it "rejects a numeric power the parser can't express" do
      require "bigdecimal"
      expect { Unitsml::Unit.new("m", BigDecimal("1.5")) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
      expect { Unitsml::Unit.new("m", Complex(2, 0)) }
        .to raise_error(Unitsml::Errors::InvalidPowerError)
    end

    it "raises MisplacedExtenderError for a leading separator" do
      formula = Unitsml::Formula.new(
        [Unitsml::Extender.new("*"), Unitsml::Unit.new("m")], root: true
      )
      expect { formula.to_latex }
        .to raise_error(Unitsml::Errors::MisplacedExtenderError)
    end

    it "validates a render option on a non-root to_mathml" do
      nested = Unitsml::Formula.new([Unitsml::Unit.new("W")], root: false)
      expect { nested.to_mathml(multiplier: BasicObject.new) }
        .to raise_error(Unitsml::Errors::BaseError)
    end

    it "drops a pathological quantity through find_by_name too" do
      hostile = Class.new { def to_s = raise("boom") }.new
      expect { Unitsml.compose(units: ["W"], quantity: hostile).to_xml }
        .not_to raise_error
    end
  end

  describe "norm_text round trip" do
    # Test-only exponent comparison: implicit power is 1, and a slashed lexeme
    # (including 1//2 and a signed denominator) is read as a Rational here.
    # Production never evaluates or normalizes these lexemes.
    def exponent_value(power)
      raw = power && fenced_lexeme(power)
      return Rational(1) unless raw

      parts = raw.gsub("//", "/").split("/")
      return Rational(raw) unless parts.size == 2

      Rational(Integer(parts[0], 10), Integer(parts[1], 10))
    end

    def fenced_lexeme(power)
      return power.raw_value unless power.is_a?(Unitsml::Fenced)

      fenced_lexeme(power.value)
    end

    def leaf_signature(formula)
      leaves = []
      Unitsml::Compose::TermTree.each_leaf(formula.value) do |leaf|
        case leaf
        when Unitsml::Unit
          leaves << [:unit, leaf.unit_name, leaf.prefix_name,
                     exponent_value(leaf.power_numerator)]
        when Unitsml::Dimension
          leaves << [:dimension, leaf.dimension_name, nil,
                     exponent_value(leaf.power_numerator)]
        end
      end
      leaves
    end

    def expect_round_trip(formula, text)
      expect(formula.norm_text).to eq(text)
      expect(leaf_signature(Unitsml.parse(formula.norm_text)))
        .to eq(leaf_signature(formula))
    end

    it "keeps the familiar text for a simple division" do
      expect_round_trip(unit("W") / unit("m"), "W/m")
      expect_round_trip(unit("m") / unit("s"), "m/s")
      expect_round_trip(unit("m", prefix: "k") / unit("s"), "km/s")
    end

    it "flattens chained and grouped divisions into explicit powers" do
      expect_round_trip(unit("W") / unit("m") / unit("sr"),
                        "W*m^(-1)*sr^(-1)")
      expect_round_trip((unit("J") / unit("s")) / (unit("m") / unit("s")),
                        "J*s^(-1)*m^(-1)*s")
      expect_round_trip((unit("W") / unit("m")) * unit("s"), "W*m^(-1)*s")
      expect_round_trip(unit("W").extender("//").unit("m", -1), "W*m^(-1)")
    end

    it "changes only norm_text, not the rendered output" do
      formula = unit("W") / unit("m") / unit("sr")
      explicit = unit("W").ext("/").unit("m", -1).ext("/").unit("sr", -1)
      expect(formula.norm_text).to eq("W*m^(-1)*sr^(-1)")
      expect(all_formats.map { |fmt| formula.public_send(fmt) })
        .to eq(all_formats.map { |fmt| explicit.public_send(fmt) })
    end

    it "round-trips rational and signed powers" do
      expect_round_trip(unit("m", Rational(1, 2)) * unit("s"), "m^(1/2)*s")
      expect_round_trip(unit("s") / unit("m", Rational(1, 2)), "s*m^(-1/2)")
    end

    it "round-trips lexical powers" do
      {
        "0" => "m^(0)*s", "-0" => "m^(-0)*s", "1" => "m^(1)*s",
        "007" => "m^(007)*s", "1/-2" => "m^(1/-2)*s", "1//2" => "m^(1//2)*s"
      }.each do |raw, text|
        expect_round_trip(unit("m", Unitsml::Number.new(raw)) * unit("s"), text)
      end
    end

    it "round-trips parser-produced fenced exponents" do
      {
        "m^((1/2))" => "s*m^(-1/2)", "g^((((3))))" => "s*g^(-3)",
        "m^((-2))" => "s*m^(2)", "K^(((-1)))" => "s*K"
      }.each do |source, text|
        expect_round_trip(unit("s") / Unitsml.parse(source), text)
      end
    end

    it "lists the stored leaves of grouped and root operands" do
      expect_round_trip(Unitsml.parse("((m*s))") * unit("s"), "m*s*s")
      expect_round_trip(Unitsml.parse("sqrt(Hz)") * unit("s"), "Hz^(5/10)*s")
      expect_round_trip(unit("s") / Unitsml.parse("sqrt(m*s)"),
                        "s*m^(-1)*s^(-1)")
      expect_round_trip(Unitsml.parse("sqrt(sqrt(m))") * unit("s"),
                        "m^(5/10)*s")
    end

    it "round-trips dimension products and roots" do
      dim_m = Unitsml::Dimension.new("dim_M")
      expect_round_trip(dim_m / Unitsml::Dimension.new("dim_L"),
                        "dim_M*dim_L^(-1)")
      expect_round_trip(dim_m / Unitsml.parse("sqrt(dim_L)"),
                        "dim_M*dim_L^(-5/10)")
    end

    it "leaves parsed norm_text untouched" do
      expect(Unitsml.parse("W/m/sr").norm_text).to eq("W/m/sr")
      expect(Unitsml.parse("m^1*s").norm_text).to eq("m^1*s")
    end
  end

  describe "Quantity adapter (Builder.quantity_product)" do
    let(:builder) { Unitsml::Compose::Builder }
    let(:seconds) { Unitsml.parse("s") }

    def leaf_powers(formula)
      formula.value.grep_v(Unitsml::Extender)
        .map { |leaf| [leaf.unit_name, leaf.power_numerator&.raw_value] }
    end

    it "returns nil when both sides are pure numbers" do
      %w[* /].each do |operator|
        expect(builder.quantity_product(nil, nil, operator)).to be_nil
      end
    end

    def nil_side_results(formula)
      [builder.quantity_product(formula, nil, "*"),
       builder.quantity_product(nil, formula, "*"),
       builder.quantity_product(formula, nil, "/")]
    end

    it "copies the formula when the other side is nil" do
      formula = Unitsml.parse("m")
      nil_side_results(formula).each do |result|
        expect(result).not_to be(formula)
        expect(result.value.map(&:class)).to eq([Unitsml::Unit])
        expect(leaf_powers(result)).to eq([["m", nil]])
      end
    end

    it "inverts a lone divisor without a leading extender" do
      result = builder.quantity_product(nil, Unitsml.parse("s"), "/")
      expect(result.value.first).to be_a(Unitsml::Unit)
      expect(leaf_powers(result)).to eq([["s", "-1"]])
      expect(result.norm_text).to eq("s^(-1)")
    end

    it "round-trips an inverted root through norm_text" do
      result = builder.quantity_product(nil, Unitsml.parse("sqrt(Hz)"), "/")
      expect(result.value.first).to be_a(Unitsml::Sqrt)
      expect(result.norm_text).to eq("Hz^(-5/10)")
      reparsed = Unitsml.parse(result.norm_text).value.first
      expect(reparsed.unit_name).to eq("Hz")
    end

    it "joins two formulas with the operator like the DSL" do
      left = Unitsml.parse("W")
      right = Unitsml.parse("m")
      expect(builder.quantity_product(left, right, "/").to_xml)
        .to eq((unit("W") / unit("m")).to_xml)
      expect(builder.quantity_product(left, right, "*").to_xml)
        .to eq((unit("W") * unit("m")).to_xml)
    end

    it "does not mutate either operand" do
      left = Unitsml.parse("km^((((3))))")
      right = Unitsml.parse("s^((-2))")
      before = [left.to_xml, right.to_xml]
      builder.quantity_product(left, right, "/")
      expect([left.to_xml, right.to_xml]).to eq(before)
    end

    it "copies fenced powers and prefixes instead of sharing them" do
      left = Unitsml.parse("km^((((3))))")
      leaf = left.value.first
      copied = builder.quantity_product(left, seconds, "/").value.first
      expect(copied.power_numerator).not_to be(leaf.power_numerator)
      expect(copied.power_numerator.value)
        .not_to be(leaf.power_numerator.value)
      expect(copied.prefix).not_to be(leaf.prefix)
    end

    it "keeps main's un-inverted dimension division" do
      result = builder.quantity_product(Unitsml.parse("dim_M"),
                                        Unitsml.parse("dim_L"), "/")
      xml = result.to_xml
      expect(xml).to eq(Unitsml.parse("dim_M/dim_L").to_xml)
      expect(Digest::SHA256.hexdigest(xml)[0, 16]).to eq("fadb9a9811d67de4")
      expect(result.value.last.power_numerator).to be_nil
    end

    it "keeps the default DSL dimension inversion" do
      result = Unitsml::Dimension.new("dim_M") / Unitsml::Dimension.new("dim_L")
      expect(result.value.last.power_numerator.raw_value).to eq("-1")
    end

    it "still rejects mixed units and dimensions" do
      expect do
        builder.quantity_product(Unitsml.parse("dim_L"), seconds, "*")
      end.to raise_error(Unitsml::Errors::MixedTermsError)
    end
  end

  describe "Builder.copy_formula" do
    let(:builder) { Unitsml::Compose::Builder }
    let(:area) do
      Unitsml.compose(units: [{ unit: "m", prefix: "k", power: 2 }],
                      name: "area")
    end

    it "returns nil for nil" do
      expect(builder.copy_formula(nil)).to be_nil
    end

    it "keeps the parsed m/s text and tree" do
      formula = Unitsml.parse("m/s")
      copy = builder.copy_formula(formula)
      expect(copy.norm_text).to eq("m/s")
      expect(copy.to_xml).to eq(formula.to_xml)
    end

    it "keeps grouped and root wrappers" do
      %w[((m*s))*s sqrt(m)].each do |source|
        parsed = Unitsml.parse(source)
        copy = builder.copy_formula(parsed)
        expect([copy.to_asciimath, copy.norm_text])
          .to eq([parsed.to_asciimath, parsed.norm_text])
      end
    end

    def mutable_parts(formula)
      leaf = formula.value.first
      [formula.value, leaf, leaf.power_numerator, leaf.prefix,
       formula.norm_text, formula.explicit_value]
    end

    it "copies the mutable tree, powers, prefixes, text and metadata" do
      copy = builder.copy_formula(area)
      mutable_parts(copy).zip(mutable_parts(area)).each do |copied, original|
        expect(copied).not_to be(original)
      end
    end

    it "keeps the original intact when the copy changes in place" do
      copy = builder.copy_formula(area)
      copy.value.clear
      copy.norm_text.replace("changed")
      copy.explicit_value[:name] = "other"
      expect([area.value.size, area.norm_text, area.explicit_value[:name]])
        .to eq([1, "km^(2)", "area"])
    end
  end

  describe "regressions" do
    it "does not break parsing of da-/h-prefixed derived units" do
      expect { Unitsml.parse("hPa").to_xml }.not_to raise_error
    end

    it "renders division by an inverse term without a spurious ^1" do
      formula = Unitsml::Unit.new("W") / Unitsml::Unit.new("A", -1)
      # dividing by A^-1 leaves A with no exponent (never "^1"), joined by "/"
      expect(formula.value.last.power_numerator).to be_nil
      expect(formula.to_asciimath).to eq("W/A")
    end

    it "fails fast on a blank or missing unit reference" do
      expect { Unitsml.compose(units: [{ power: 2 }]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
      expect { Unitsml.compose(units: [""]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "accepts a single Hash entry not wrapped in an array" do
      formula = Unitsml.compose(units: { unit: "m", power: 2 })
      expect(formula.to_latex).to eq(Unitsml.parse("m^2").to_latex)
    end

    it "inverts a parsed grouped or sqrt operand when dividing" do
      grouped = Unitsml::Unit.new("W") / Unitsml.parse("((m*s))")
      expect(grouped.to_xml).to eq(Unitsml.parse("W/((m*s))").to_xml)
      rooted = Unitsml::Unit.new("W") / Unitsml.parse("sqrt(m)")
      expect(rooted.to_xml).to eq(Unitsml.parse("W/sqrt(m)").to_xml)
    end

    it "inverts a parsed operand containing internal division" do
      divided = Unitsml::Unit.new("W") / Unitsml.parse("m/s")
      expect(divided.to_xml).to eq(Unitsml.parse("W/(m/s)").to_xml)
      doubled = Unitsml::Unit.new("W") / Unitsml.parse("m//s")
      expect(doubled.to_xml).to eq(Unitsml.parse("W/(m//s)").to_xml)
    end

    it "does not mutate a parsed operand it divides by" do
      operand = Unitsml.parse("((m*s))")
      before = operand.to_xml
      Unitsml::Unit.new("W") / operand
      expect(operand.to_xml).to eq(before)
    end

    it "fails fast with the same error for a nil entry" do
      expect { Unitsml.compose(units: [nil]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "treats a blank prefix as no prefix rather than crashing" do
      expect(Unitsml::Unit.new("m", prefix: "").prefix).to be_nil
    end

    it "guards a Sqrt-wrapped dimension against mixing with a unit" do
      expect { Unitsml::Unit.new("m") * Unitsml.parse("sqrt(dim_L)") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end

    it "emits no Quantity for an explicit but unresolvable quantity" do
      xml = Unitsml.compose(units: ["Hz"], quantity: "bogus_qty").to_xml
      expect(xml).not_to include("<Quantity")
    end

    it "omits dimensionURL (not a broken \"#\") when the dim id is unknown" do
      composed = Unitsml.compose(units: [{ unit: "Pa", prefix: "h" }, "s"],
                                 quantity: "pressure").to_xml
      parsed = Unitsml.parse("hPa*s").to_xml(quantity: "pressure")
      [composed, parsed].each do |xml|
        expect(xml).to include("<Quantity")
        expect(xml).not_to include('dimensionURL="#"')
      end
    end

    it "explains an invalid Number power without mentioning Float" do
      bad = Unitsml::Number.new("abc")
      expect { Unitsml.compose(units: [{ unit: "m", power: bad }]) }
        .to raise_error(Unitsml::Errors::InvalidPowerError,
                        /Invalid Number power/)
    end
  end
end
