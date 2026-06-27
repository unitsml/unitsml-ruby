# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :unitsml do
  desc "Regenerate lib/unitsml/opal/database_payload.rb from unitsdb YAML"
  task :generate_opal_payload do
    require "unitsml/opal/payload_generator"
    path = Unitsml::Opal::PayloadGenerator::DEFAULT_OUTPUT_PATH
    Unitsml::Opal::PayloadGenerator.new.write_to(path)
    puts "Wrote #{path}"
  end
end

task default: :spec
