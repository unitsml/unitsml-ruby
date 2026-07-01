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

    it "composes pure dimensions like the parser" do
      formula = Unitsml.compose(units: ["dim_L", "dim_M"])
      expect(formula.to_xml).to eq(Unitsml.parse("dim_L*dim_M").to_xml)
    end

    it "raises for an empty unit list" do
      expect { Unitsml.compose(units: []) }.to raise_error(ArgumentError)
    end

    it "raises when units and dimensions are mixed" do
      expect { Unitsml.compose(units: ["W", "dim_L"]) }
        .to raise_error(Unitsml::Errors::MixedTermsError)
    end

    it "raises for an unknown unit reference" do
      expect { Unitsml.compose(units: ["zzz"]) }
        .to raise_error(Unitsml::Errors::UnknownUnitError)
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

  describe "power coercion (Number.coerce)" do
    it "mirrors the parser exponent strings" do
      cases = { 2 => "2", -1 => "-1", 1 => "1", 2.0 => "2",
                Rational(1, 2) => "1/2", Rational(2, 1) => "2" }
      cases.each do |input, expected|
        expect(Unitsml::Number.coerce(input).raw_value).to eq(expected)
      end
    end

    it "rejects a non-integer Float power" do
      expect { Unitsml::Number.coerce(0.5) }.to raise_error(ArgumentError)
    end

    it "passes nil and existing Numbers through" do
      number = Unitsml::Number.new("3")
      expect(Unitsml::Number.coerce(nil)).to be_nil
      expect(Unitsml::Number.coerce(number)).to be(number)
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
  end
end
