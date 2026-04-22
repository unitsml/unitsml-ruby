# frozen_string_literal: true

require "spec_helper"

RSpec.describe Unitsml::MathmlHelper do
  let(:helper_host) { Class.new { extend Unitsml::MathmlHelper } }

  describe ".mml_v4_with_content" do
    it "replaces the mapped content attribute with the provided content" do
      instance = helper_host.send(:mml_v4_new, :mi, value: [])

      updated = helper_host.send(:mml_v4_with_content, instance, "m")

      expect(updated.value).to eq(["m"])
    end
  end
end
