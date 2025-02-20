# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class Name < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :lang, :string, default: -> { "en" }

        xml do
          root "UnitName"

          map_content to: :name
          map_attribute :lang, to: :lang, namespace: nil, prefix: "xml", render_default: true
        end
      end
    end
  end
end
