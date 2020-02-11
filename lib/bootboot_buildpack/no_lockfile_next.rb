require "language_pack/base"

module BootbootBuildpack
  class NoLockfileNext < LanguagePack::Base
    def self.use?
      !File.exist?("Gemfile_next.lock")
    end

    def name
      "Bootboot/NoLockfileNext"
    end

    def compile
      error "Gemfile_next.lock required. Please check it in."
    end
  end
end
