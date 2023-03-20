require "spec_helper"

RSpec.describe Unitsml::Parser do

  subject(:formula) { described_class.new(exp).parse.to_latex }

  context "contains Unitsml #1 example" do
    let(:exp) { "unitsml(mm*s^-2)" }
    let(:expected_value) { "m\\ensuremath{\\mathrm{m}}/\\ensuremath{\\mathrm{s}}^-2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #2 example" do
    let(:exp) { "unitsml(um)" }
    let(:expected_value) { "$mu$\\ensuremath{\\mathrm{m}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #3 example" do
    let(:exp) { "unitsml(degK)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{^{\\circ}K}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #4 example" do
    let(:exp) { "unitsml(prime)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{'}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #5 example" do
    let(:exp) { "unitsml(rad)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{rad}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #6 example" do
    let(:exp) { "unitsml(Hz)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{Hz}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #7 example" do
    let(:exp) { "unitsml(kg)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{g}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #8 example" do
    let(:exp) { "unitsml(m)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{m}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #9 example" do
    let(:exp) { "unitsml(sqrt(Hz))" }
    let(:expected_value) { "\\ensuremath{\\mathrm{Hz}}^0.5" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #10 example" do
    let(:exp) { "unitsml(g)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{g}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #11 example" do
    let(:exp) { "unitsml(hp)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{hp}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #12 example" do
    let(:exp) { "unitsml(kg*s^-2)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{g}}/\\ensuremath{\\mathrm{s}}^-2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #13 example" do
    let(:exp) { "unitsml(mbar)" }
    let(:expected_value) { "m\\ensuremath{\\mathrm{bar}}" }

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
    let(:expected_value) { "$mu$" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #18 example" do
    let(:exp) { "unitsml(A*C^3)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{A}}/\\ensuremath{\\mathrm{C}}^3" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #19 example" do
    let(:exp) { "unitsml(A/C^-3)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{A}}/\\ensuremath{\\mathrm{C}}^3" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #20 example" do
    let(:exp) { "unitsml(J/kg*K)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{J}}/k\\ensuremath{\\mathrm{g}}^-1/\\ensuremath{\\mathrm{K}}^-1" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #21 example" do
    let(:exp) { "unitsml(kg^-2)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{g}}^-2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #22 example" do
    let(:exp) { "unitsml(kg*s^-2)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{g}}/\\ensuremath{\\mathrm{s}}^-2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #23 example" do
    let(:exp) { "unitsml(mW*cm^(-2))" }
    let(:expected_value) { "m\\ensuremath{\\mathrm{W}}/c\\ensuremath{\\mathrm{m}}^-2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #24 example" do
    let(:exp) { "unitsml(dim_Theta*dim_L^2)" }
    let(:expected_value) { "\\ensuremath{\\mathsf{\\Theta}}/\\ensuremath{\\mathsf{L}}^2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #25 example" do
    let(:exp) { "unitsml(dim_Theta^10*dim_L^2)" }
    let(:expected_value) { "\\ensuremath{\\mathsf{\\Theta}}^10/\\ensuremath{\\mathsf{L}}^2" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #26 example" do
    let(:exp) { "unitsml(Hz^10*darcy^100)" }
    let(:expected_value) { "\\ensuremath{\\mathrm{Hz}}^10/\\ensuremath{\\mathrm{d}}^100" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #27 example" do
    let(:exp) { "unitsml(kcal_IT)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{cal_{IT}}}" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end

  context "contains Unitsml #28 example" do
    let(:exp) { "unitsml(kcal_IT^100)" }
    let(:expected_value) { "k\\ensuremath{\\mathrm{cal_{IT}}}^100" }

    it "returns parslet tree of parsed Unitsml string" do
      expect(formula).to be_equivalent_to(expected_value)
    end
  end
end
