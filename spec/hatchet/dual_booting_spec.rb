# frozen_string_literal: true

describe "Dual booting" do
  around(:each) do |spec|
    Bundler.with_unbundled_env(&spec)
  end

  describe "different Ruby versions" do
    it "handles apps with different Ruby versions in Gemfile.lock and Gemfile_next.lock" do
      before_deploy = proc do
        FileUtils.cp("Gemfile.lock", "Gemfile_next.lock")

        open("Gemfile.lock", "a") do |f|
          f.puts <<~EOS
            RUBY VERSION
                ruby 2.4.9p362
          EOS
        end

        open("Gemfile_next.lock", "a") do |f|
          f.puts <<~EOS
            RUBY VERSION
                ruby 2.5.7p206
          EOS
        end
      end

      Hatchet::App.new("default_ruby", before_deploy: before_deploy).deploy do |app|
      end
    end
  end
end
