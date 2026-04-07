# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Database < ::Unitsdb::Database
      def self.from_db(dir_path, context: Unitsml::Configuration.context.id)
        if RUBY_ENGINE == "opal"
        else
          super
        end
      end

      Configuration.register_model(self, id: :database)
    end
  end
end
