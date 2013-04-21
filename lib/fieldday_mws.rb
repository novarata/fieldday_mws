require 'sinatra/base'
require 'sinatra/json'
require 'haml'
require 'active_record'
require 'oj'
#require 'sidekiq'
#require 'redis'

# TODO remove shared DB dependency for store, pass all needed store fields as api parameters
# TODO pass callback URL as api parameter, including headers

class FielddayMws < Sinatra::Base
  helpers Sinatra::JSON

  configure { 
    set :server, :puma 
    set :json_encoder, Oj
  }
  configure :development do
    enable :logging, :dump_errors, :raise_errors
  end
  set :show_exceptions, true if development?
  
  class << self
    attr_accessor :host

    def post_callback(uri, payload)
      RestClient.post uri, payload, :content_type => :json, :accept => :json#, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{auth_token}:X")}"
    end
    
  end
    
  #get '/' do
    #@store_name = Store.first.name
    #@client_ip = request.ip
    #haml :index, :format => :html5
  #end

  post '/v1/order_items_requests' do
    begin
      params = JSON.parse(request.env["rack.input"].read)
      p = order_items_requests_params(params)
      ApiRequest.fetch_items(p)
      return 200
    rescue ArgumentError, JSON::ParserError
      #logger.info $!
      #puts $!
      return 500
    end
  end

  post '/v1/orders_requests' do
    begin
      params = JSON.parse(request.env["rack.input"].read)
      #puts params.inspect
      p = orders_requests_params(params)
      #puts p.inspect
      #logger.info params.inspect
      #logger.info p.inspect
      ApiRequest.fetch_orders(p)
      return 200
    rescue ArgumentError, JSON::ParserError
      #logger.info $!
      #puts $!
      return 500
    end
  end

  private
  
  def valid_params(required, valid, params)
    p = params.select { |k,v| valid.include?(k) }
    required.each { |k| raise ArgumentError unless p.keys.include?(k) }
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