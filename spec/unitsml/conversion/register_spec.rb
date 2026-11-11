# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::Conversion::Register do
  let(:mass) { { "Mass" => "1" } }
  let(:degc) do
    { "unit" => "degC", "factor" => "1", "offset" => "273.15",
      "dimensions" => { "ThermodynamicTemperature" => "1" } }
  end
  let(:entry) do
    { "unit" => "NISTu230", "factor" => "50", "dimensions" => mass }
  end

  def quantity(value, unit)
    Unitsml::Quantity.new(value: value, unit: unit)
  end

  def with_register(entries, &block)
    Unitsml::Conversion.with_register(entries, &block)
  end

  it "converts with a caller factor exactly" do
    with_register([entry]) do
      expect(quantity(2, "cwt (US)").convert_to("kg").value).to eq(100)
    end
  end

  it "keeps rational factors exact" do
    with_register([entry.merge("factor" => "1/3")]) do
      value = quantity(2, "cwt (US)").convert_to("kg").value
      expect(value).to eq(Rational(2, 3))
    end
  end

  it "aligns operands of + and - through the register" do
    with_register([entry]) do
      expect((quantity(2, "cwt (US)") + quantity(50, "kg")).value).to eq(3)
      expect((quantity(2, "cwt (US)") - quantity(50, "kg")).value).to eq(1)
    end
  end

  it "gates a unit without a decomposition by its declared dimensions" do
    with_register([entry]) do
      expect { quantity(2, "cwt (US)") + quantity(3, "m") }
        .to raise_error(Unitsml::Errors::DimensionMismatchError)
    end
  end

  it "lets a later entry for the same unit replace an earlier one" do
    with_register([entry.merge("factor" => "25"), entry]) do
      expect(quantity(2, "cwt (US)").convert_to("kg").value).to eq(100)
    end
  end

  it "does not persist past the block" do
    with_register([entry]) { quantity(2, "cwt (US)").convert_to("kg") }
    expect(Unitsml::Conversion.current_register).to be_nil
  end

  it "applies affine entries to absolute values and not to differences" do
    with_register([degc]) do
      expect(quantity(20, "degC").convert_to("K").value)
        .to eq(Rational("293.15"))
      diff = quantity(20, "degC") - quantity(15, "degC")
      expect(diff.convert_to("K").value).to eq(5)
    end
  end

  it "accepts an entry within the canonical 1e-9 relative tolerance" do
    w = { "unit" => "W", "factor" => "1.00000000005",
          "dimensions" => { "Length" => "2", "Mass" => "1", "Time" => "-3" } }
    expect { with_register([w]) { nil } }.not_to raise_error
  end

  describe "validation" do
    let(:invalid) { Unitsml::Errors::InvalidUnitRegisterError }
    let(:power) { { "Length" => "2", "Mass" => "1", "Time" => "-3" } }

    it "refuses a non-Array register" do
      expect { with_register({}) { nil } }.to raise_error(invalid)
    end

    it "refuses unknown fields" do
      expect do
        with_register([entry.merge("extra" => 1)]) do
          nil
        end
      end.to raise_error(invalid, /extra/)
    end

    it "refuses a numeric factor" do
      expect do
        with_register([entry.merge("factor" => 50)]) do
          nil
        end
      end.to raise_error(invalid, /exact/)
    end

    it "refuses a non-exact factor" do
      expect do
        with_register([entry.merge("factor" => "NaN")]) do
          nil
        end
      end.to raise_error(invalid, /exact/)
    end

    it "refuses zero and negative factors" do
      expect do
        with_register([entry.merge("factor" => "0")]) do
          nil
        end
      end.to raise_error(invalid, /positive/)
      expect { with_register([entry.merge("factor" => "-1")]) { nil } }
        .to raise_error(invalid, /positive/)
    end

    it "refuses declared dimensions that differ from the unit's" do
      expect do
        with_register([entry.merge("dimensions" => { "Length" => "1" })]) do
          nil
        end
      end
        .to raise_error(invalid, /NISTd1.*NISTd2/)
    end

    it "refuses an unknown unit" do
      expect do
        with_register([entry.merge("unit" => "unregistered-unit")]) do
          nil
        end
      end
        .to raise_error(Unitsml::Errors::UnknownUnitError)
    end

    it "refuses disagreement with the register's canonical conversion" do
      w = { "unit" => "W", "factor" => "2", "dimensions" => power }
      expect { with_register([w]) { nil } }.to raise_error(invalid, /disagrees/)
    end
  end
end
