# frozen_string_literal: true

require "unitsdb"

module Unitsml
  module Configuration
    CONTEXT_ID = :unitsml_ruby

    module_function

    def context_id
      CONTEXT_ID
    end

    def context(force_populate: false)
      existing = ::Unitsdb::Config.find_context(context_id)
      return existing if existing && !force_populate

      build_context
    end

    def register_model(klass, id:)
      registered_models[id.to_sym] = klass
    end

    def registered_models
      @registered_models ||= {}
    end

    def build_context
      ::Unitsdb::Config.context # ensure unitsdb context exists

      substitutions = registered_models.each_value.filter_map do |klass|
        parent = klass.superclass
        next if parent == Object

        { from_type: parent, to_type: klass }
      end

      ::Unitsdb::Config.populate_context(
        id: context_id,
        fallback_to: [::Unitsdb::Config.context_id],
        substitutions: substitutions,
      )
    end
  end
end
