# ENVIRONMENT
ENV["RACK_ENV"] ||= "development"
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

# INCLUDE FILES
Dir["./lib/**/*.rb"].each { |f| require f }

# ACTIVE RECORD
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

# REDIS
if ['production','staging'].include? ENV['RACK_ENV']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
elsif ENV['RACK_ENV'] == 'development'
  REDIS = Redis.new
else
  require 'fakeredis'
  REDIS = Redis.new
end

# SIDEKIQ
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler
  end
end

