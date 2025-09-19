require "spec_helper"

RSpec.describe Unitsml::Parser do

  before(:all) { Lutaml::Model::Config.xml_adapter_type = :ox }

  subject(:formula) { described_class.new(exp).parse }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^((-2)))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_mm.s-2" dimensionURL="#D_LT-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">mm*s^-2</UnitName>
          <UnitSymbol type="HTML">mm&#x22c5;s<sup>(&#x2212;2)</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant='normal'>mm</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant='normal'>s</mi>
                <mrow>
                  <mo>(</mo>
                  <mrow>
                    <mo>&#x2212;</mo>
                    <mn>2</mn>
                  </mrow>
                  <mo>)</mo>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="metre" prefix="m"/>
            <EnumeratedRootUnit unit="second" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-3" xml:id="NISTp10_-3">
          <PrefixName xml:lang="en">milli</PrefixName>
          <PrefixSymbol type="ASCII">m</PrefixSymbol>
          <PrefixSymbol type="unicode">m</PrefixSymbol>
          <PrefixSymbol type="LaTeX">m</PrefixSymbol>
          <PrefixSymbol type="HTML">m</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_LT-2">
          <Length symbol="L" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um, name: micro meter)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_um" dimensionURL="#NISTd1">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">micro meter</UnitName>
          <UnitSymbol type="HTML">&micro;m</UnitSymbol>
          <UnitSymbol type="MathMl"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>µm</mi>
        </math>
        </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="metre" prefix="u"/>
          </RootUnits>
        </Unit>


        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-6" xml:id="NISTp10_-6">
          <PrefixName xml:lang="en">micro</PrefixName>
          <PrefixSymbol type="ASCII">u</PrefixSymbol>
          <PrefixSymbol type="unicode">μ</PrefixSymbol>
          <PrefixSymbol type="LaTeX">$mu$</PrefixSymbol>
          <PrefixSymbol type="HTML">&micro;</PrefixSymbol>
        </Prefix>


        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd1">
          <Length symbol="L" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu5" dimensionURL="#NISTd5">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">kelvin</UnitName>
          <UnitSymbol type="HTML">&#176;K</UnitSymbol>
          <UnitSymbol type="MathMl"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&#176;K</mi>
        </math>
        </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd5">
          <ThermodynamicTemperature symbol="Theta" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu147">
          <UnitSystem name="not_SI" type="not_SI" xml:lang="en-US"/>
          <UnitName xml:lang="en">arcminute</UnitName>
          <UnitSymbol type="HTML">&#8242;</UnitSymbol>
          <UnitSymbol type="MathMl"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
          <mi mathvariant='normal'>&#8242;</mi>
        </math>
        </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd9">
          <PlaneAngle symbol="phi" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq9" quantityType="base" dimensionURL="#NISTd9">
          <QuantityName xml:lang="en-US">plane angle</QuantityName>
          <QuantityName xml:lang="en-US">angle</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu9" dimensionURL="#D_L0">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">radian</UnitName>
          <UnitSymbol type="HTML">rad</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">rad</mi>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd98">
          <PlaneAngle symbol="phi" powerNumerator="1"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L0">
          <Length symbol="L" powerNumerator="0"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu31" dimensionURL="#NISTd101">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">hertz</UnitName>
          <UnitSymbol type="HTML">Hz</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">Hz</mi>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd24">
          <Time symbol="T" powerNumerator="-1"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd101">
          <Time symbol="T" powerNumerator="-1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq45" quantityType="base" dimensionURL="#NISTd24">
          <QuantityName xml:lang="en-US">frequency</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg, name: custom kilogram)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu2" dimensionURL="#NISTd2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">custom kilogram</UnitName>
          <UnitSymbol type="HTML">kg</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">kg</mi>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="gram" prefix="k"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd2">
          <Mass symbol="M" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq2" quantityType="base" dimensionURL="#NISTd2">
          <QuantityName xml:lang="en-US">mass</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu1" dimensionURL="#NISTd1">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">metre</UnitName>
          <UnitSymbol type="HTML">m</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">m</mi>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd1">
          <Length symbol="L" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_Hz0.5" dimensionURL="#D_T-0.5">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">Hz^0.5</UnitName>
          <UnitSymbol type="HTML">Hz<sup>0.5</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">Hz</mi>
                <mn>0.5</mn>
              </msup>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_T-0.5">
          <Time symbol="T" powerNumerator="-0.5"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(g)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu27" dimensionURL="#NISTd2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">gram</UnitName>
          <UnitSymbol type="HTML">g</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">g</mi>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd2">
          <Mass symbol="M" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq2" quantityType="base" dimensionURL="#NISTd2">
          <QuantityName xml:lang="en-US">mass</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(hp)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu284">
          <UnitSystem name="not_SI" type="not_SI" xml:lang="en-US"/>
          <UnitName xml:lang="en">horsepower</UnitName>
          <UnitSymbol type="HTML">hp</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">hp</mi>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd16">
          <Length symbol="L" powerNumerator="2"/>
          <Mass symbol="M" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="-3"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq20" quantityType="base" dimensionURL="#NISTd16">
          <QuantityName xml:lang="en-US">power</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(kg*s^-2)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_kg.s-2" dimensionURL="#D_MT-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">kg*s^-2</UnitName>
          <UnitSymbol type="HTML">kg&#x22c5;s<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">kg</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">s</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="gram" prefix="k"/>
            <EnumeratedRootUnit unit="second" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_MT-2">
          <Mass symbol="M" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(mbar)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu362">
          <UnitSystem name="not_SI" type="not_SI" xml:lang="en-US"/>
          <UnitName xml:lang="en">millibar</UnitName>
          <UnitSymbol type="HTML">mbar</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">mbar</mi>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="bar" prefix="m"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-3" xml:id="NISTp10_-3">
          <PrefixName xml:lang="en">milli</PrefixName>
          <PrefixSymbol type="ASCII">m</PrefixSymbol>
          <PrefixSymbol type="unicode">m</PrefixSymbol>
          <PrefixSymbol type="LaTeX">m</PrefixSymbol>
          <PrefixSymbol type="HTML">m</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd14">
          <Length symbol="L" powerNumerator="-1"/>
          <Mass symbol="M" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(d-)" }
    let(:expected_value) do
      <<~XML
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-1" xml:id="NISTp10_-1">
          <PrefixName xml:lang="en">deci</PrefixName>
          <PrefixSymbol type="ASCII">d</PrefixSymbol>
          <PrefixSymbol type="unicode">d</PrefixSymbol>
          <PrefixSymbol type="LaTeX">d</PrefixSymbol>
          <PrefixSymbol type="HTML">d</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd3">
          <Time symbol="T" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq3" quantityType="base" dimensionURL="#NISTd3">
          <QuantityName xml:lang="en-US">time</QuantityName>
          <QuantityName xml:lang="en-US">duration</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(h-)" }
    let(:expected_value) do
      <<~XML
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="2" xml:id="NISTp10_2">
          <PrefixName xml:lang="en">hecto</PrefixName>
          <PrefixSymbol type="ASCII">h</PrefixSymbol>
          <PrefixSymbol type="unicode">h</PrefixSymbol>
          <PrefixSymbol type="LaTeX">h</PrefixSymbol>
          <PrefixSymbol type="HTML">h</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd3">
          <Time symbol="T" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq3" quantityType="base" dimensionURL="#NISTd3">
          <QuantityName xml:lang="en-US">time</QuantityName>
          <QuantityName xml:lang="en-US">duration</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(da-)" }
    let(:expected_value) do
      <<~XML
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="1" xml:id="NISTp10_1">
          <PrefixName xml:lang="en">deka</PrefixName>
          <PrefixSymbol type="ASCII">da</PrefixSymbol>
          <PrefixSymbol type="unicode">da</PrefixSymbol>
          <PrefixSymbol type="LaTeX">da</PrefixSymbol>
          <PrefixSymbol type="HTML">da</PrefixSymbol>
        </Prefix>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(u-)" }
    let(:expected_value) do
      <<~XML
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-6" xml:id="NISTp10_-6">
          <PrefixName xml:lang="en">micro</PrefixName>
          <PrefixSymbol type="ASCII">u</PrefixSymbol>
          <PrefixSymbol type="unicode">μ</PrefixSymbol>
          <PrefixSymbol type="LaTeX">$mu$</PrefixSymbol>
          <PrefixSymbol type="HTML">&micro;</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd2">
          <Mass symbol="M" powerNumerator="1"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq2" quantityType="base" dimensionURL="#NISTd2">
          <QuantityName xml:lang="en-US">mass</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(A*C^3)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_A.C3" dimensionURL="#D_M3I4">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">A*C^3</UnitName>
          <UnitSymbol type="HTML">A&#x22c5;C<sup>3</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">A</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">C</mi>
                <mn>3</mn>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="ampere"/>
            <EnumeratedRootUnit unit="coulomb" powerNumerator="3"/>
          </RootUnits>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_M3I4">
          <Mass symbol="M" powerNumerator="3"/>
          <ElectricCurrent symbol="I" powerNumerator="4"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(A/C^-3)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_A.C3" dimensionURL="#D_M3I4">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">A*C^3</UnitName>
          <UnitSymbol type="HTML">A&#x22c5;C<sup>3</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">A</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">C</mi>
                <mn>3</mn>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="ampere"/>
            <EnumeratedRootUnit unit="coulomb" powerNumerator="3"/>
          </RootUnits>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_M3I4">
          <Mass symbol="M" powerNumerator="3"/>
          <ElectricCurrent symbol="I" powerNumerator="4"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(J/kg*K)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu13.u27p10_3e-1/1.u5e-1/1" dimensionURL="#D_L2M0T-2Theta-1">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">joule per kilogram kelvin</UnitName>
          <UnitSymbol type="HTML">J&#x22c5;kg<sup>&#x2212;1</sup>&#x22c5;K<sup>&#x2212;1</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
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
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="joule"/>
            <EnumeratedRootUnit unit="gram" prefix="k" powerNumerator="-1"/>
            <EnumeratedRootUnit unit="kelvin" powerNumerator="-1"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd40">
          <Length symbol="L" powerNumerator="2"/>
          <Time symbol="T" powerNumerator="-2"/>
          <ThermodynamicTemperature symbol="Theta" powerNumerator="-1"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L2M0T-2Theta-1">
          <Length symbol="L" powerNumerator="2"/>
          <Mass symbol="M" powerNumerator="0"/>
          <Time symbol="T" powerNumerator="-2"/>
          <ThermodynamicTemperature symbol="Theta" powerNumerator="-1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_kg-2" dimensionURL="#D_M-2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">kg^-2</UnitName>
          <UnitSymbol type="HTML">kg<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">kg</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="gram" prefix="k" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_M-2">
          <Mass symbol="M" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(kg*s^-2)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_kg.s-2" dimensionURL="#D_MT-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">kg*s^-2</UnitName>
          <UnitSymbol type="HTML">kg&#x22c5;s<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">kg</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">s</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="gram" prefix="k"/>
            <EnumeratedRootUnit unit="second" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_MT-2">
          <Mass symbol="M" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_mW.cm-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">mW*cm^-2</UnitName>
          <UnitSymbol type="HTML">mW&#x22c5;cm<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">mW</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">cm</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="watt" prefix="m"/>
            <EnumeratedRootUnit unit="metre" prefix="c" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-3" xml:id="NISTp10_-3">
          <PrefixName xml:lang="en">milli</PrefixName>
          <PrefixSymbol type="ASCII">m</PrefixSymbol>
          <PrefixSymbol type="unicode">m</PrefixSymbol>
          <PrefixSymbol type="LaTeX">m</PrefixSymbol>
          <PrefixSymbol type="HTML">m</PrefixSymbol>
        </Prefix>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-2" xml:id="NISTp10_-2">
          <PrefixName xml:lang="en">centi</PrefixName>
          <PrefixSymbol type="ASCII">c</PrefixSymbol>
          <PrefixSymbol type="unicode">c</PrefixSymbol>
          <PrefixSymbol type="LaTeX">c</PrefixSymbol>
          <PrefixSymbol type="HTML">c</PrefixSymbol>
        </Prefix>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^((2)))" }
    let(:expected_value) do
      <<~XML
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L2Theta">
          <Length symbol="L" powerNumerator="2"/>
          <ThermodynamicTemperature symbol="Theta" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }
    let(:expected_value) do
      <<~XML
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L2Theta10">
          <Length symbol="L" powerNumerator="2"/>
          <ThermodynamicTemperature symbol="Theta" powerNumerator="10"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_Hz10.darcy100">
          <UnitSystem name="not_SI" type="not_SI" xml:lang="en-US"/>
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">Hz^10*darcy^100</UnitName>
          <UnitSymbol type="HTML">Hz<sup>10</sup>&#x22c5;d<sup>100</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">Hz</mi>
                <mn>10</mn>
              </msup>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">d</mi>
                <mn>100</mn>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="hertz" powerNumerator="10"/>
            <EnumeratedRootUnit unit="darcy" powerNumerator="100"/>
          </RootUnits>
        </Unit>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(sqrt(dim_Theta))" }
    let(:expected_value) do
      <<~XML
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_Theta0.5">
          <ThermodynamicTemperature symbol="Theta" powerNumerator="0.5"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(sqrt(mm))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_mm0.5" dimensionURL="#D_L0.5">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">mm^0.5</UnitName>
          <UnitSymbol type="HTML">mm<sup>0.5</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">mm</mi>
                <mn>0.5</mn>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="metre" prefix="m" powerNumerator="0.5"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-3" xml:id="NISTp10_-3">
          <PrefixName xml:lang="en">milli</PrefixName>
          <PrefixSymbol type="ASCII">m</PrefixSymbol>
          <PrefixSymbol type="unicode">m</PrefixSymbol>
          <PrefixSymbol type="LaTeX">m</PrefixSymbol>
          <PrefixSymbol type="HTML">m</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L0.5">
          <Length symbol="L" powerNumerator="0.5"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #29 example" do
    let(:exp) { "unitsml(GHz//V)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_GHz.V-1" dimensionURL="#D_L-2M-1T2I">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">GHz*V^-1</UnitName>
          <UnitSymbol type="HTML">GHz&#x22c5;V<sup>&#x2212;1</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">GHz</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">V</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>1</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="hertz" prefix="G"/>
            <EnumeratedRootUnit unit="volt" powerNumerator="-1"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="9" xml:id="NISTp10_9">
          <PrefixName xml:lang="en">giga</PrefixName>
          <PrefixSymbol type="ASCII">G</PrefixSymbol>
          <PrefixSymbol type="unicode">G</PrefixSymbol>
          <PrefixSymbol type="LaTeX">G</PrefixSymbol>
          <PrefixSymbol type="HTML">G</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L-2M-1T2I">
          <Length symbol="L" powerNumerator="-2"/>
          <Mass symbol="M" powerNumerator="-1"/>
          <Time symbol="T" powerNumerator="2"/>
          <ElectricCurrent symbol="I" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #30 example" do
    let(:exp) { "unitsml(m^(-2))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu1e-2/1" dimensionURL="#D_L-2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">meter to the power minus two</UnitName>
          <UnitSymbol type="HTML">m<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">m</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd96">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L-2">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq190" quantityType="base" dimensionURL="#NISTd96">
          <QuantityName xml:lang="en-US" xmlns="https://schema.unitsml.org/unitsml/1.0">fluence</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #31 example" do
    let(:exp) { "unitsml(cd*sr*m^(-2),symbol:cd cdot sr cdot m^(-2))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_cd.sr.m-2" dimensionURL="#D_L-2J">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">cd*sr*m^-2</UnitName>
          <UnitSymbol type="HTML">cd&#x22c5;sr&#x22c5;m<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">cd</mi>
              <mo>&#x22c5;</mo>
              <mi mathvariant="normal">sr</mi>
              <mo>&#x22c5;</mo>
              <msup>
                <mi mathvariant="normal">m</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="candela"/>
            <EnumeratedRootUnit unit="steradian"/>
            <EnumeratedRootUnit unit="metre" powerNumerator="-2"/>
          </RootUnits>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L-2J">
          <Length symbol="L" powerNumerator="-2"/>
          <LuminousIntensity symbol="J" powerNumerator="1"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #32 example" do
    let(:exp) { "unitsml(mOhm)" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_mOhm" dimensionURL="#D_L2MT4I2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">mOhm</UnitName>
          <UnitSymbol type="HTML">m&#8486;</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">m&#8486;</mi>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="ohm" prefix="m"/>
          </RootUnits>
        </Unit>

        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="-3" xml:id="NISTp10_-3">
          <PrefixName xml:lang="en">milli</PrefixName>
          <PrefixSymbol type="ASCII">m</PrefixSymbol>
          <PrefixSymbol type="unicode">m</PrefixSymbol>
          <PrefixSymbol type="LaTeX">m</PrefixSymbol>
          <PrefixSymbol type="HTML">m</PrefixSymbol>
        </Prefix>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L2MT4I2">
          <Length symbol="L" powerNumerator="2"/>
          <Mass symbol="M" powerNumerator="1"/>
          <Time symbol="T" powerNumerator="4"/>
          <ElectricCurrent symbol="I" powerNumerator="2"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #33 example from plurimath/plurimath#321" do
    let(:exp) { "unitsml(m*kg^-2)" }
    let(:space_expected_value) do
      <<~XML
      <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" dimensionURL="#D_LM-2" xml:id="U_m.kg-2">
        <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
        <UnitName xml:lang="en">m*kg^-2</UnitName>
        <UnitSymbol type="HTML">m&#xa0;kg<sup>&#x2212;2</sup></UnitSymbol>
        <UnitSymbol type="MathMl">
          <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
            <mi mathvariant="normal">m</mi>
            <mo rspace="thickmathspace">&#x2062;</mo>
            <msup>
              <mi mathvariant="normal">kg</mi>
              <mrow>
                <mo>&#x2212;</mo>
                <mn>2</mn>
              </mrow>
            </msup>
          </math>
        </UnitSymbol>
        <RootUnits>
          <EnumeratedRootUnit unit="metre"/>
          <EnumeratedRootUnit unit="gram" prefix="k" powerNumerator="-2"/>
        </RootUnits>
      </Unit>
      <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
        <PrefixName xml:lang="en">kilo</PrefixName>
        <PrefixSymbol type="ASCII">k</PrefixSymbol>
        <PrefixSymbol type="unicode">k</PrefixSymbol>
        <PrefixSymbol type="LaTeX">k</PrefixSymbol>
        <PrefixSymbol type="HTML">k</PrefixSymbol>
      </Prefix>
      <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_LM-2">
        <Length symbol="L" powerNumerator="1"/>
        <Mass symbol="M" powerNumerator="-2"/>
      </Dimension>
      XML
    end

    let(:nospace_expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" dimensionURL="#D_LM-2" xml:id="U_m.kg-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">m*kg^-2</UnitName>
          <UnitSymbol type="HTML">m⁢kg<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">m</mi>
              <mo>⁢</mo>
              <msup>
                <mi mathvariant="normal">kg</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="metre"/>
            <EnumeratedRootUnit unit="gram" prefix="k" powerNumerator="-2"/>
          </RootUnits>
        </Unit>
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_LM-2">
          <Length symbol="L" powerNumerator="1"/>
          <Mass symbol="M" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    let(:custom_expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" dimensionURL="#D_LM-2" xml:id="U_m.kg-2">
          <UnitSystem name="SI" type="SI_derived" xml:lang="en-US"/>
          <UnitName xml:lang="en">m*kg^-2</UnitName>
          <UnitSymbol type="HTML">mXkg<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mi mathvariant="normal">m</mi>
              <mo>X</mo>
              <msup>
                <mi mathvariant="normal">kg</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit="metre"/>
            <EnumeratedRootUnit unit="gram" prefix="k" powerNumerator="-2"/>
          </RootUnits>
        </Unit>
        <Prefix xmlns="https://schema.unitsml.org/unitsml/1.0" prefixBase="10" prefixPower="3" xml:id="NISTp10_3">
          <PrefixName xml:lang="en">kilo</PrefixName>
          <PrefixSymbol type="ASCII">k</PrefixSymbol>
          <PrefixSymbol type="unicode">k</PrefixSymbol>
          <PrefixSymbol type="LaTeX">k</PrefixSymbol>
          <PrefixSymbol type="HTML">k</PrefixSymbol>
        </Prefix>
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_LM-2">
          <Length symbol="L" powerNumerator="1"/>
          <Mass symbol="M" powerNumerator="-2"/>
        </Dimension>
      XML
    end

    it "matches Unitsml to MathML converted string with :space multiplier argument" do
      expect(formula.to_xml(multiplier: :space)).to be_equivalent_to(space_expected_value)
    end

    it "matches Unitsml to MathML converted string with :nospace multiplier argument" do
      expect(formula.to_xml(multiplier: :nospace)).to be_equivalent_to(nospace_expected_value)
    end

    it "matches Unitsml to MathML converted string with custom multiplier argument" do
      expect(formula.to_xml(multiplier: "X")).to be_equivalent_to(custom_expected_value)
    end
  end

  context "contains Unitsml #34 example" do
    let(:exp) { "unitsml((((m^-2))))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu1e-2/1" dimensionURL="#D_L-2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">meter to the power minus two</UnitName>
          <UnitSymbol type="HTML">(m<sup>&#x2212;2</sup>)</UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <mrow>
                <mo>(</mo>
                <msup>
                  <mi mathvariant="normal">m</mi>
                  <mrow>
                    <mo>&#x2212;</mo>
                    <mn>2</mn>
                  </mrow>
                </msup>
                <mo>)</mo>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd96">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L-2">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq190" quantityType="base" dimensionURL="#NISTd96">
          <QuantityName xml:lang="en-US" xmlns="https://schema.unitsml.org/unitsml/1.0">fluence</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #35 example" do
    let(:exp) { "unitsml((dim_Theta^10)*dim_L^2)" }
    let(:expected_value) do
      <<~XML
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L2Theta10">
          <Length symbol="L" powerNumerator="2"/>
          <ThermodynamicTemperature symbol="Theta" powerNumerator="10"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #36 example" do
    let(:exp) { "unitsml((m^((-2))))" }
    let(:expected_value) do
      <<~XML
        <Unit xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="U_NISTu1e-2/1" dimensionURL="#D_L-2">
          <UnitSystem name="SI" type="SI_base" xml:lang="en-US"/>
          <UnitName xml:lang="en">meter to the power minus two</UnitName>
          <UnitSymbol type="HTML">m<sup>&#x2212;2</sup></UnitSymbol>
          <UnitSymbol type="MathMl">
            <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
              <msup>
                <mi mathvariant="normal">m</mi>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>2</mn>
                </mrow>
              </msup>
            </math>
          </UnitSymbol>
        </Unit>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTd96">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_L-2">
          <Length symbol="L" powerNumerator="-2"/>
        </Dimension>

        <Quantity xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="NISTq190" quantityType="base" dimensionURL="#NISTd96">
          <QuantityName xml:lang="en-US" xmlns="https://schema.unitsml.org/unitsml/1.0">fluence</QuantityName>
        </Quantity>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml(explicit_parenthesis: false)).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #37 example" do
    let(:exp) { "unitsml(sqrt((dim_Theta)))" }
    let(:expected_value) do
      <<~XML
        <Dimension xmlns="https://schema.unitsml.org/unitsml/1.0" xml:id="D_Theta0.5">
          <ThermodynamicTemperature symbol="Theta" powerNumerator="0.5" xmlns="https://schema.unitsml.org/unitsml/1.0"/>
        </Dimension>
      XML
    end

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula.to_xml(explicit_parenthesis: false)).to be_equivalent_to(expected_value)
    end
  end
end
