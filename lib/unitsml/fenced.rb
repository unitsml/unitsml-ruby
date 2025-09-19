module Unitsml
  class Fenced
    include FencedNumeric

    attr_reader :open_paren, :value, :close_paren

    def initialize(open_paren, value, close_paren)
      @open_paren = open_paren
      @value = value
      @close_paren = close_paren
    end

    def ==(object)
      self.class == object.class &&
        open_paren == object&.open_paren &&
        value == object&.value &&
        close_paren == object&.close_paren
    end

    def to_asciimath(options = {})
      fenced_conversion_for(lang: :asciimath, options: options)
    end

    def to_latex(options = {})
      fenced_conversion_for(lang: :latex, options: options)
    end

    def to_mathml(options = {})
      mathml = value.to_mathml(options)
      return mathml unless options[:explicit_parenthesis]

      fenced = ::Mml::Mrow.new(mo_value: [::Mml::Mo.new(value: open_paren)])
      fenced.ordered = true
      fenced.element_order ||= [xml_order_element("mo")]
      [mathml].flatten.each { |record| add_math_element(fenced, record) }
      fenced.mo_value << ::Mml::Mo.new(value: close_paren)
      fenced.element_order << xml_order_element("mo")
      { method_name: :mrow, value: fenced }
    end

    def negative?
      value.negative?
    end

    def update_negative_sign
      value.update_negative_sign
    end

    def float_to_display
      value.float_to_display
    end

    def to_html(options = {})
      fenced_conversion_for(lang: :html, options: options)
    end

    def to_unicode(options = {})
      fenced_conversion_for(lang: :unicode, options: options)
    end

    def dimensions_extraction
      case value
      when Dimension
        value
      when Formula, Fenced
        value.dimensions_extraction
      end
    end

    private

    def add_math_element(instance, child_hash)
      method_name = child_hash[:method_name]
      method_value = instance.public_send(:"#{method_name}_value") || []
      method_value += Array(child_hash[:value])
      instance.public_send(:"#{method_name}_value=", method_value)
      instance.element_order << xml_order_element(method_name.to_s)
    end

    def xml_order_element(tag_name)
      Lutaml::Model::Xml::Element.new("Element", tag_name)
    end

    def fenced_conversion_for(lang:, options:)
      lang_value = value.send(:"to_#{lang}", options)
      return lang_value unless options[:explicit_parenthesis]

      "#{open_paren}#{lang_value}#{close_paren}"
    end
  end
end
