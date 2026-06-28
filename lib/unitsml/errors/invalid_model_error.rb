# frozen_string_literal: true

module Unitsml
  module Errors
    class InvalidModelError < Unitsml::Errors::BaseError
      def initialize(klass)
        class_name = display_name(klass)
        parent = klass.is_a?(Class) ? klass.superclass : nil
        super("[unitsml] Error: #{class_name} cannot be registered as a " \
              "UnitsML model. register_model expects a subclass of " \
              "::Unitsdb::*, got superclass #{parent}.")
      end

      private

      def display_name(klass)
        return klass.inspect unless klass.is_a?(Class)
        return klass.name unless klass.name.nil?

        klass.inspect
      end
    end
  end
end
