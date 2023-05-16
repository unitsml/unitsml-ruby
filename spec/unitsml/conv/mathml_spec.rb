require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse.to_mathml }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant="normal">mm</mi>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant="normal">s</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&micro;m</mi>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mrow>
              <mi mathvariant='normal'>Hz</mi>
            </mrow>
            <mrow>
              <mn>0.5</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>s</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(p-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          p
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(h-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          h
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(da-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          da
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(u-)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          &micro;
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>C</mi>
            </mrow>
            <mrow>
              <mn>3</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>C</mi>
            </mrow>
            <mrow>
              <mn>3</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>kg</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant='normal'>K</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>1</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mrow>
              <mi mathvariant='normal'>kg</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>s</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mi mathvariant='normal'>cm</mi>
            </mrow>
            <mrow>
              <mo>&#x2212;</mo>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
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
            <mrow>
              <mn>10</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant='sans-serif'>L</mi>
            </mrow>
            <mrow>
              <mn>2</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100)" }

    let(:expected_value) do
      <<~MATHML
        <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <msup>
            <mrow>
              <mi mathvariant='normal'>Hz</mi>
            </mrow>
            <mrow>
              <mn>10</mn>
            </mrow>
          </msup>
          <mo>&#x22c5;</mo>
          <msup>
            <mrow>
              <mi mathvariant='normal'>d</mi>
            </mrow>
            <mrow>
              <mn>100</mn>
            </mrow>
          </msup>
        </math>
      MATHML
    end
    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end
end
