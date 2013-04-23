module FielddayMws
  class ApiRequest# < ActiveRecord::Base
    ITEM_SLEEP_TIME = ENV["RACK_ENV"]=='test' ? 0 : 6
    #ITEM_SLEEP_TIME = 6
    
    LIST_ORDERS = "ListOrders"

    FBA_CHANNEL = 'AFN'
    MFN_CHANNEL = 'MFN'
    FULFILLMENT_CHANNELS = [MFN_CHANNEL, FBA_CHANNEL]
    FULFILLMENT_STATUSES = ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"]

    ORDER_RESULTS_PER_PAGE = 100
    COMPLETE_STATUS = 'Complete'

    #FULLY_COMPLETED = 'fully_completed'
    #STATUS_DONE = '_DONE_'
    #ASIN_ISSUE_MESSAGE_CODE = '8541'

    #FEED_POLL_WAIT = 3.minutes
    #FEED_INCOMPLETE_WAIT = 1.minute

    #FEED_STEPS = %w( product_data product_relationship_data product_pricing product_image_data inventory_availability )
    #FEED_MSGS = %w( Product Relationship Price ProductImage Inventory )

    #belongs_to :store
    #belongs_to :parent_request, :class_name => "ApiRequest", :foreign_key => "api_request_id"

    #has_many :child_requests, :class_name => "ApiRequest", :foreign_key => "api_request_id"

    attr_accessor :mws_connection, :params, :processing_status
  
    def init_mws_connection
      return self.mws_connection unless self.mws_connection.nil?
      self.mws_connection = Amazon::MWS::Base.new(
        "access_key"        =>self.params['access_key'],
        "secret_access_key" =>self.params['secret_access_key'],
        "merchant_id"       =>self.params['merchant_id'],
        "marketplace_id"    =>self.params['marketplace_id'])
    end

    def self.fetch_order(p)
      r = ApiRequest.new
      r.params = p
      r.fetch_order(p['amazon_order_id'])
    end

    def fetch_order(amazon_order_id)
      self.init_mws_connection
      mws_response = self.mws_connection.get_orders(amazon_order_id: [amazon_order_id])
      self.process_orders(mws_response)
      self.mark_complete        
    end

    def self.fetch_orders(p)
      r = ApiRequest.new
      r.params = p
      r.fetch_orders(p['time_from'], p['time_to'])
    end

    def fetch_orders(time_from, time_to=nil)
      raise ArgumentError unless time_from.present?
      self.init_mws_connection
      time_from = time_from.is_a?(String) ? DateTime.parse(time_from) : time_from    
      args = {  last_updated_after:   time_from.iso8601,
                results_per_page:     ORDER_RESULTS_PER_PAGE,
                fulfillment_channel:  FULFILLMENT_CHANNELS,
                order_status:         FULFILLMENT_STATUSES,
                marketplace_id:       [self.params['marketplace_id']]     #TODO this handles a single marketplace only
              }
      if time_to.present?
        time_to = time_to.is_a?(String) ? DateTime.parse(time_to) : time_to
        args.merge!({ last_updated_before: time_to.iso8601 })
      end
      mws_response = self.mws_connection.list_orders(args)
      self.process_orders(mws_response)
      self.mark_complete
    end

    def check_errors(mws_response)
      raise AmazonError, "#{mws_response.code}: #{mws_response.message}" if mws_response.accessors.include?("code")
    end

    # Recursive function to process all orders
    def process_orders(mws_response)
      self.check_errors(mws_response)    
      mws_response.orders.each { |mws_order| self.process_order(mws_order) }
      return unless mws_response.next_token
      mws_response = self.mws_connection.list_orders_by_next_token(next_token: mws_response.next_token)
      self.process_orders(mws_response)
    end

    def process_order(mws_order)
      items = self.fetch_items(mws_order.amazon_order_id)
      order_hash = Order.build_hash(mws_order, items)
      order_id = Order.post_create(order_hash, self.params['orders_uri'])
    end

    def fetch_items(amazon_order_id)
      sleep ITEM_SLEEP_TIME
      mws_response = self.mws_connection.list_order_items(amazon_order_id: amazon_order_id)
      self.process_items(mws_response)
    end

    # Recursive function to process all items
    def process_items(mws_response, items=[])
      self.check_errors(mws_response)
      items += mws_response.order_items.collect { |mws_item| self.process_item(mws_item, mws_response.amazon_order_id) }
      return items unless mws_response.next_token
      mws_response = self.mws_connection.list_order_items_by_next_token(next_token: mws_response.next_token)
      return process_items(mws_response, items)
    end

    def process_item(mws_item, amazon_order_id)
      OrderItem.build_hash(mws_item, amazon_order_id)
    end

    def mark_complete
      self.processing_status = COMPLETE_STATUS
    end

  end

  class AmazonError < StandardError
  end
end