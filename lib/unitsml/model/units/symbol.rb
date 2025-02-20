# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class Symbol < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "UnitSymbol"

          map_attribute :type, to: :type
          map_content to: :content, with: { from: :content_from_xml, to: :content_to_xml }
        end

        # Not reading any XML for now.
        def content_from_xml(**); end

        def content_to_xml(model, parent, doc)
          doc.add_xml_fragment(parent, model.content)
        end
      end
    end
  end
end
