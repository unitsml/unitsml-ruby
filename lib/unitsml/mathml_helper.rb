# frozen_string_literal: true

module Unitsml
  module MathmlHelper
    module_function

    def mml_v4_context_id
      ::Mml::V4::Configuration.context
      ::Mml::V4::Configuration.context_id
    end

    def mml_v4_from_xml(klass, xml)
      klass.from_xml(xml, register: mml_v4_context_id)
    end

    def mml_v4_new(klass, **attributes)
      klass.new(**attributes, lutaml_register: mml_v4_context_id)
    end
  end
end
