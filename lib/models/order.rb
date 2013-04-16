class Order < ActiveRecord::Base
  MAX_ORDER_ITEM_PAGES = 20
  MAX_FAILURE_COUNT = 1
  ORDER_ITEM_FAIL_WAIT = 60  
      
  PERMITTED_ORDER_FIELDS = [:purchase_date, :last_update_date, :order_status, :fulfillment_channel,
  :sales_channel, :order_channel, :ship_service_level, :amount, :currency_code, :name, :address_line_1,
  :address_line_2, :address_line_3, :city, :county, :district, :state_or_region, :postal_code, :country_code,
  :phone, :number_of_items_shipped, :number_of_items_unshipped, :marketplace_id, :buyer_name, :buyer_email,
  :shipment_service_level_category, :api_response_id]

  belongs_to :api_response
  belongs_to :store
  has_many :order_items, :dependent => :destroy
  
  
  # Process XML order into ActiveRecord, and process items on order
  def process_order(mws_connection)
    #puts "      PROCESS_ORDER: #{self.foreign_order_id}"
    return_code = self.fetch_order_items(mws_connection)
    #self.append_to_omx_if_clean # TODO move this to orders controller
    return return_code
  end

  def reprocess_order
    self.store.init_store_connection
    self.process_order(self.store.mws_connection)
  end

  # fetch items associated with this order
  # calls the Amazon MWS API
  def fetch_order_items(mws_connection)    
    #puts "        FETCH_ORDER_ITEMS: for order #{self.foreign_order_id}, about to call MWS ListOrderItems"
    parent_request = self.api_response.api_request
    request = ::ApiRequest.create!(:request_type => "ListOrderItems", :store_id => parent_request.store_id, :api_request_id => parent_request.id)
    response = mws_connection.get_list_order_items(:amazon_order_id => self.foreign_order_id)
    #puts "        FETCH_ORDER_ITEMS: called MWS ListOrderItems, about to process response"
    next_token = request.process_response(mws_connection, response,0,0)
    #puts "        FETCH_ORDER_ITEMS: back, finished process_response"
    if next_token.is_a?(Numeric)
      return next_token
    end
  
    page_num = 1
    failure_count = 0
    while next_token.is_a?(String) && page_num<MAX_ORDER_ITEM_PAGES do
      #puts "        FETCH_ORDER_ITEMS: next_token is present, about to fetch by next token for #{self.foreign_order_id}"
      response = mws_connection.get_list_order_items_by_next_token(:next_token => next_token)
      #puts "        FETCH_ORDER_ITEMS: called MWS ListOrderItemsByNextToken, about to process response"
      n = request.process_response(mws_connection,response,page_num,ORDER_ITEM_FAIL_WAIT)
      if n.is_a?(Numeric)
        failure_count += 1
        if failure_count >= MAX_FAILURE_COUNT
          return n
        end
      else
        page_num += 1 # don't want to increment page if there is an error
        next_token = n
      end
      #puts "        FETCH_ORDER_ITEMS: finished process_response for next token"
    end
    #puts "        FETCH_ORDER_ITEMS: finishing order #{self.foreign_order_id}"
  end

  def process_order_item(item, response_id)
    #puts "              PROCESS_ORDER_ITEM: order #{self.foreign_order_id}, item #{item.foreign_order_item_id}"

    amz_item = OrderItem.find_by(foreign_order_item_id: item.amazon_order_item_id)
    if amz_item.nil?
      amz_item = OrderItem.create(:foreign_order_item_id=>item.amazon_order_item_id, :seller_sku=>item.seller_sku, :api_response_id=>response_id, :order_id=>self.id, :foreign_order_id=>self.foreign_order_id)
      #puts "              PROCESS_ORDER_ITEM: new item #{amz_item.foreign_order_item_id} created, id: #{amz_item.id}"
    else
      #puts "              PROCESS_ORDER_ITEM: existing item #{amz_item.foreign_order_item_id} updated, id: #{amz_item.id}"    
    end

    amz_item.update_attributes(item.as_hash.select{ |k,v| OrderItem::PERMITTED_ITEM_ATTRS.include?(k) })
    #puts "              PROCESS_ORDER_ITEM: finished"
  end

end