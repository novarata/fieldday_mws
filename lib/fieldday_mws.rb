require 'sinatra/base'
require 'haml'
require 'active_record'
require 'sidekiq'
require 'redis'

class FielddayMws < Sinatra::Base
  configure { set :server, :puma }
  
  get '/' do
    @store_name = Store.first.name
    @client_ip = request.ip
    haml :index, :format => :html5
  end

  post '/v1/order_requests' do
    p = params[:order_request]
    if p[:store_id] && p[:time_from] && p[:time_to]
      request = ApiRequest.create!(:request_type => ApiRequest::LIST_ORDERS_MWS, :store_id => p[:store_id])
      FetchOrdersWorker.perform_async(request.id, p[:store_id], p[:time_from], p[:time_to])
      return { :api_request_id=>request.id }
    else
      return 500
    end
  end

end