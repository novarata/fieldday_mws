require 'sinatra/base'
require 'haml'
require 'active_record'
#require 'sidekiq'
#require 'redis'

# TODO remove shared DB dependency for store, pass all needed store fields as api parameters
# TODO pass callback URL as api parameter, including headers

class FielddayMws < Sinatra::Base
  configure { set :server, :puma }
  
  class << self
    attr_accessor :host, :create_order_url, :create_order_item_url

    def post_callback(uri, payload)
      RestClient.post uri, payload, :content_type => :json, :accept => :json#, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{auth_token}:X")}"
    end
    
  end
    
  #get '/' do
  #  @store_name = Store.first.name
  #  @client_ip = request.ip
  #  haml :index, :format => :html5
  #end

  post '/v1/order_items_requests' do
    p = order_items_requests_params(params)
    return 500 unless p
    #FetchItemsWorker.perform_async(p)
    ApiRequest.fetch_items(p)
    return 200
  end

  post '/v1/orders_requests' do
    p = orders_requests_params(params)
    return 500 unless p    
    #FetchOrdersWorker.perform_async(p)
    ApiRequest.fetch_orders(p)
    return 200
  end

  private
  
  def valid_params(required, valid, params)
    p = params.select { |k,v| valid.include?(k) }
    required.each { |k| return false unless p.keys.include?(k) }
    return p
  end
  
  def order_items_requests_params(params)
    required = %w(order_id amazon_order_id access_key secret_access_key merchant_id marketplace_id order_items_uri)
    valid = required + %w(store_id parent_request_id)
    valid_params(required, valid, params)
  end
  
  def orders_requests_params(params)
    required = %w(time_from access_key secret_access_key merchant_id marketplace_id orders_uri order_items_uri)
    valid = required + %w(time_to store_id)
    valid_params(required, valid, params)
  end

end