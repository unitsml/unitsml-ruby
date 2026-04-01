# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class System < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :type, :string
        attribute :lang, :xml_lang, default: -> { 'en' }

        xml do
          element 'UnitSystem'
          namespace ::Unitsml::Namespace

          map_attribute :name, to: :name
          map_attribute :type, to: :type
          map_attribute :lang, to: :lang, render_default: true
        end
      end
    end
  end
end
