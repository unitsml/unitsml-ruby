# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      # Descriptive note attached to a conversion definition (NoteType).
      class ConversionNote < Lutaml::Model::Serializable
        attribute :content, :string

        xml do
          element "ConversionNote"
          namespace ::Unitsml::Namespace

          map_content to: :content
        end
      end
    end
  end
end
