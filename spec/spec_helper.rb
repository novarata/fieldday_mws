# encoding: UTF-8
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/config/"
  add_group "Models", "./lib/models"
end

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require './lib/fieldday_mws.rb'
require 'sidekiq/testing/inline' # Note this needs to come after boot is loaded as sidekiq is initialized in boot.rb

Dir["./spec/support/**/*.rb"].each {|f| require f}

def app; @app ||= FielddayMws::App end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Stub requests to any localhost route to this application
  # Any outbound requests should be stubbed separately (and not match localhost)
  config.before(:each) do
    FielddayMws::App.base_uri = "http://localhost"
    FielddayMws::App.item_sleep = 0
    
    stub_request(:any, /localhost/).to_rack(app)
  end
  
end