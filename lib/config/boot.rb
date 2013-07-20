require 'sinatra/base'
require 'sinatra/json'
require 'haml'
require 'active_record'
require 'json'
require 'oj'
require 'redis'
require 'sidekiq'
require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'faraday_middleware'

# Register RABL
#require 'rabl'
#require 'active_support/core_ext'
#require 'active_support/inflector'
#require 'builder'
#Rabl.register!

# ENVIRONMENT
ENV["RACK_ENV"] ||= "development"
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

# Require models and workers
Dir.glob(File.expand_path("../../models/*.rb", __FILE__)).each { |file| require file }
Dir.glob(File.expand_path("../../workers/*.rb", __FILE__)).each { |file| require file }

if ENV["RACK_ENV"] == 'test'
  require 'webmock'
  include WebMock::API
  FielddayMws::Client.stub_all
end

# ACTIVE RECORD
local_db_name = ENV["RACK_ENV"]=='test' ? 'fieldday_test' : 'fieldday_dev'
db = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost/#{local_db_name}")
ENV['DATABASE_URL'] = "#{database_url}?pool=20" if ENV['DATABASE_URL']
ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

# REDIS
if ['production','staging'].include? ENV['RACK_ENV']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
elsif ENV['RACK_ENV'] == 'development'
  REDIS ||= Redis.new
else
  require 'fakeredis'
  REDIS ||= Redis.new
end

# Sidekiq
if ['production','staging'].include? ENV['RACK_ENV']
  Sidekiq.configure_server do |config|
    config.redis = { :url => ENV["REDISTOGO_URL"], namespace:'fieldday_mws_workers', size:2 }

    config.server_middleware do |chain|
      chain.add Sidekiq::Throttler
    end
  end

  # When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
  Sidekiq.configure_client do |config|
    config.redis = { :url => ENV["REDISTOGO_URL"], namespace:'fieldday_mws_workers', size:1 }
  end
end