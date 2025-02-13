require_relative 'lib/unitsml/version'

Gem::Specification.new do |spec|
  spec.name          = "unitsml"
  spec.version       = Unitsml::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Gem-wrapper for working with unitsdb"
  spec.description   = "Gem-wrapper for working with unitsdb"

  spec.homepage      = "https://github.com/unitsml/unitsml-ruby"
  spec.license       = "BSD-2-Clause"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.files += Dir.glob('unitsdb/**/*')

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "unitsdb/**/*.yaml"]

  spec.add_dependency "htmlentities"
  spec.add_dependency "ox"
  spec.add_dependency "parslet"
end
