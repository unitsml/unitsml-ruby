require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) do
    described_class.new(exp).parse.to_asciimath(
      respond_to?(:options) ? options : {}
    )
  end

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    let(:expected_value) { "mm*s^-2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }

    let(:expected_value) { "um" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }

    let(:expected_value) { "degK" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }

    let(:expected_value) { "'" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }

    let(:expected_value) { "rad" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }

    let(:expected_value) { "Hz" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg)" }

    let(:expected_value) { "kg" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }

    let(:expected_value) { "m" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    let(:expected_value) { "Hz^0.5" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(g)" }

    let(:expected_value) { "g" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(hp)" }

    let(:expected_value) { "hp" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) { "kg*s^-2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(mbar)" }

    let(:expected_value) { "mbar" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(p-)" }

    let(:expected_value) { "p" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(h-)" }

    let(:expected_value) { "h" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(da-)" }

    let(:expected_value) { "da" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(u-)" }

    let(:expected_value) { "u" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(A*C^3)" }

    let(:expected_value) { "A*C^3" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(A/C^-3)" }

    let(:expected_value) { "A/C^3" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(J/kg*K)" }

    let(:expected_value) { "J/kg^-1*K^-1" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }

    let(:expected_value) { "kg^-2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) { "kg*s^-2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }

    let(:expected_value) { "mW*cm^-2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }

    let(:expected_value) { "Theta*L^2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }

    let(:expected_value) { "Theta^10*L^2" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100, multiplier: xx)" }

    let(:expected_value) { "Hz^10xxd^100" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(((Hz^10))*(darcy^100), multiplier: xx)" }

    let(:expected_value) { "(Hz^10)xxd^100" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(((dim_Theta^10*dim_L^2)))" }
    let(:expected_value) { "Theta^10*L^2" }
    let(:options) { { explicit_parenthesis: false } }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to eq(expected_value)
    end
  end

  describe "implicit extender" do
    context "implicit extender example #1 from issue#53" do
      let(:exp) { "unitsml(J(kg*K))" }
      let(:expected_value) { "J(kg*K)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #2 from issue#53" do
      let(:exp) { "unitsml(J kg^-1 * K^-1)" }
      let(:expected_value) { "J kg^-1*K^-1" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #3 from issue#53" do
      let(:exp) { "unitsml(J/mol * K)" }
      let(:expected_value) { "J/mol^-1*K^-1" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #4 from issue#53" do
      let(:exp) { "unitsml(J/(mol * K))" }
      let(:expected_value) { "J/mol^-1*K^-1" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #5" do
      let(:exp) { "unitsml((mol * K)J)" }
      let(:expected_value) { "(mol*K)J" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #6" do
      let(:exp) { "unitsml((mol * K) J)" }
      let(:expected_value) { "(mol*K)J" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #7" do
      let(:exp) { "unitsml((mol * K)(J))" }
      let(:expected_value) { "(mol*K)(J)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #8" do
      let(:exp) { "unitsml((mol * K)(J*K))" }
      let(:expected_value) { "(mol*K)(J*K)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #9" do
      let(:exp) { "unitsml(E_erlang(mm)*kg)" }
      let(:expected_value) { "E(mm)*kg" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #10" do
      let(:exp) { "unitsml(dim_Theta(dim_phi))" }
      let(:expected_value) { "Theta(phi)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #11" do
      let(:exp) { "unitsml((dim_Theta)dim_L)" }
      let(:expected_value) { "(Theta)L" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #12" do
      let(:exp) { "unitsml(dim_Theta dim_L)" }
      let(:expected_value) { "Theta L" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #13" do
      let(:exp) { "unitsml(dim_phi (dim_Theta dim_L))" }
      let(:expected_value) { "phi(Theta L)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #14" do
      let(:exp) { "unitsml((dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) { "(phi(I))((Theta)L)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #15" do
      let(:exp) { "unitsml(sqrt(dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) { "phi(I)((Theta)L)" }

      it "matches the UnitsML to AsciiMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end
  end
end
