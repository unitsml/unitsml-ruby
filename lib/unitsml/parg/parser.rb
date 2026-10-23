# frozen_string_literal: true

module Unitsml
  module Parg
    # Parses AsciiUnits expressions through the asciiunits PARG artifact
    # (github.com/unitsml/asciiunits) instead of the Parslet grammar,
    # producing the same Formula object model.
    class Parser < ::Unitsml::Parser
      REPO_ROOT = File.expand_path("../../..", __dir__)
      ARTIFACT_PATH = File.join(REPO_ROOT,
                                "vendor/asciiunits/artifacts/unitsml.json")
      TABLES_DIR = File.join(REPO_ROOT, "vendor/asciiunits/tables")

      class << self
        def artifact
          @artifact ||= load_artifact
        end

        private

        def load_artifact
          if RUBY_ENGINE == "opal"
            raise opal_unavailable_error
          end
          unless File.file?(ARTIFACT_PATH)
            raise Errors::PargLoadError.new(
              ARTIFACT_PATH,
              "expected the unitsml/asciiunits checkout with " \
              "artifacts/unitsml.json (git submodule)",
            )
          end

          # Opal's builder statically scans literal requires; parsanol has no
          # Opal build, so keep the require dynamic (this line never runs
          # under Opal — the RUBY_ENGINE guard above raises first).
          runtime = "parsanol"
          require runtime
          Parsanol::PARG::Artifact.load(ARTIFACT_PATH, tables_dir: TABLES_DIR)
        end

        def opal_unavailable_error
          Errors::PargLoadError.new(
            ARTIFACT_PATH,
            "the parsanol runtime is not available under Opal; " \
            "use Unitsml::Configuration.parser = :parslet",
          )
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
