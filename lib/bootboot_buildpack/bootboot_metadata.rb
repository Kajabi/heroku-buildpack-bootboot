require "language_pack/metadata"

module BootbootBuildpack
  class BootbootMetadata < LanguagePack::Metadata
    KEY_TRANSFORMS = {
      "buildpack_ruby_version" => "bootboot_buildpack_ruby_version",
      "ruby_version" => "bootboot_ruby_version",
      "bundler_version" => "bootboot_bundler_version",
      "rubygems_version" => "bootboot_rubygems_version",
    }

    def read(key)
      super(transform_key(key))
    end

    def exists?(key)
      super(transform_key(key))
    end

    def write(key, *args)
      super(transform_key(key), *args)
    end

    private

    def transform_key(key)
      KEY_TRANSFORMS.fetch(key, key)
    end
  end
end
