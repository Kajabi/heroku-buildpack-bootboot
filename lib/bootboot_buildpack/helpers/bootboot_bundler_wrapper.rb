require "language_pack/helpers/bundler_wrapper"

module BootbootBuildpack
  module Helpers
    class BootbootBundlerWrapper < LanguagePack::Helpers::BundlerWrapper
      # Gemfile.lock -> Gemfile_next.lock
      # gems.locked -> gems_next.locked
      def lockfile_path
        super.sub(".lock", "_next.lock")
      end

      # Bundler 1.17.3 and 2.0.2 both use `bundle config --delete name` to
      # delete config values, which internally sets to nil both locally and
      # globally. Bundler 2.1 has slightly different behavior on the command
      # line (using `bundle config unset name` and supporting specifying local
      # scope, global scope, or both) but still internally calls the same
      # methods. However it is possible this will change in future versions, so
      # if/when newer versions of Bundler are used, this method should be
      # carefully tested against them.
      # TODO: This can probably moved to the Ruby buildpack
      def config_delete(name)
        Bundler.settings.set_local(name, nil)
        Bundler.settings.set_global(name, nil)
      end

      # BundlerWrapper#ruby_version uses `bundle platform` but unfortunately
      # `bundle platform` is one of the few bundler commands that is
      # effectively impossible to monkey patch. Since we can't affect the
      # output of `bundle platform` via bootboot, this copies the same .sub
      # code as the super class but looks at the lockfile instead.
      # TODO: This can probably be moved to the Ruby buildpack
      def ruby_version
        lockfile_next_version = Bundler::LockfileParser.new(lockfile_path.read).ruby_version

        if lockfile_next_version
          lockfile_next_version.chomp.sub("(", "").sub(")", "").sub(/(p-?\d+)/, ' \1').split.join("-")
        else
          super
        end
      end
    end
  end
end
