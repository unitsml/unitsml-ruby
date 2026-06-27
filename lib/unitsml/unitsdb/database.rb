# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Database < ::Unitsdb::Database
      def self.from_db(dir_path, context: Unitsml::Configuration.context.id)
        return super unless RUBY_ENGINE == "opal"

        context_id = context.to_sym
        raise Unitsml::Errors::OpalPayloadNotBundledError unless opal_payload

        Unitsml::Configuration.context

        from_hash(opal_payload, register: context_id)
      end

      def self.load_opal_payload(payload)
        @opal_payload = payload
      end

      def self.reset_opal_payload
        return unless instance_variable_defined?(:@opal_payload)

        remove_instance_variable(:@opal_payload)
      end

      def self.opal_payload
        return @opal_payload if instance_variable_defined?(:@opal_payload)
        return unless const_defined?(:DATABASE, false)

        @opal_payload = const_get(:DATABASE, false)
      end
      private_class_method :opal_payload

      Configuration.register_model(self, id: :database)
    end
  end
end
