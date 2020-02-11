require "language_pack/installers/ruby_installer"
require "tempfile"

module BootbootBuildpack
  module HerokuRubyInstallerPatch
    # The implementation in heroku-buildpack-ruby creates links in the
    # application's `bin` directory, but we don't want to conflict with what's
    # there and want to be able to switch binstubs dynamically. The super
    # method has `bin` hardcoded though, so this temporarily moves `bin` out of
    # the way, lets the super method setup binstubs, then moves `bin` to
    # `bin_next` and the original `bin` back to `/app/bin`.
    def setup_binstubs(install_dir)
      Dir.mktmpdir do |tmpdir|
        begin
          FileUtils.mv("bin", tmpdir)
          super
          FileUtils.mv("bin", "bin_next")
          FileUtils.mv("#{tmpdir}/bin", "bin")
        ensure
          # If there was an error, make sure to restore the original `bin`
          if Dir.exist?("#{tmpdir}/bin")
            FileUtils.mv("#{tmpdir}/bin", "bin")
          end
        end
      end
    end

    LanguagePack::Installers::HerokuRubyInstaller.prepend(self)
  end
end
