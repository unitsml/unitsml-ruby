# frozen_string_literal: true

require "spec_helper"
require "pathname"

# Verifies the Opal boot file (lib/unitsml/opal.rb) stays in sync with
# the autoload declarations across the gem. Under Opal, autoloads do not
# lazy-execute, so the boot file eager-requires every entry point. If a
# new autoload is added without a matching require here, Opal users will
# hit NameError at runtime.
UPSTREAM_STUBS = %w[
  lutaml/model
  lutaml/xml
  unitsdb
  unitsdb/opal
  mml
  mml/opal
  omml
  omml/opal
  ox
  htmlentities
  parslet
  plurimath
  nokogiri
].freeze

RSpec.describe "Unitsml Opal boot file" do # rubocop:disable RSpec/DescribeClass
  let(:gem_root) { Pathname.new(__dir__).join("..", "..").expand_path }
  let(:lib_root) { gem_root.join("lib") }
  let(:boot_file) { lib_root.join("unitsml", "opal.rb") }
  let(:boot_source) { boot_file.read }

  def autoload_paths_in(file)
    source = file.read
    pattern = /^\s*autoload\s+:[A-Za-z_][A-Za-z0-9_]*,?\s*["']([^"']+)["']/
    source.scan(pattern).flatten
  end

  def autoload_source_files
    [
      "unitsml.rb",
      "unitsml/unitsdb.rb",
      "unitsml/errors.rb",
      "unitsml/model.rb",
      "unitsml/model/dimension_quantities.rb",
      "unitsml/model/prefixes.rb",
      "unitsml/model/quantities.rb",
      "unitsml/model/units.rb",
    ].map { |relative| lib_root.join(relative) }
  end

  def all_autoload_paths
    autoload_source_files.flat_map { |file| autoload_paths_in(file) }.uniq
  end

  def boot_required_paths
    boot_source.scan(/^require\s+["']([^"']+)["']/).flatten
  end

  describe "static structure" do
    it "exists at lib/unitsml/opal.rb" do
      expect(boot_file).to exist
    end

    it "is syntactically valid Ruby" do
      expect do
        RubyVM::AbstractSyntaxTree.parse(boot_source)
      end.not_to raise_error
    end

    it "requires every autoloaded entry point so Opal eager-loads them" do
      missing = all_autoload_paths - boot_required_paths
      expect(missing).to be_empty,
                         "The following autoloads are not eager-required by " \
                         "lib/unitsml/opal.rb — Opal users will see " \
                         "NameError: #{missing.inspect}"
    end

    it "requires unitsml/opal/database_payload so DATABASE is defined" do
      expect(boot_required_paths).to include("unitsml/opal/database_payload"),
                                     "boot file must require " \
                                     "unitsml/opal/database_payload so " \
                                     "Unitsml::Unitsdb::Database::DATABASE " \
                                     "is set under Opal"
    end
  end

  describe "Opal builder compilation", :opal do
    it "compiles under Opal when external deps are stubbed" do
      require "opal"
      require "opal/builder"

      builder = Opal::Builder.new
      builder.append_paths(lib_root.to_s)
      builder.stubs += UPSTREAM_STUBS

      expect { builder.build("unitsml/opal") }.not_to raise_error
    end
  end
end
