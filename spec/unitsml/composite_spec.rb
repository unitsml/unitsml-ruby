# frozen_string_literal: true

require "spec_helper"

# Composite-unit builder (issue #2): the operator DSL (Unit#* / Unit#/) and the
# Unitsml.compose keyword form, both producing a root Formula whose output
# equals the equivalent parsed string.
RSpec.describe "Unitsml composite builder" do # rubocop:disable RSpec/DescribeClass
  def unit(name, power = nil, prefix: nil)
    Unitsml::Unit.new(name, power, prefix: prefix)
  end

  describe "operator DSL" do
    it "composes W/m/sr identically to the parsed expression" do
      formula = unit("W") / unit("m") / unit("sr")
      parsed = Unitsml.parse("W*m^-1*sr^-1")
      formats = %i[to_latex to_asciimath to_unicode to_html to_xml to_mathml]
      formats.each do |fmt|
        expect(formula.public_send(fmt)).to eq(parsed.public_send(fmt))
      end
    end

    it "returns a Formula, not a Unit" do
      expect(unit("W") / unit("m")).to be_a(Unitsml::Formula)
    end

    it "takes powers from the constructor (m/s^2)" do
      formula = unit("m") / unit("s", 2)
      expect(formula.to_latex).to eq(Unitsml.parse("m*s^-2").to_latex)
    end

    it "does not mutate its operands" do
      squared = unit("s", 2)
      unit("m") / squared
      expect(squared.power_numerator).to eq(2)
    end

    it "raises when units and dimensions are mixed" do
      expect { unit("m") * Unitsml::Dimension.new("dim_L") }
        .to raise_error(Unitsml::Errors::MixedTermsError)
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
    it "resolves a short name to the canonical symbol id" do
      expect(Unitsml::Unit.new("watt")).to eq(Unitsml::Unit.new("W"))
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

    it "validates the prefix of a pre-built Unit entry" do
      bad = Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("zz"))
      expect { Unitsml.compose(units: [bad]) }
        .to raise_error(Unitsml::Errors::UnknownPrefixError)
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

    it "fails loud (not a crash) on an unsupported fenced-exponent operand" do
      expect { Unitsml::Unit.new("W") / Unitsml.parse("m^((1/2))") }
        .to raise_error(Unitsml::Errors::BaseError)
    end
  end

  describe "regressions" do
    it "does not break parsing of da-/h-prefixed derived units" do
      expect { Unitsml.parse("hPa").to_xml }.not_to raise_error
    end

    it "renders division by an inverse term without a spurious ^1" do
      formula = Unitsml::Unit.new("W") / Unitsml::Unit.new("A", -1)
      expect(formula.to_xml).to eq(Unitsml.parse("W*A").to_xml)
      expect(formula.to_asciimath).to eq(Unitsml.parse("W*A").to_asciimath)
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
  end
end
