# encoding: UTF-8

require 'rspec'
require 'rack/test'
#require 'sidekiq/testing/inline' # do not delay sidekiq jobs


ENV['RACK_ENV'] = 'test'
require_relative '../lib/config/boot.rb'

# code coverage
require 'simplecov'
SimpleCov.start #do
#  add_filter "/vendor/"
#  add_filter "/bin/"
#end

#ENV["EXPECT_WITH"] ||= "racktest"
#Spec_dir = File.expand_path( File.dirname __FILE__ )
#Dir[ File.join( Spec_dir, "/support/**/*.rb")].each { |f| require f }

#RSpec.configure do |config|
#  config.treat_symbols_as_metadata_keys_with_true_values = true  
#end
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