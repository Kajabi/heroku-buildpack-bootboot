require_relative "../config/environment"

require "rspec/core"
require "rspec/retry"
require "hatchet"

require "language_pack/shell_helpers"

ENV["RACK_ENV"] = "test"

DEFAULT_STACK = "heroku-18"

RSpec.configure do |config|
  config.alias_example_to :fit, focused: true
  config.filter_run_when_matching :focus unless ENV["CI"]

  config.default_retry_count = 2 if ENV["CI"] # retry all tests that fail again
  config.verbose_retry = true # show retry status in spec process

  config.example_status_persistence_file_path = "tmp/examples.txt"
  config.warnings = true

  config.include LanguagePack::ShellHelpers
end

ReplRunner.register_commands(:console) do |config|
  config.terminate_command "exit" # the command you use to end the 'rails console'
  config.startup_timeout 60 # seconds to boot
  config.return_char "\n" # the character that submits the command
  config.sync_stdout "STDOUT.sync = true" # force REPL to not buffer standard out
end
