# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "language_pack"

Gem::Specification.new do |s|
  s.name = "language_pack"
  s.version = LanguagePack::Base::BUILDPACK_VERSION.sub(/^v/, "")
  s.platform = Gem::Platform::RUBY
  s.summary = "Heroku's Ruby Buildpack"
  s.authors = ["hone", "schneems"]
  s.license = "MIT"
  s.homepage = "https://github.com/heroku/heroku-buildpack-ruby"

  s.files = Dir.glob("{bin,config,lib,vendor}/**/*") +
    %w[LICENSE README.md CHANGELOG.md buildpack.toml]
  s.require_path = "lib"
end
