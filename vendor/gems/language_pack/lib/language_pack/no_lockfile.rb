require "language_pack"
require "language_pack/base"

class LanguagePack::NoLockfile < LanguagePack::Base
  def self.use?
    !File.exists?("Gemfile.lock") && !File.exists?("gems.locked")
  end

  def name
    "Ruby/NoLockfile"
  end

  def compile
    error "Gemfile.lock or gems.locked required. Please check it in."
  end
end
