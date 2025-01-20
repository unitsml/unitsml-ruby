# frozen_string_literal: true

module Unitsml
  module Model
    class Prefixes
      class Name < Lutaml::Model::Serializable
        attribute :lang, :string, default: -> { "en" }
        attribute :content, :string

        xml do
          root "PrefixName"

          map_attribute :lang, to: :lang, namespace: nil, prefix: "xml", render_default: true
          map_content to: :content
        end
      end
    end
  end
end
