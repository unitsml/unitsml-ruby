# frozen_string_literal: true

require "spec_helper"

RSpec.describe "conversion definitions in quantity conversion" do # rubocop:disable RSpec/DescribeClass
  def float64_model(id:, initial:, initial_addend: nil, multiplicand: nil,
                    divisor: nil, final_addend: nil)
    Unitsml::Model::Units::Float64ConversionFrom.new(
      id: id, initial_unit: initial, initial_addend: initial_addend,
      multiplicand: multiplicand, divisor: divisor,
      final_addend: final_addend, exact: true
    )
  end

  def degc_from_k
    # y_degC = -273.15 + x_K
    float64_model(id: "degC_from_K", initial: "#NISTu5",
                  final_addend: "-273.15")
  end

  def k_from_degc(initial: "#NISTu23")
    # y_K = 273.15 + x_degC
    float64_model(id: "K_from_degC", initial: initial, final_addend: "273.15")
  end

  def degf_from_k
    # y_degF = 32 + (9 / 5)(x_K - 273.15)
    float64_model(id: "degF_from_K", initial: "#NISTu5",
                  initial_addend: "-273.15", multiplicand: "9",
                  divisor: "5", final_addend: "32")
  end

  def full_metadata_xml
    <<~XML
      <Unit xmlns="https://schemas.unitsml.org/unitsml/1.0" xml:id="U">
        <Conversions>
          <Float64ConversionFrom xml:id="full" initialUnit="#NISTu5"
            initialAddend="0.0" initialAddendDecimalPlace="1"
            multiplicand="9" multiplicandDigits="1"
            divisor="5" divisorDigits="1"
            finalAddend="32.0" finalAddendDecimalPlace="1" exact="false"/>
        </Conversions>
      </Unit>
    XML
  end

  it "converts through a caller-supplied definition whose fragment " \
     "initialUnit resolves through the register" do
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")

    expect(q.convert_to("K", definitions: { "K" => k_from_degc }).value)
      .to eq(Rational(29315, 100))
  end

  it "chains a definition with canonical data across both hops" do
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")

    # degC reduces canonically to K; degF is entered through its
    # definition — 20 degC = 68 degF.
    expect(q.convert_to("degF", definitions: { "degF" => degf_from_k }).value)
      .to eq(Rational(68))
  end

  it "matches the canonical path when both describe the same hop" do
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")
    canonical = q.convert_to("K").value
    defined = q.convert_to("K", definitions: { "K" => k_from_degc }).value

    expect(defined).to eq(canonical)
  end

  it "raises a diagnostic when a definition disagrees with canonical data" do
    q = Unitsml::Quantity.new(value: 20, unit_expression: "K")
    wrong = float64_model(id: "bad_degC", initial: "#NISTu5",
                          final_addend: "-273.16")

    expect { q.convert_to("degC", definitions: { "degC" => wrong }) }
      .to raise_error(Unitsml::Errors::ConversionError,
                      /disagrees with canonical data for "degC".*definition/)
  end

  it "refuses an affine definition at a power other than 1" do
    formula = Unitsml.parse("degF^2")

    expect do
      Unitsml::Conversion.to_canonical(formula,
                                       definitions: { "degF" => degf_from_k })
    end.to raise_error(Unitsml::Errors::ConversionError,
                       /affine unit raised to power/)
  end

  it "refuses a SpecialConversionFrom supplied as a definition" do
    special = Unitsml::Model::Units::SpecialConversionFrom.new(
      id: "sp", initial_unit: "#NISTu5",
    )
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")

    expect { q.convert_to("K", definitions: { "K" => special }) }
      .to raise_error(Unitsml::Errors::ConversionError,
                      /SpecialConversionFrom "sp" is not/)
  end

  it "resolves an initialUnit URI through the register references" do
    sdf = "http://si-digital-framework.org/SI/units/degreeCelsius"
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")
    definition = k_from_degc(initial: sdf)

    expect(q.convert_to("K", definitions: { "K" => definition }).value)
      .to eq(Rational(29315, 100))
  end

  it "keeps difference semantics when definitions are in play" do
    diff = Unitsml::Quantity.new(value: 20, unit_expression: "degC") -
      Unitsml::Quantity.new(value: 15, unit_expression: "degC")

    expect(diff.convert_to("K", definitions: { "K" => k_from_degc }).value)
      .to eq(Rational(5))
  end

  it "round-trips a value through definition-based conversion" do
    q = Unitsml::Quantity.new(value: 20, unit_expression: "degC")
    forward = q.convert_to("K", definitions: { "K" => k_from_degc })
    back = forward.convert_to("degC", definitions: { "degC" => degc_from_k })

    expect(back.value).to eq(Rational(20))
  end

  it "preserves the declared digit and decimal-place metadata" do
    model = Unitsml::Model::Unit.from_xml(full_metadata_xml)
      .conversions.float64_conversion_from

    expect([model.multiplicand_digits, model.divisor_digits,
            model.initial_addend_decimal_place,
            model.final_addend_decimal_place]).to all(eq(1))
    expect(model.exact).to be(false)
    expect(model.lexical_decimal(:final_addend)).to eq("32.0")
  end
end
