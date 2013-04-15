# encoding: UTF-8

require 'rspec'
#require 'rack/test'
#require 'sinatra/base'


# code coverage
require 'simplecov'
SimpleCov.start #do
#  add_filter "/vendor/"
#  add_filter "/bin/"
#end

ENV['RACK_ENV'] ||= 'test'
#ENV["EXPECT_WITH"] ||= "racktest"
Spec_dir = File.expand_path( File.dirname __FILE__ )
Dir[ File.join( Spec_dir, "/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true  
end