require "spec_helper"

RSpec.describe Unitsml::Parse do

  subject(:formula) { described_class.new.parse(exp.match(/unitsml\((.*)\)/)[1]) }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("m")
      expect(formula[:units]).to eq("m*s^-2")
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("u")
      expect(formula[:units]).to eq("m")
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("degK")
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("prime")
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("rad")
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("Hz")
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("kg")
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("m")
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:sqrt][:units]).to eq("Hz")
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(kg)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("kg")
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(g)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("g")
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(hp)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("hp")
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:units]).to eq("kg")
      expect(formula[:extender]).to eq("*")
      expect(sequence[:units]).to eq("s")
      expect(sequence[:integer]).to eq("-2")
    end
  end

  context "contains Unitsml #14 example" do
    let(:exp) { "unitsml(degK)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("degK")
    end
  end

  context "contains Unitsml #15 example" do
    let(:exp) { "unitsml(mbar)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:units]).to eq("mbar")
    end
  end

  context "contains Unitsml #16 example" do
    let(:exp) { "unitsml(p-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("p")
    end
  end

  context "contains Unitsml #17 example" do
    let(:exp) { "unitsml(h-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("h")
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(da-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("da")
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(u-)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("u")
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(um)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("u")
      expect(formula[:units]).to eq("m")
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(A*C^3)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:units]).to eq("A")
      expect(formula[:extender]).to eq("*")
      expect(sequence[:units]).to eq("C")
      expect(sequence[:integer]).to eq("3")
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(A/C^-3)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:units]).to eq("A")
      expect(formula[:extender]).to eq("/")
      expect(sequence[:units]).to eq("C")
      expect(sequence[:integer]).to eq("-3")
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(J/kg*K)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:units]).to eq("J")
      expect(formula[:extender]).to eq("/")
      expect(sequence[:units]).to eq("kg")
      expect(sequence[:extender]).to eq("*")
      expect(sequence[:sequence][:units]).to eq("K")
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(kg^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula[:prefixes]).to eq("k")
      expect(formula[:units]).to eq("g")
      expect(formula[:integer]).to eq("-2")
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(que?)" }

    it "returns parslet tree of parsed Unitsml string" do
      expect{formula}.to raise_error(Parslet::ParseFailed)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(kg*s^-2)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:units]).to eq("kg")
      expect(formula[:extender]).to eq("*")
      expect(sequence[:units]).to eq("s")
      expect(sequence[:integer]).to eq("-2")
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:prefixes]).to eq("m")
      expect(formula[:units]).to eq("W")
      expect(formula[:extender]).to eq("*")
      expect(sequence[:prefixes]).to eq("c")
      expect(sequence[:units]).to eq("m")
      expect(sequence[:integer]).to eq("-2")
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }

    it "returns parslet tree of parsed Unitsml string" do
      sequence = formula[:sequence]

      expect(formula[:dimensions]).to eq("dim_Theta")
      expect(formula[:extender]).to eq("*")
      expect(sequence[:dimensions]).to eq("dim_L")
      expect(sequence[:integer]).to eq("2")
    end
  end
end
