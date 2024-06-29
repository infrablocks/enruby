# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
end

require 'bundler/setup'
require 'faker'

require 'enruby_spec'

Dir[File.join(__dir__, 'support', '**', '*.rb')]
  .each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
