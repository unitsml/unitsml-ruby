# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe Unitsml do
  it "has a version number" do
    expect(Unitsml::VERSION).not_to be_nil
  end

  it "does not change an existing global XML adapter when required" do
    lib_path = File.expand_path("../lib", __dir__)
    script = <<~RUBY
      require "lutaml/model"
      Lutaml::Model::Config.xml_adapter_type = :nokogiri
      require "unitsml"

      unless Lutaml::Model::Config.xml_adapter_type == :nokogiri
        abort "expected :nokogiri, got \#{Lutaml::Model::Config.xml_adapter_type.inspect}"
      end
    RUBY

    _stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-I",
      lib_path,
      "-e",
      script,
    )

    expect(status).to be_success, stderr
  end

  it "parses a basic unit expression" do
    formula = described_class.parse("mm")
    expect(formula).to be_a(Unitsml::Formula)
    expect(formula.to_latex).to eq("m\\ensuremath{\\mathrm{m}}")
  end
end
