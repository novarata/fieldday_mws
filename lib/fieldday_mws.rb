require 'sinatra/base'
require 'haml'

class FielddayMws < Sinatra::Base

  configure { set :server, :puma }
  
  get '/' do
    @client_ip = request.ip
    haml :index, :format => :html5
  end

  run! if app_file == $0
end