gem_group :development, :test do
  gem "factory_bot_rails"
  gem 'fuubar', require: false
  gem "rspec-rails"
end

gem_group :test do
  gem 'shoulda-matchers'
end

run "bundle install"

#################
# RSpec Install #
#################
rails_command "generate rspec:install"

###################
# Binstub Install #
###################
run 'bin/bundle binstubs rspec-core'

#######################
# RSpec Configuration #
#######################
append_to_file ".rspec", <<~CODE
  --color
  --no-profile
CODE

file 'spec/spec_helper.rb', <<~CODE
  # Given that it is always loaded, you are encouraged to keep this file as
  # light-weight as possible. Requiring heavyweight dependencies from this file
  # will add to the boot time of your test suite on EVERY test run, even for an
  # individual file that may not need all of that loaded. Instead, consider making
  # a separate helper file that requires the additional dependencies and performs
  # the additional setup, and require it from the spec files that actually need
  # it.
  #
  # See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
  RSpec.configure do |config|
    # rspec-expectations config goes here.
    config.expect_with :rspec

    # rspec-mocks config goes here.
    config.mock_with :rspec

    # Uses a progress bar instead of dots for test suite progress
    config.add_formatter 'Fuubar'

    # This allows you to limit a spec run to individual examples or groups
    # you care about by tagging them with `:focus` metadata. When nothing
    # is tagged with `:focus`, all examples get run.
    config.filter_run_when_matching :focus

    # Allows RSpec to persist some state between runs in order to support
    # the `--only-failures` and `--next-failure` CLI options. We recommend
    # you configure your source control system to ignore this file.
    config.example_status_persistence_file_path = 'spec/examples.txt'

    # Limits the available syntax to the non-monkey patched syntax that is
    # recommended. For more details, see:
    # https://relishapp.com/rspec/rspec-core/docs/configuration/zero-monkey-patching-mode
    config.disable_monkey_patching!

    # Many RSpec users commonly either run the entire suite or an individual
    # file, and it's useful to allow more verbose output when running an
    # individual spec file.
    if config.files_to_run.one?
      config.default_formatter = 'doc'
    else
      config.default_formatter = 'Fuubar'
    end

    # Print the 10 slowest examples and example groups at the
    # end of the spec run
    config.profile_examples = 10

    # Run specs in random order to surface order dependencies.
    config.order = :random

    # Seed global randomization in this process using the `--seed` CLI option.
    Kernel.srand config.seed
  end
CODE

# Allow usage of the `spec/support` folder
uncomment_lines 'spec/rails_helper.rb', %r{'spec', 'support'}

############################
# FactoryBot Configuration #
############################
copy_file File.join(__dir__, 'factory_bot.rb'), 'spec/support/factory_bot.rb'

#################################
# ShouldaMatchers Configuration #
#################################
copy_file File.join(__dir__, 'shoulda_matchers.rb'), 'spec/support/shoulda_matchers.rb'

