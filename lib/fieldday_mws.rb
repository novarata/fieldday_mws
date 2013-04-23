require_relative 'config/boot'

module FielddayMws

  class App < Sinatra::Base
    helpers Sinatra::JSON

    configure { 
      set :server, :puma 
      set :json_encoder, Oj
    }
    configure :development do
      enable :logging, :dump_errors, :raise_errors
    end
    set :show_exceptions, false if development?
  
    class << self
      attr_accessor :base_uri

      def post_callback(uri, payload)
        RestClient.post uri, payload, :content_type => :json, :accept => :json#, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{auth_token}:X")}"
      end
    
    end
    
    get '/' do
      @version = 1 
      @client_ip = request.ip
      haml :index, :format => :html5
    end
    
    post '/v1/order_requests' do
      begin
        params = JSON.parse(request.env["rack.input"].read)
        p = order_requests_params(params)
        FielddayMws::ApiRequest.fetch_order(p)
        return 200
      rescue ArgumentError, JSON::ParserError => e
        logger.fatal $!
        return error 400, e.message.to_json
      end
    end

    post '/v1/orders_requests' do
      begin
        params = JSON.parse(request.env["rack.input"].read)
        p = orders_requests_params(params)
        FielddayMws::ApiRequest.fetch_orders(p)
        return 200
      rescue ArgumentError, JSON::ParserError => e
        logger.fatal $!
        return error 400, e.message.to_json
      end
    end

    private
  
    def valid_params(required, valid, params)
      p = params.select { |k,v| valid.include?(k) }
      required.each { |k| raise ArgumentError unless p.keys.include?(k) }
      return p
    end
  
    def order_requests_params(params)
      required = %w(amazon_order_id access_key secret_access_key merchant_id marketplace_id orders_uri)
      valid = required
      valid_params(required, valid, params)
    end
  
    def orders_requests_params(params)
      required = %w(time_from access_key secret_access_key merchant_id marketplace_id orders_uri)
      valid = required + %w(time_to)
      valid_params(required, valid, params)
    end

  end
end