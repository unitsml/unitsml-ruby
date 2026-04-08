# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Database < ::Unitsdb::Database
      DATABASE = nil

      def self.from_db(dir_path, context: Unitsml::Configuration.context.id)
        return super unless RUBY_ENGINE == "opal"

        context_id = context.to_sym
        raise Unitsml::Errors::OpalPayloadNotBundledError unless DATABASE
        Unitsml::Configuration.context

        from_hash(DATABASE, register: context_id)
      end

      Configuration.register_model(self, id: :database)
    end
  end
end
