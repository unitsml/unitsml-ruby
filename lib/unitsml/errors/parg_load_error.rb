# frozen_string_literal: true

module Unitsml
  module Errors
    class PargLoadError < BaseError
      def initialize(path, reason)
        super("[unitsml] Error: cannot load the asciiunits PARG artifact " \
              "at #{path}: #{reason}")
      end
    end
  end
end
