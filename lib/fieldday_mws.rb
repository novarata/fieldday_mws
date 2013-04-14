class FielddayMws < Sinatra::Base
  require 'sinatra'
  require 'haml'

  get '/' do
    @client_ip = request.ip
    haml :index, :format => :html5
  end
end