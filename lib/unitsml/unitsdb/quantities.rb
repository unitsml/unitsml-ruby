# frozen_string_literal: true

module Unitsml
  module Unitsdb
    class Quantities
      attr_accessor :quantities

      def initialize(register = nil)
        @register = register
      end

      def find_by_id(q_id)
        quantities.find { |quantity| quantity.id == q_id }
      end
    end
  end
end
