require "spec_helper"

RSpec.describe Unitsml::Parser do

  before(:all) { Lutaml::Model::Config.xml_adapter_type = :ox }

  subject(:formula) { described_class.new(exp).parse }
  subject(:mathml) { formula.to_mathml }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">mm</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant="normal">s</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&#xb5;m</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&#176;K</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&#8242;</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>rad</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>Hz</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>kg</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>m</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mi mathvariant='normal'>Hz</mi>
            <mn>0.5</mn>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(g)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>g</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(hp)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>hp</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>kg</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>s</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(mbar)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>mbar</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(p-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi>p</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(h-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi>h</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(da-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi>da</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(u-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi>&#xb5;</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(A*C^3)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>A</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>C</mi>
            <mn>3</mn>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(A/C^-3)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>A</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>C</mi>
            <mn>3</mn>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(J/kg*K)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>J</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>kg</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>K</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mi mathvariant='normal'>kg</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>kg</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>s</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>mW</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>cm</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="sans-serif">&#x398;</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant="sans-serif">L</mi>
            </mrow>
            <mn>2</mn>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mrow>
              <mi mathvariant='sans-serif'>&#x398;</mi>
            </mrow>
            <mn>10</mn>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant='sans-serif'>L</mi>
            </mrow>
            <mn>2</mn>
          </msup>
        </math>
      MATHML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mi mathvariant='normal'>Hz</mi>
            <mn>10</mn>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant='normal'>d</mi>
            <mn>100</mn>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(R-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi>R</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(Rm*A)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">Rm</mi>
          <mo>X</mo>
          <mi mathvariant="normal">A</mi>
        </math>
      MATHML
    end

    let(:space_expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">Rm</mi>
          <mo rspace="thickmathspace">&#x2062;</mo>
          <mi mathvariant="normal">A</mi>
        </math>
      MATHML
    end

    let(:nospace_expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">Rm</mi>
          <mo>&#x2062;</mo>
          <mi mathvariant="normal">A</mi>
        </math>
      MATHML
    end

    it "matches Unitsml to MathML converted string with custom multiplier argument" do
      expect(formula.to_mathml(multiplier: "X")).to be_equivalent_to(expected_value)
    end

    it "matches Unitsml to MathML converted string with :space multiplier argument" do
      expect(formula.to_mathml(multiplier: :space)).to be_equivalent_to(space_expected_value)
    end

    it "matches Unitsml to MathML converted string with :nospace multiplier argument" do
      expect(formula.to_mathml(multiplier: :nospace)).to be_equivalent_to(nospace_expected_value)
    end
  end

  context "contains plurimath/plurimath#356 Unitsml #28 example" do
    let(:exp) { "unitsml(kg*m^-1*s^-1*K^(-1//2))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">kg</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant="normal">m</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant="normal">s</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mi mathvariant="normal">K</mi>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1//2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "matches MathML string" do
      expect(mathml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #29 example" do
    let(:exp) { "unitsml(Rm*((A)))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">Rm</mi>
          <mo>X</mo>
          <mrow>
            <mo>(</mo>
            <mi mathvariant="normal">A</mi>
            <mo>)</mo>
          </mrow>
        </math>
      MATHML
    end

    it "matches Unitsml to MathML converted string with custom multiplier argument" do
      expect(formula.to_mathml(multiplier: "X")).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #29 example" do
    let(:exp) { "unitsml(Rm*((A)))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">Rm</mi>
          <mo>X</mo>
          <mi mathvariant="normal">A</mi>
        </math>
      MATHML
    end

    it "matches Unitsml to MathML converted string with custom multiplier argument" do
      expect(formula.to_mathml(multiplier: "X", explicit_parenthesis: false)).to be_equivalent_to(expected_value)
    end
  end

  describe "implicit extender" do
    context "implicit extender example #1 from issue#53" do
      let(:exp) { "unitsml(J(kg*K))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">J</mi>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">kg</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #2 from issue#53" do
      let(:exp) { "unitsml(J kg^-1 * K^-1)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">J</mi>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">kg</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">K</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #3 from issue#53" do
      let(:exp) { "unitsml(J/mol * K)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">J</mi>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">mol</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">K</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #4 from issue#53" do
      let(:exp) { "unitsml(J/(mol * K))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">J</mi>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">mol</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
            <mo>&#x22c5;</mo>
            <msup>
              <mi mathvariant="normal">K</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>1</mn>
              </mrow>
            </msup>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #5" do
      let(:exp) { "unitsml((mol * K)J)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">mol</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
            <mi mathvariant="normal">J</mi>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #6" do
      let(:exp) { "unitsml((mol * K) J)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">mol</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
            <mi mathvariant="normal">J</mi>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #7" do
      let(:exp) { "unitsml((mol * K)(J))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">mol</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">J</mi>
              <mo>)</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #8" do
      let(:exp) { "unitsml((mol * K)(J*K))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">mol</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">J</mi>
              <mo>)</mo>
              <mi mathvariant="normal">K</mi>
              <mo>&#x22c5;</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #9" do
      let(:exp) { "unitsml(E_erlang(mm)*kg)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">E</mi>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="normal">mm</mi>
              <mo>)</mo>
            </mrow>
            <mo>&#x22c5;</mo>
            <mi mathvariant="normal">kg</mi>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #10" do
      let(:exp) { "unitsml(dim_Theta(dim_phi))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="sans-serif">Θ</mi>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="sans-serif">φ</mi>
              <mo>)</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #11" do
      let(:exp) { "unitsml((dim_Theta)dim_L)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="sans-serif">Θ</mi>
              <mo>)</mo>
            </mrow>
            <mi mathvariant="sans-serif">L</mi>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #12" do
      let(:exp) { "unitsml(dim_Theta dim_L)" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="sans-serif">Θ</mi>
            <mo>&#x22c5;</mo>
            <mi mathvariant="sans-serif">L</mi>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #13" do
      let(:exp) { "unitsml(dim_phi (dim_Theta dim_L))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="sans-serif">φ</mi>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="sans-serif">Θ</mi>
              <mo>)</mo>
              <mi mathvariant="sans-serif">L</mi>
              <mo>&#x22c5;</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #14" do
      let(:exp) { "unitsml((dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mrow>
              <mo>(</mo>
              <mi mathvariant="sans-serif">φ</mi>
              <mrow>
                <mo>(</mo>
                <mi mathvariant="sans-serif">I</mi>
                <mo>)</mo>
              </mrow>
              <mo>)</mo>
            </mrow>
            <mrow>
              <mo>(</mo>
              <mrow>
                <mo>(</mo>
                <mi mathvariant="sans-serif">Θ</mi>
                <mo>)</mo>
              </mrow>
              <mi mathvariant="sans-serif">L</mi>
              <mo>)</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end

    context "implicit extender example #15" do
      let(:exp) { "unitsml(sqrt(dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) do
        <<~MATHML
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="sans-serif">φ</mi>
            <mrow>
              <mo>(</mo>
              <mi mathvariant="sans-serif">I</mi>
              <mo>)</mo>
            </mrow>
            <mrow>
              <mo>(</mo>
              <mrow>
                <mo>(</mo>
                <mi mathvariant="sans-serif">Θ</mi>
                <mo>)</mo>
              </mrow>
              <mi mathvariant="sans-serif">L</mi>
              <mo>)</mo>
            </mrow>
          </math>
        MATHML
      end

      it "matches the UnitsML to MathML converted value" do
        expect(mathml).to be_equivalent_to(expected_value)
      end
    end
  end
end
