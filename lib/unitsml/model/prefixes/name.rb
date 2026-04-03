# frozen_string_literal: true

module Unitsml
  module Model
    module Prefixes
      class Name < Lutaml::Model::Serializable
        attribute :lang, :xml_lang, default: -> { "en" }
        attribute :content, :string

        xml do
          element "PrefixName"
          namespace ::Unitsml::Namespace

          map_attribute :lang, to: :lang, render_default: true
          map_content to: :content
        end
      end
    end
  end
end
