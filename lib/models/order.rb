require 'rest_client'

module FielddayMws
  class Order
    
    PERMITTED_FIELDS = [:purchase_date, :last_update_date, :order_status, :fulfillment_channel,
    :sales_channel, :order_channel, :ship_service_level, :amount, :currency_code, :name, :address_line_1,
    :address_line_2, :address_line_3, :city, :county, :district, :state_or_region, :postal_code, :country_code,
    :phone, :number_of_items_shipped, :number_of_items_unshipped, :marketplace_id, :buyer_name, :buyer_email,
    :shipment_service_level_category, :api_request_id]

    # Send a POST HTTP request to create an order
    def self.post_create(order_hash, orders_uri)
      # TODO include retry logic or put through Sidekiq worker with retry
      response = FielddayMws::App.post_callback(orders_uri, {order:order_hash}.to_json)
      JSON.parse(response.body)["order"]["id"]
    end

    # Take an amazon format order object and some additional information and construct a hash suitable for POSTing
    def self.build_hash(mws_order, api_request_id=nil)
      mws_order.as_hash.select{|k,v| PERMITTED_FIELDS.include?(k)}.merge({
        foreign_order_id: mws_order.amazon_order_id,
        api_request_id: api_request_id,
      })
    end

  end
end