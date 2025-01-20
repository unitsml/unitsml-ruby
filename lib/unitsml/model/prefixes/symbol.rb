# frozen_string_literal: true

module Unitsml
  module Model
    class Prefixes
      class Symbol < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "PrefixSymbol"

          map_attribute :type, to: :type
          map_content to: :content
        end
      end
    end
  end
end
