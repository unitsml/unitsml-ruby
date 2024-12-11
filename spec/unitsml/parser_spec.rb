require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(K/(kg*m))" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("K"),
            Unitsml::Extender.new("/"),
            Unitsml::Formula.new([
              Unitsml::Unit.new("g", "-1", prefix: Unitsml::Prefix.new("k")),
              Unitsml::Extender.new("*"),
              Unitsml::Unit.new("m", "-1"),
            ])
          ])
        ],
        explicit_value: nil,
        norm_text: "K/(kg*m)",
        orig_text: "K/(kg*m)",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(m, quantity: NISTq103)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Unit.new("m"),
        ],
        explicit_value: { quantity: "NISTq103" },
        norm_text: "m",
        orig_text: "m, quantity: NISTq103",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(cal_th/cm^2, name: langley)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Formula.new([
            Unitsml::Unit.new("cal_th"),
            Unitsml::Extender.new("/"),
            Unitsml::Unit.new("m", "-2", prefix: Unitsml::Prefix.new("c")),
          ])
        ],
        explicit_value: { name: "langley" },
        norm_text: "cal_th/cm^2",
        orig_text: "cal_th/cm^2, name: langley",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(m, symbol: La)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Unit.new("m"),
        ],
        explicit_value: { symbol: "La" },
        norm_text: "m",
        orig_text: "m, symbol: La",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(cm*s^-2, symbol: cm cdot s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Formula.new([
            Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("c")),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("s", "-2")
          ])
        ],
        explicit_value: { symbol: "cm cdot s^-2"},
        root: true,
        orig_text: "cm*s^-2, symbol: cm cdot s^-2",
        norm_text: "cm*s^-2"
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(cm*s^-2, multiplier: xx)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Formula.new([
            Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("c")),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("s", "-2"),
          ])
        ],
        explicit_value: { multiplier: "xx" },
        norm_text: "cm*s^-2",
        orig_text: "cm*s^-2, multiplier: xx",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new(
        [
          Unitsml::Formula.new([
            Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("m")),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("s", "-2"),
          ]),
        ],
        root: true,
        orig_text: "mm*s^-2",
        norm_text: "mm*s^-2",
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(um)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("m", prefix: Unitsml::Prefix.new("u")),
        ],
        norm_text: "um",
        orig_text: "um",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(degK)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("degK"),
        ],
        norm_text: "degK",
        orig_text: "degK",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(prime)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("prime"),
        ],
        norm_text: "prime",
        orig_text: "prime",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(rad)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("rad"),
        ],
        norm_text: "rad",
        orig_text: "rad",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(Hz)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("Hz"),
        ],
        norm_text: "Hz",
        orig_text: "Hz",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(kg)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("g", prefix: Unitsml::Prefix.new("k")),
        ],
        norm_text: "kg",
        orig_text: "kg",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(m)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("m"),
        ],
        norm_text: "m",
        orig_text: "m",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Sqrt.new(
            Unitsml::Unit.new("Hz", "0.5"),
          ),
        ],
        norm_text: "sqrt(Hz)",
        orig_text: "sqrt(Hz)",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(g)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("g"),
        ],
        norm_text: "g",
        orig_text: "g",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(hp)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("hp"),
        ],
        norm_text: "hp",
        orig_text: "hp",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("g", prefix: Unitsml::Prefix.new("k")),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("s", "-2")
          ])
        ],
        norm_text: "kg*s^-2",
        orig_text: "kg*s^-2",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(mbar)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("bar", prefix: Unitsml::Prefix.new("m"))
        ],
        norm_text: "mbar",
        orig_text: "mbar",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(p-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Prefix.new("p", true)
        ],
        norm_text: "p-",
        orig_text: "p-",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(h-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Prefix.new("h", true)
        ],
        norm_text: "h-",
        orig_text: "h-",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(da-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Prefix.new("da", true)
        ],
        norm_text: "da-",
        orig_text: "da-",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(u-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Prefix.new("u", true)
        ],
        norm_text: "u-",
        orig_text: "u-",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(A*C^3)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("A"),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("C", "3"),
          ])
        ],
        norm_text: "A*C^3",
        orig_text: "A*C^3",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(A/C^-3)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("A"),
            Unitsml::Extender.new("/"),
            Unitsml::Unit.new("C", "3"),
          ])
        ],
        norm_text: "A/C^-3",
        orig_text: "A/C^-3",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(J/kg*K)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("J"),
            Unitsml::Extender.new("/"),
            Unitsml::Formula.new([
              Unitsml::Unit.new("g", "-1", prefix: Unitsml::Prefix.new("k")),
              Unitsml::Extender.new("*"),
              Unitsml::Unit.new("K", "-1"),
            ])
          ])
        ],
        norm_text: "J/kg*K",
        orig_text: "J/kg*K",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(kg^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Unit.new("g", "-2", prefix: Unitsml::Prefix.new("k")),
        ],
        norm_text: "kg^-2",
        orig_text: "kg^-2",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("W", prefix: Unitsml::Prefix.new("m")),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("m", "-2", prefix: Unitsml::Prefix.new("c")),
          ])
        ],
        norm_text: "mW*cm(-2)",
        orig_text: "mW*cm(-2)",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #29 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Dimension.new("dim_Theta"),
            Unitsml::Extender.new("*"),
            Unitsml::Dimension.new("dim_L", "2"),
          ])
        ],
        norm_text: "dim_Theta*dim_L^2",
        orig_text: "dim_Theta*dim_L^2",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #30 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Dimension.new("dim_Theta", "10"),
            Unitsml::Extender.new("*"),
            Unitsml::Dimension.new("dim_L", "2"),
          ])
        ],
        norm_text: "dim_Theta^10*dim_L^2",
        orig_text: "dim_Theta^10*dim_L^2",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #31 example" do
    let(:exp) { "unitsml(Hz^10*darcy^-100)" }

    it "returns parslet tree of parsed Unitsml string" do
      expected_value = Unitsml::Formula.new([
          Unitsml::Formula.new([
            Unitsml::Unit.new("Hz", "10"),
            Unitsml::Extender.new("*"),
            Unitsml::Unit.new("darcy", "-100"),
          ])
        ],
        norm_text: "Hz^10*darcy^-100",
        orig_text: "Hz^10*darcy^-100",
        root: true,
      )
      expect(formula).to eq(expected_value)
    end
  end
end
