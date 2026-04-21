# frozen_string_literal: true

module Unitsml
  module MathmlHelper
    module_function

    def mml_v4_context
      ::Mml::V4::Configuration.context
    end

    def mml_v4_from_xml(klass_ref, xml)
      mml_v4_class_for(klass_ref).from_xml(xml, register: mml_v4_context.id)
    end

    def mml_v4_new(klass_ref, **attributes)
      klass = mml_v4_class_for(klass_ref)
      coerce_mml_v4_collection_attributes!(klass, attributes)
      klass.new(**attributes, lutaml_register: mml_v4_context.id)
    end

    def mml_v4_with_content(instance, content)
      attributes = instance.to_hash.transform_keys(&:to_sym)
      mml_v4_new(
        instance.class,
        **attributes,
        mml_v4_content_attribute(instance) => content
      )
    end

    def mml_v4_class_for(klass_ref)
      return klass_ref if klass_ref.is_a?(Class)

      mml_v4_context.lookup_local(klass_ref.to_sym)
    end

    private

    def coerce_mml_v4_collection_attributes!(klass, attributes)
      return unless klass.respond_to?(:attributes)

      attributes.each do |name, value|
        attribute = klass.attributes[name]
        attributes[name] = coerce_mml_v4_collection_value(attribute, value)
      end
    end

    def coerce_mml_v4_collection_value(attribute, value)
      return value unless attribute&.collection?
      return value if value.nil?
      return value if attribute.collection_instance?(value)

      attribute.build_collection(value)
    end

    def mml_v4_content_attribute(instance)
      register = instance.lutaml_register || mml_v4_context.id
      instance.class.mappings_for(:xml, register).content_mapping.to
    end
  end
end
