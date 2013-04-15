ENV["RACK_ENV"] ||= "development"

require 'bundler'
Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

Dir["./lib/**/*.rb"].each { |f| require f }

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/fieldday_dev')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)  

if ['production','staging'].include? ENV['RACK_ENV']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
elsif ENV['RACK_ENV'] == 'development'
  REDIS = Redis.new
else
  require 'fakeredis'
  REDIS = Redis.new
end