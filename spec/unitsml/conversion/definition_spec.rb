# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Conversion::Definition do
  def parse_unit(xml)
    Unitsml::Model::Unit.from_xml(xml)
  end

  def float64_from(xml)
    parse_unit(xml).conversions.float64_conversion_from
  end

  def degc_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA185">
        <Conversions>
          <Float64ConversionFrom xml:id="UAA185_from_UAA033" initialUnit="#UAA033"
            multiplicand="1" divisor="1" finalAddend="273.15" exact="true"/>
        </Conversions>
      </Unit>
    XML
  end

  def degc_definition
    described_class.from_model(float64_from(degc_xml),
                               document_units: { "UAA033" => :kelvin })
  end

  def degf_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA185">
        <Conversions>
          <Float64ConversionFrom xml:id="degF_from_K" initialUnit="#UAA033"
            initialAddend="-273.15" multiplicand="9" divisor="5" finalAddend="32"
            exact="true"/>
        </Conversions>
      </Unit>
    XML
  end

  def percent_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA900">
        <Conversions>
          <Float64ConversionFrom xml:id="pct_from_one" initialUnit="#one"
            multiplicand="1" divisor="100" exact="true"/>
        </Conversions>
      </Unit>
    XML
  end

  def grad_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA901">
        <Conversions>
          <Float64ConversionFrom xml:id="ppd_from_deg" initialUnit="#deg"
            multiplicand="1" divisor="1" finalAddend="0.5729577951308232087679815481"/>
        </Conversions>
      </Unit>
    XML
  end

  def special_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA902">
        <Conversions>
          <SpecialConversionFrom xml:id="sp_from_x" initialUnit="#x"
            conversionURL="https://example.com/convert"/>
        </Conversions>
      </Unit>
    XML
  end

  def wsdl_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA903">
        <Conversions>
          <WSDLConversionFrom xml:id="wsdl_from_x" initialUnit="#x"
            wsdlURL="https://example.com/convert?wsdl"/>
        </Conversions>
      </Unit>
    XML
  end

  def dangling_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="UAA904">
        <Conversions>
          <Float64ConversionFrom xml:id="dangling" initialUnit="#nowhere"
            multiplicand="1" divisor="1"/>
        </Conversions>
      </Unit>
    XML
  end

  it "parses the degC definition with XSD defaults and lexical decimals" do
    defn = degc_definition

    expect(defn.model.initial_unit).to eq("#UAA033")
    expect(defn.model.lexical_decimal(:final_addend)).to eq("273.15")
    expect(defn.model.lexical_decimal(:initial_addend)).to eq("0")
    expect(defn.model.lexical_decimal(:multiplicand)).to eq("1")
    expect(defn.model.lexical_decimal(:divisor)).to eq("1")
    expect(defn).to be_exact
  end

  it "applies the degC definition forward exactly: 0 degC -> 273.15 K" do
    expect(degc_definition.forward(0)).to eq(Rational(27315, 100))
    expect(degc_definition.forward(100)).to eq(Rational(37315, 100))
  end

  it "applies the degC definition inverse exactly: 273.15 K -> 0 degC" do
    expect(degc_definition.inverse(Rational(27315, 100))).to eq(Rational(0))
    expect(degc_definition.inverse(Rational(37315, 100))).to eq(Rational(100))
  end

  it "applies the degF definition exactly through the 5/9 factor" do
    defn = described_class.from_model(float64_from(degf_xml))

    expect(defn.forward(Rational(27315, 100))).to eq(Rational(32))
    expect(defn.forward(Rational(37315, 100))).to eq(Rational(212))
    expect(defn.inverse(Rational(212))).to eq(Rational(37315, 100))
  end

  it "applies percent-to-one exactly (0.01)" do
    defn = described_class.from_model(float64_from(percent_xml))

    expect(defn.forward(1)).to eq(Rational(1, 100))
    expect(defn.inverse(Rational(1, 100))).to eq(Rational(1))
  end

  it "keeps a non-exact definition from claiming exactness" do
    defn = described_class.from_model(float64_from(grad_xml))

    expect(defn).not_to be_exact
    expect(defn.model.lexical_decimal(:final_addend))
      .to eq("0.5729577951308232087679815481")
  end

  it "refuses SpecialConversionFrom with a typed error" do
    model = parse_unit(special_xml).conversions.special_conversion_from

    expect { described_class.from_model(model) }
      .to raise_error(Unitsml::Errors::ConversionError,
                      /SpecialConversionFrom .*not executable/)
  end

  it "refuses WSDLConversionFrom with a typed error" do
    model = parse_unit(wsdl_xml).conversions.wsdl_conversion_from

    expect { described_class.from_model(model) }
      .to raise_error(Unitsml::Errors::ConversionError,
                      /WSDLConversionFrom .*not executable/)
  end

  it "resolves a document-local initialUnit through the document units" do
    expect(degc_definition.resolve_initial_unit).to eq(:kelvin)
  end

  it "raises naming the URI for an unresolvable initialUnit" do
    defn = described_class.from_model(float64_from(dangling_xml),
                                      document_units: {})

    expect { defn.resolve_initial_unit }
      .to raise_error(Unitsml::Errors::ConversionError,
                      /unresolvable initialUnit "#nowhere"/)
  end

  it "round-trips a value through the document-local definition" do
    defn = degc_definition
    converted = defn.forward(20)

    expect(defn.inverse(converted)).to eq(Rational(20))
  end
end
