RSpec.describe Unitsml::Parser do

  subject(:formula) do
    described_class.new(exp).parse.to_plurimath(
      respond_to?(:options) ? options : {}
    )
  end

  context "when plurimath is not required/installed" do
    let(:exp) { "unitsml(mm*s^-2)" }

    before do
      allow_any_instance_of(Unitsml::Formula).to receive(:require).with("plurimath").and_raise(LoadError)
    end

    it "raises an error when trying to use Plurimath" do
      expect { formula }.to raise_error(Unitsml::Errors::PlurimathLoadError, /\[unitsml\] Error: Failed to require 'plurimath'./)
    end
  end

  context "Unitsml example contains prefix and units" do
    let(:exp) { "unitsml(mm*s^-2)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("mm"),
          "normal"
        ),
        Plurimath::Math::Symbols::Cdot.new,
        Plurimath::Math::Function::Power.new(
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("s"),
            "normal"
          ),
          Plurimath::Math::Formula.new([
            Plurimath::Math::Symbols::Minus.new,
            Plurimath::Math::Number.new("2")
          ])
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains dimension only" do
    let(:exp) { "unitsml(dim_L)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::SansSerif.new(
          Plurimath::Math::Symbols::Symbol.new("L"),
          "sans-serif",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains prefix only" do
    let(:exp) { "unitsml(k-)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Symbols::Symbol.new("k"),
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains unit only" do
    let(:exp) { "unitsml(g)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("g"),
          "normal",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains 'um' crashing while LutaML-Model integration in Plurimath" do
    let(:exp) { "unitsml(um)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("&#xb5;m"),
          "normal",
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example crashing in plurimath/plurimath#343" do
    let(:exp) { "unitsml(kg^(-1)*m^(-3)*s^4*A^2)" }
    let(:expected_value) do
      Plurimath::Math::Formula.new(
        [
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("kg"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ])
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("m"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("3"),
            ])
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("s"),
              "normal",
            ),
            Plurimath::Math::Number.new("4"),
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("A"),
              "normal",
            ),
            Plurimath::Math::Number.new("2"),
          ),
        ],
      )
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains unit only wrapped in parentheses with default explicit_parenthesis: true" do
    let(:exp) { "unitsml(((((g)))))" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::Fenced.new(
          Plurimath::Math::Symbols::Paren::Lround.new,
          [
            Plurimath::Math::Function::Fenced.new(
              Plurimath::Math::Symbols::Paren::Lround.new,
              [
                Plurimath::Math::Function::FontStyle::Normal.new(
                  Plurimath::Math::Symbols::Symbol.new("g"),
                  "normal",
                ),
              ],
              Plurimath::Math::Symbols::Paren::Rround.new,
            ),
          ],
          Plurimath::Math::Symbols::Paren::Rround.new,
        )
      ])
    end

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  context "Unitsml example contains unit only wrapped in parentheses with explicit_parenthesis: false" do
    let(:exp) { "unitsml(((g)))" }
    let(:expected_value) do
      Plurimath::Math::Formula.new([
        Plurimath::Math::Function::FontStyle::Normal.new(
          Plurimath::Math::Symbols::Symbol.new("g"),
          "normal",
        )
      ])
    end
    let(:options) { { explicit_parenthesis: false } }

    it "compares expected value with to_plurimath method output" do
      expect(formula).to eq(expected_value)
    end
  end

  describe "implicit extender" do
    context "implicit extender example #1 from issue#53" do
      let(:exp) { "unitsml(J(kg*K))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("kg"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
                )
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          )
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #2 from issue#53" do
      let(:exp) { "unitsml(J kg^-1 * K^-1)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("kg"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ])
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("K"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ]),
          )
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #3 from issue#53" do
      let(:exp) { "unitsml(J/mol * K)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("mol"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ]),
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("K"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ]),
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #4 from issue#53" do
      let(:exp) { "unitsml(J/(mol * K))" }
      let(:expected_value) do

        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("mol"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ]),
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::Power.new(
            Plurimath::Math::Function::FontStyle::Normal.new(
              Plurimath::Math::Symbols::Symbol.new("K"),
              "normal",
            ),
            Plurimath::Math::Formula.new([
              Plurimath::Math::Symbols::Minus.new,
              Plurimath::Math::Number.new("1"),
            ]),
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #5" do
      let(:exp) { "unitsml((mol * K)J)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("mol"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #6" do
      let(:exp) { "unitsml((mol * K) J)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("mol"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("J"),
            "normal",
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #7" do
      let(:exp) { "unitsml((mol * K)(J))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("mol"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("J"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #8" do
      let(:exp) { "unitsml((mol * K)(J*K))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("mol"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("J"),
                "normal",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("K"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #9" do
      let(:exp) { "unitsml(E_erlang(mm)*kg)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("E"),
            "normal",
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::Normal.new(
                Plurimath::Math::Symbols::Symbol.new("mm"),
                "normal",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::FontStyle::Normal.new(
            Plurimath::Math::Symbols::Symbol.new("kg"),
            "normal",
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #10" do
      let(:exp) { "unitsml(dim_Theta(dim_phi))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::UpcaseTheta.new,
            "sans-serif",
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Phi.new,
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #11" do
      let(:exp) { "unitsml((dim_Theta)dim_L)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::UpcaseTheta.new,
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::Symbol.new("L"),
            "sans-serif",
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #12" do
      let(:exp) { "unitsml(dim_Theta dim_L)" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::UpcaseTheta.new,
            "sans-serif",
          ),
          Plurimath::Math::Symbols::Cdot.new,
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::Symbol.new("L"),
            "sans-serif",
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #13" do
      let(:exp) { "unitsml(dim_phi (dim_Theta dim_L))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::Phi.new,
            "sans-serif",
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::UpcaseTheta.new,
                "sans-serif",
              ),
              Plurimath::Math::Symbols::Cdot.new,
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Symbol.new("L"),
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #14" do
      let(:exp) { "unitsml((dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Phi.new,
                "sans-serif",
              ),
              Plurimath::Math::Function::Fenced.new(
                Plurimath::Math::Symbols::Paren::Lround.new,
                [
                  Plurimath::Math::Function::FontStyle::SansSerif.new(
                    Plurimath::Math::Symbols::Symbol.new("I"),
                    "sans-serif",
                  ),
                ],
                Plurimath::Math::Symbols::Paren::Rround.new,
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::Fenced.new(
                Plurimath::Math::Symbols::Paren::Lround.new,
                [
                  Plurimath::Math::Function::FontStyle::SansSerif.new(
                    Plurimath::Math::Symbols::UpcaseTheta.new,
                    "sans-serif",
                  ),
                ],
                Plurimath::Math::Symbols::Paren::Rround.new,
              ),
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Symbol.new("L"),
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end

    context "implicit extender example #15" do
      let(:exp) { "unitsml(sqrt(dim_phi(dim_I)) ((dim_Theta) dim_L))" }
      let(:expected_value) do
        Plurimath::Math::Formula.new([
          Plurimath::Math::Function::FontStyle::SansSerif.new(
            Plurimath::Math::Symbols::Phi.new,
            "sans-serif",
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Symbol.new("I"),
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
          Plurimath::Math::Function::Fenced.new(
            Plurimath::Math::Symbols::Paren::Lround.new,
            [
              Plurimath::Math::Function::Fenced.new(
                Plurimath::Math::Symbols::Paren::Lround.new,
                [
                  Plurimath::Math::Function::FontStyle::SansSerif.new(
                    Plurimath::Math::Symbols::UpcaseTheta.new,
                    "sans-serif",
                  ),
                ],
                Plurimath::Math::Symbols::Paren::Rround.new,
              ),
              Plurimath::Math::Function::FontStyle::SansSerif.new(
                Plurimath::Math::Symbols::Symbol.new("L"),
                "sans-serif",
              ),
            ],
            Plurimath::Math::Symbols::Paren::Rround.new,
          ),
        ])
      end

      it "matches the UnitsML to UnicodeMath converted value" do
        expect(formula).to eq(expected_value)
      end
    end
  end
end
