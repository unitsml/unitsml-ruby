# frozen_string_literal: true

module Unitsml
  module Errors
    class PlurimathLoadError < Unitsml::Error
      def to_s
        <<~MESSAGE
          [unitsml] Error: Failed to require 'plurimath'.
          [unitsml] Please add 'plurimath' in your gemfile and run 'bundle install'
          [unitsml] OR
          [unitsml] run following command to install the gem:
          [unitsml] gem install plurimath
          [unitsml] If this is a bug, please report at our official issue tracker:
          [unitsml] https://github.com/unitsml/unitsml-ruby/issues
        MESSAGE
      end
    end
  end
end
