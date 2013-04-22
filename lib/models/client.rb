module FielddayMws
  class Client
  
    # get orders from Amazon storefront between two times
    def self.fetch_orders(mws_params, time_from, time_to=nil)
      uri = "#{FielddayMws::App.base_uri}/v1/orders_requests"      
      begin
        response = RestClient.post uri, mws_params.merge({ time_from:time_from, time_to:time_to }).to_json
      rescue RestClient::InternalServerError => e
        return e.message
      end
      return response.body
    end

    # get orders from Amazon storefront between two times
    def self.fetch_order(mws_params, amazon_order_id)
      uri = "#{FielddayMws::App.base_uri}/v1/order_requests"      
      begin
        response = RestClient.post uri, mws_params.merge({ amazon_order_id:'blah' }).to_json
      rescue RestClient::InternalServerError => e
        return e.message
      end
      return response.body
    end  
  
  end
end