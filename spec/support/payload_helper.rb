# frozen_string_literal: true

# Spec helper for slicing the Ruby hash literal out of an auto-generated
# `Unitsml::Unitsdb::Database` payload file. Used by both the
# PayloadGenerator spec and the payload-sync spec.
module PayloadHelper
  WRAPPER_PREFIXES = [
    "Unitsml::Unitsdb::Database.load_opal_payload(",
    "Unitsml::Unitsdb::Database.const_set(:DATABASE, ",
  ].freeze

  WRAPPER_SUFFIX = ".freeze)\n"

  module_function

  # Strips comments, leading/trailing wrapper, and `.freeze` so the
  # remainder is a bare Ruby hash literal that can be `eval`-ed.
  def extract_payload_hash_literal(source)
    non_comment_lines = source.each_line.reject do |line|
      line.start_with?("#") || line.strip.empty?
    end

    joined = non_comment_lines.join
    prefix = WRAPPER_PREFIXES.find { |candidate| joined.start_with?(candidate) }
    raise "No known payload wrapper prefix found" unless prefix

    joined.delete_prefix(prefix).delete_suffix(WRAPPER_SUFFIX)
  end
end
