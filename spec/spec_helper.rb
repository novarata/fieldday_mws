# encoding: UTF-8

require 'rspec'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
require_relative '../lib/config/boot.rb'

require 'sidekiq/testing/inline' # do not delay sidekiq jobs

# code coverage
require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end