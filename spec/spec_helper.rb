# encoding: UTF-8
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/config/"
  add_group "Models", "./lib/models"
end

require 'rspec'
require 'rack/test'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'
require_relative '../lib/config/boot.rb'

#require 'sidekiq/testing/inline' # do not delay sidekiq jobs

Dir["./spec/support/**/*.rb"].each {|f| require f}

def app; @app ||= FielddayMws end

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