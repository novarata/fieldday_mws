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

  post '/v1/order_requests' do
    request = ApiRequest.create!(:request_type => ApiRequest::LIST_ORDERS_MWS, :store_id => params[:store_id])
    FetchOrdersWorker.perform_async(request.id, params[:store_id], params[:time_from], params[:time_to])
    { :api_request_id=>request.id }
  end

end