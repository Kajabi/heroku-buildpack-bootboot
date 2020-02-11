require "language_pack/shell_helpers"

require "bootboot_buildpack/helpers/bootboot_bundler_wrapper"
require "bootboot_buildpack/bootboot_metadata"

# Most of the methods on this class are overrides of methods that exist on
# LanguagePack::Ruby and most of them are called by LanguagePack::Ruby#compile.
module BootbootBuildpack
  class Bootboot < LanguagePack::Ruby
    def self.bundler
      @bundler ||= begin
        setup_bootboot_buildpack_environment
        bundler = Helpers::BootbootBundlerWrapper.new
        topic "Using #{bundler.gemfile} and #{bundler.lockfile} for Bundler"
        bundler
      end.install
    end

    def self.use?
      bundler.gemfile_path.exist? && bundler.lockfile_path.exist?
    end

    def self.env_next
      @env_next ||= begin
        # The Ruby buildpack will have already installed the version of
        # bundler used in Gemfile.lock, so we want to use that version to
        # determine the correct environment variable for dual booting since
        # actually loading bundler in this process before we have set the env
        # var will complicate things
        env_prefix = `bundle exec ruby -e 'print Bundler.settings["bootboot_env_prefix"] || "DEPENDENCIES"'`
        "#{env_prefix}_NEXT"
      end
    end

    class << self
      private

      def setup_bootboot_buildpack_environment
        topic "Dectected Bootboot environment variable #{env_next}"

        # Force all calls to bundler to use the NEXT dependencies
        ENV[env_next] = "1"
        ENV["HEROKU_BUILDPACK_BOOTBOOT"] = "1"
      end
    end

    def env_next
      self.class.env_next
    end

    def initialize(*)
      super
      @metadata = BootbootMetadata.new(@cache)
    end

    def name
      "Bootboot 👢👢"
    end

    # This is used both for writing to profiled via binstubs_relative_paths as
    # well as passed to bundler as --bin. It is necessary to use `bin_next` so
    # that if the Ruby version is the same for NEXT and PREV we can have two
    # separate sets of binstubs in the same Ruby directory
    def bundler_binstubs_path
      "vendor/bundle/bin_next"
    end

    # These paths are added to profiled, but not used to actually know where to
    # install things, that's done via bundler_binstubs_path,
    # write_bundler_shim, and setup_bootboot_buildpack_environment.
    def binstubs_relative_paths
      [
        "bin_next",
        bundler_binstubs_path,
        "#{slug_vendor_base}/bin_next",
      ]
    end

    def write_bundler_shim(path)
      super(path.sub(/bin$/, "bin_next"))
    end

    # We don't want to run the super version of this, we just want to
    # supplement what is already there.
    def setup_profiled
      profiled_path = [binstubs_relative_paths.map { |path| "$HOME/#{path}" }.join(":")]
      profiled_path << "$PATH"

      add_to_profiled <<~EOS
        if [ -n "$#{env_next}" ]; then
          export PATH="#{profiled_path.join(":")}"
          export BUNDLE_BIN="#{bundler_binstubs_path}"
        else
          export BUNDLE_BIN="vendor/bundle/bin"
        fi
      EOS
    end

    def cleanup
      # Bundler's plugin installation adds absolute paths to
      # .bundle/plugin/index which breaks when the slug is deployed, so this
      # replaces the absolute path with `/app`. $HOME would be less tightly
      # coupled, but doesn't seem to work.
      run!("sed -i 's|#{build_path}|/app|' .bundle/plugin/index")

      # Ruby#build_bundler calls bundle install with --binstubs (which sets the
      # "bin" config). In the blessed versions of bundler, this config value is
      # automatically written to .bundle/config and overrides any environment
      # variables (though this is likely to change in the future). We want to
      # be able to adjust the gem executables via environment variables, so we
      # need to explicitly delete this from .bundle/config.
      bundler.config_delete("bin")
    end

    # Ruby#compile calls several methods that we want to just be no-ops
    [
      :check_for_bundle_config,
      :create_database_yml,
      :load_bundler_cache,
      :remove_vendor_bundle,
      :run_assets_precompile_rake_task,
      :setup_export,
      :vendor_libpg,
    ].each do |m|
      define_method m, proc {}
    end
  end
end
