require 'rest_client'

class Order
      
  PERMITTED_FIELDS = [:purchase_date, :last_update_date, :order_status, :fulfillment_channel,
  :sales_channel, :order_channel, :ship_service_level, :amount, :currency_code, :name, :address_line_1,
  :address_line_2, :address_line_3, :city, :county, :district, :state_or_region, :postal_code, :country_code,
  :phone, :number_of_items_shipped, :number_of_items_unshipped, :marketplace_id, :buyer_name, :buyer_email,
  :shipment_service_level_category, :api_response_id]
  
  def self.create_url; FielddayMws.create_order_url end
  
  # Send a POST HTTP request to create an order
  def self.post_create(order_hash)
    response = RestClient.post Order.create_url, :order => order_hash
    return response[:order_id]
  end

  # Take an amazon format order object and some additional information and construct a hash suitable for POSTing
  def self.build_hash(mws_order, response_id, store_id, channel)
    mws_order.as_hash.select{|k,v| PERMITTED_FIELDS.include?(k)}.merge({
      :foreign_order_id => mws_order.amazon_order_id,
      :api_response_id=>response_id,
      :store_id=>store_id,
      :purchase_date=>mws_order.purchase_date,
      :order_channel=>channel
    })
  end

end