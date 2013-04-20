# ENVIRONMENT
ENV["RACK_ENV"] ||= "development"
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

# INCLUDE FILES
Dir["./lib/**/*.rb"].each { |f| require f }

# ACTIVE RECORD
local_db_name = ENV["RACK_ENV"]=='test' ? 'fieldday_test' : 'fieldday_dev'
#ENV['DATABASE_URL'] = "#{database_url}?pool=20" if ENV['DATABASE_URL'] # pool of workers for Active Record
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


# SIDEKIQ
#if ['production','staging'].include? ENV['RACK_ENV']
#  Sidekiq.configure_server do |config|
#    config.redis = { :url => ENV["REDISTOGO_URL"], namespace:'fieldday_mws_workers', size:9 }
#
#    config.server_middleware do |chain|
#      chain.add Sidekiq::Throttler
#    end
#  end

  # When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
#  Sidekiq.configure_client do |config|
#    config.redis = { :url => ENV["REDISTOGO_URL"], namespace:'fieldday_mws_workers', size:1 }
#  end
#end