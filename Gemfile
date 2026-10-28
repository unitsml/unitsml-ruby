# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in unitsml.gemspec
gemspec

gem "canon"
gem "nokogiri"
gem "oga"
gem "opal", "~> 1.8"
gem "ox"
gem "plurimath"
gem "pry"
gem "rake"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
gem "simplecov"

# Pinned branches until the editions release: the TreeMapper reads
# parsanol capture edition 2 trees, which need asciiunits' edition-2
# artifact (unitsml/asciiunits feat/edition-2) and the parsanol
# carrying parsanol-ruby#361. Switch both to rubygems pins once those
# releases are cut.
gem "asciiunits", github: "unitsml/asciiunits", branch: "feat/edition-2"
gem "parsanol", github: "parsanol/parsanol-ruby", branch: "fix/v2-trivia-class"
