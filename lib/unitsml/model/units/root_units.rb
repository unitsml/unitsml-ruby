# frozen_string_literal: true

module Unitsml
  module Model
    module Units
      class RootUnits < Lutaml::Model::Serializable
        attribute :enumerated_root_unit, EnumeratedRootUnit, collection: true

        xml do
          element 'RootUnits'
          namespace ::Unitsml::Namespace

          map_element :EnumeratedRootUnit, to: :enumerated_root_unit
        end
      end
    end
  end
end
