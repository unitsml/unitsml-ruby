# frozen_string_literal: true

module Unitsml
  module Parg
    # Parses AsciiUnits expressions through the asciiunits PARG artifact
    # (the asciiunits gem, built from github.com/unitsml/asciiunits) instead
    # of the Parslet grammar, producing the same Formula object model.
    class Parser < ::Unitsml::Parser
      class << self
        def artifact
          @artifact ||= load_artifact
        end

        private

        def load_artifact
          if RUBY_ENGINE == "opal"
            raise Errors::PargLoadError.new(
              "the asciiunits gem",
              "the parsanol runtime is not available under Opal; " \
              "use Unitsml::Configuration.parser = :parslet",
            )
          end

          # Opal's builder statically scans literal requires; neither
          # asciiunits nor parsanol has an Opal build, so keep both requires
          # dynamic (this line never runs under Opal — the RUBY_ENGINE
          # guard above raises first).
          data_gem = "asciiunits"
          require data_gem
          Asciiunits.load_artifact
        rescue LoadError => e
          raise Errors::PargLoadError.new("the asciiunits gem", e.message)
        end
      end

      def parse
        tree = self.class.artifact.parse("expression", text)
        formula = build_formula(TreeMapper.new.apply(tree))
        update_units_exponents(formula.value, false)
        formula.value.first.only_instance = true if text.end_with?("-")
        formula
      end

      private

      def build_formula(mapped)
        formula_value = mapped.is_a?(Formula) ? mapped.value : [mapped].flatten
        Formula.new(
          formula_value,
          explicit_value: @extras_hash,
          root: true,
          orig_text: @orig_text,
          norm_text: text,
        )
      end
    end
  end
end
