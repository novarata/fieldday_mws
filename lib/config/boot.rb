require 'sinatra/base'
require 'sinatra/json'
require 'haml'
#require 'active_record'
require 'json'
require 'oj'
#require 'redis'

# ENVIRONMENT
ENV["RACK_ENV"] ||= "development"
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require_relative '../models/api_request'
require_relative '../models/order'
require_relative '../models/order_item'
require_relative '../models/client'

# ACTIVE RECORD
=begin
local_db_name = ENV["RACK_ENV"]=='test' ? 'fieldday_test' : 'fieldday_dev'
db = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost/#{local_db_name}")
ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)
=end

# REDIS
#if ['production','staging'].include? ENV['RACK_ENV']
#  uri = URI.parse(ENV["REDISTOGO_URL"])
#  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
#elsif ENV['RACK_ENV'] == 'development'
#  REDIS = Redis.new
#else
#  require 'fakeredis'
#  REDIS = Redis.new
#end
