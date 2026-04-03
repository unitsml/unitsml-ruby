# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class Name < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :lang, :xml_lang, default: -> { "en" }

        xml do
          element "UnitName"
          namespace ::Unitsml::Namespace

          map_content to: :name
          map_attribute :lang, to: :lang, render_default: true
        end
      end
    end
  end
end
