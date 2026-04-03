# frozen_string_literal: true

module Unitsml
  module Model
    module Prefixes
      class Symbol < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          element "PrefixSymbol"
          namespace ::Unitsml::Namespace

          map_attribute :type, to: :type
          map_content to: :content
        end
      end
    end
  end
end
