# frozen_string_literal: true

require "unitsml/model/units/enumerated_root_unit"

module Unitsml
  module Model
    module Units
      class RootUnits < Lutaml::Model::Serializable
        attribute :enumerated_root_unit, EnumeratedRootUnit, collection: true

        xml do
          map_element :EnumeratedRootUnit, to: :enumerated_root_unit
        end
      end
    end
  end
end
