require 'sinatra/base'
require 'haml'
require "sinatra/activerecord"

Dir["./lib/models/*.rb"].each {|file| require file }

class FielddayMws < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure { set :server, :puma }
  
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
    
  get '/' do
    @store_name = Store.first.name
    @client_ip = request.ip
    haml :index, :format => :html5
  end

  #run! if app_file == $0
end