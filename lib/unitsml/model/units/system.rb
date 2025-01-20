# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class System < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :type, :string
        attribute :lang, :string, default: -> { "en-US" }

        xml do
          root "UnitSystem"

          map_attribute :name, to: :name
          map_attribute :type, to: :type
          map_attribute :lang, to: :lang, namespace: nil, prefix: "xml", render_default: true
        end
      end
    end
  end
end
