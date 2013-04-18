require 'sinatra/base'
require 'haml'
require 'active_record'
require 'sidekiq'
require 'redis'

class FielddayMws < Sinatra::Base
  configure { set :server, :puma }
  
  class << self
    attr_accessor :host, :create_order_url, :create_order_item_url
  end
    
  get '/' do
    @store_name = Store.first.name
    @client_ip = request.ip
    haml :index, :format => :html5
  end

  post '/v1/order_items_requests' do
    if params[:store_id] && params[:order_id] && params[:amazon_order_id]
      FetchItemsWorker.perform_async(params[:store_id], params[:order_id], params[:amazon_order_id])
      return 200
    end
    return 500
  end

  post '/v1/orders_requests' do
    if params[:store_id] && params[:time_from]
      FetchOrdersWorker.perform_async(params[:store_id], params[:time_from], params[:time_to])
      return 200
    end
    return 500
  end

end