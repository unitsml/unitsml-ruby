# frozen_string_literal: true

module Unitsml
  # Parses AsciiUnits expressions through the asciiunits PARG artifact
  # (github.com/unitsml/asciiunits) into the Formula object model.
  class Parser
    attr_accessor :text

    def initialize(text)
      @regexp = /(quantity|name|symbol|multiplier):\s*/
      @text = extract_equation(text)
      @orig_text = @text
      @text = @text.gsub("−", "-")
      post_extras
    end

    def parse
      tree = parse_tree
      mapped = Parg::TreeMapper.new.apply(tree)
      formula = build_formula(mapped)
      update_units_exponents(formula.value, false)
      formula.value.first.only_instance = true if text.end_with?("-")
      formula
    end

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
            "use a runtime with native code access",
          )
        end

        # Opal's builder statically scans literal requires; neither
        # asciiunits nor parsanol has an Opal build, so keep the requires
        # dynamic (this line never runs under Opal — the RUBY_ENGINE guard
        # above raises first).
        data_gem = "asciiunits"
        require data_gem
        Asciiunits.load_artifact
      rescue LoadError => e
        raise Errors::PargLoadError.new("the asciiunits gem", e.message)
      end
    end

    # The artifact is loaded first, so Parsanol is defined by the time the
    # rescue clause names it.
    def parse_tree
      artifact = self.class.artifact
      begin
        artifact.parse("expression", text)
      rescue ::Parsanol::ParseFailed
        raise Errors::ParseError.new(text)
      end
    end

    def update_units_exponents(array, inverse, sqrt = false)
      array.each do |object|
        if object.is_a?(Sqrt)
          object = object.value
          if object.is_a?(Unit)
            object.power_numerator = Number.new("0.5")
          else
            update_units_exponents([object], inverse, true)
          end
        end

        case object
        when Unit
          next object.power_numerator = Number.new("0.5") if sqrt
          next unless inverse

          inverse ? object.inverse_power_numerator : object.power_numerator
        when Dimension then object.power_numerator = Number.new("0.5") if sqrt
        when Extender then inverse = !inverse if ["/", "//"].any?(object.symbol)
        when Formula then update_units_exponents(object.value, inverse)
        when Fenced then update_units_exponents([object.value], inverse, sqrt)
        end
      end
    end

    def post_extras
      return nil unless @regexp.match?(text)

      @extras_hash = {}
      texts_array = text&.split(",")&.map(&:strip)
      @text = texts_array&.shift
      texts_array&.map { |text| parse_extras(text) }
    end

    def parse_extras(text)
      return nil unless @regexp.match?(text)

      key, _, value = text&.partition(":")
      @extras_hash[key&.to_sym] ||= value&.strip
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

    def extract_equation(text)
      return text unless text&.start_with?("unitsml(")

      text.delete_prefix("unitsml(").delete_suffix(")")
    end
  end
end
