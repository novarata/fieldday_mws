require 'sinatra/base'
require 'haml'
require "sinatra/activerecord"
require 'sidekiq'
require 'redis'

class FielddayMws < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  configure { set :server, :puma }
  
  get '/' do
    @store_name = Store.first.name
    @client_ip = request.ip
    haml :index, :format => :html5
  end

end