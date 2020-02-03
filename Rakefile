# frozen_string_literal: true

require File.expand_path("config/environment", __dir__)

require "hatchet/tasks"
require "rspec/core/rake_task"
require "tempfile"

desc "Update vendored heroku-buildpack-ruby"
task "vendor:ruby-buildpack", [:tgz] do |t, args|
  require "open-uri"

  unless args.tgz
    latest_release_url = URI.open("https://api.github.com/repos/Kajabi/heroku-buildpack-ruby/releases/latest") { |res|
      JSON.parse(res.read)["tarball_url"]
    }

    args.with_defaults tgz: latest_release_url
  end

  Dir.mktmpdir do |dir|
    URI.open(args.tgz) do |f|
      system("tar xzf #{f.path} --directory=#{dir} --strip-components=1")
      system("cp vendor/gems/language_pack.gemspec #{dir}")
      system("gem build language_pack.gemspec", chdir: dir)
      system("gem unpack --target vendor/gems/ #{dir}/language_pack-*.gem")
      system("rm -rf vendor/gems/language_pack")
      system("mv vendor/gems/language_pack-* vendor/gems/language_pack")
    end
  end
end

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[-fs --color]
end
task default: :spec
