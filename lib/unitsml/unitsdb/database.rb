# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Database < ::Unitsdb::Database
      DATABASE = nil

      def self.load_opal_payload(database)
        @opal_payload = database
      end

      def self.from_db(dir_path, context: Unitsml::Configuration.context.id)
        return super unless RUBY_ENGINE == "opal"

        context_id = context.to_sym
        raise Unitsml::Errors::OpalPayloadNotBundledError unless opal_payload

        Unitsml::Configuration.context

        from_hash(opal_payload, register: context_id)
      end

      def self.opal_payload
        @opal_payload ||= const_get(:DATABASE, false) if const_defined?(:DATABASE, false)
      end

      Configuration.register_model(self, id: :database)
    end
  end
end
