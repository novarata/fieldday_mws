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
      attr_accessor :base_uri, :item_sleep

      def post_json(uri, payload)
        #Typhoeus.post uri, body: payload, headers: { :content_type => :json, :accept => :json }
        #RestClient.post uri, payload, :content_type => :json, :accept => :json#, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{auth_token}:X")}"     
        conn = Faraday.new(url: uri) do |faraday|
          faraday.request :json
          faraday.adapter :typhoeus
          faraday.response :json, :content_type => /\bjson$/
          #faraday.response :logger                  # log requests to STDOUT
        end
        response = conn.post { |req| req.body = payload }      
        halt response.status if response.status >= 400
        return response        
      end
      
      def post_callback(uri, payload)
        return post_json(uri, payload)
      end
    end
    
    get '/' do
      @version = 1 
      @client_ip = request.ip
      haml :index, :format => :html5
    end
    
    post '/v1/order_requests' do
      begin
        params = JSON.parse(request.body.read)#env["rack.input"].read) # TODO change to request.body hopefully
        p = order_requests_params(params)
        FielddayMws::FetchOrderWorker.perform_async(p)
        #FielddayMws::OrdersRequest.fetch_order(p)
        return 200
      rescue ArgumentError, JSON::ParserError => e
        logger.fatal $!
        return error 400, e.message.to_json
      end
    end

    post '/v1/orders_requests' do
      begin
        params = JSON.parse(request.body.read)#env["rack.input"].read)
        p = orders_requests_params(params)
        #FielddayMws::OrdersRequest.fetch_orders(p)
        FielddayMws::FetchOrdersWorker.perform_async(p)
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
      required = %w(access_key secret_access_key merchant_id marketplace_id orders_uri amazon_order_id)
      valid = required + %w(api_request_id)
      valid_params(required, valid, params)
    end
  
    def orders_requests_params(params)
      required = %w(access_key secret_access_key merchant_id marketplace_id orders_uri time_from)
      valid = required + %w(time_to api_request_id)
      valid_params(required, valid, params)
    end

  end
end