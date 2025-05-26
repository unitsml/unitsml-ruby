require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) do
    described_class.new(exp).parse.to_html(
      respond_to?(:options) ? options : {}
    )
  end

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    let(:expected_value) { "mm&#x22c5;s<sup>&#x2212;2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }

    let(:expected_value) { "&micro;m" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }

    let(:expected_value) { "&#176;K" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }

    let(:expected_value) { "&#8242;" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }

    let(:expected_value) { "rad" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }

    let(:expected_value) { "Hz" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg)" }

    let(:expected_value) { "kg" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }

    let(:expected_value) { "m" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    let(:expected_value) { "Hz<sup>0.5</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(g)" }

    let(:expected_value) { "g" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(hp)" }

    let(:expected_value) { "hp" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) { "kg&#x22c5;s<sup>&#x2212;2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(mbar)" }

    let(:expected_value) { "mbar" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(p-)" }

    let(:expected_value) { "p" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(h-)" }

    let(:expected_value) { "h" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(da-)" }

    let(:expected_value) { "da" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(u-)" }

    let(:expected_value) { "&micro;" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(A*C^3)" }

    let(:expected_value) { "A&#x22c5;C<sup>3</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(A/C^-3)" }

    let(:expected_value) { "A&#x22c5;C<sup>3</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(J/kg*K)" }

    let(:expected_value) { "J&#x22c5;kg<sup>&#x2212;1</sup>&#x22c5;K<sup>&#x2212;1</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }

    let(:expected_value) { "kg<sup>&#x2212;2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) { "kg&#x22c5;s<sup>&#x2212;2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }

    let(:expected_value) { "mW&#x22c5;cm<sup>&#x2212;2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }

    let(:expected_value) { "&#x1D760;&#x22c5;&#x1D5AB;<sup>2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }

    let(:expected_value) { "&#x1D760;<sup>10</sup>&#x22c5;&#x1D5AB;<sup>2</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100)" }

    let(:expected_value) { "Hz<sup>10</sup>&#x22c5;d<sup>100</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(kcal_IT)" }

    let(:expected_value) { "kcal<sub>IT</sub>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(kcal_IT^100)" }

    let(:expected_value) { "kcal<sub>IT</sub><sup>100</sup>" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #29 example" do
    let(:exp) { "unitsml(dim_Theta^10*((dim_L^2)))" }

    let(:expected_value) { "&#x1D760;<sup>10</sup>&#x22c5;(&#x1D5AB;<sup>2</sup>)" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #30 example" do
    let(:exp) { "unitsml(Hz^10*((darcy^100)))" }

    let(:expected_value) { "Hz<sup>10</sup>&#x22c5;(d<sup>100</sup>)" }
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #31 example with explicit_parenthesis: false" do
    let(:exp) { "unitsml(dim_Theta^10*((dim_L^2)))" } # Input with explicit parens
    let(:expected_value) { "&#x1D760;<sup>10</sup>&#x22c5;&#x1D5AB;<sup>2</sup>" }
    let(:options) { { explicit_parenthesis: false } }

    it "returns parslet tree of parsed Unitsml string without explicit parentheses" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end
end
