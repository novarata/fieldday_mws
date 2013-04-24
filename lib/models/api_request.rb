module FielddayMws
  class ApiRequest
    ITEM_SLEEP_TIME = 6

    FBA_CHANNEL = 'AFN'
    MFN_CHANNEL = 'MFN'
    FULFILLMENT_CHANNELS = [MFN_CHANNEL, FBA_CHANNEL]
    FULFILLMENT_STATUSES = ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"]

    ORDER_RESULTS_PER_PAGE = 100

    attr_accessor :mws_connection, :params, :item_sleep_time
  
    def init_mws_connection
      return self.mws_connection unless self.mws_connection.nil?
      self.item_sleep_time = ENV["RACK_ENV"]=='test' ? 0 : ITEM_SLEEP_TIME
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
    end

    def check_errors(mws_response)
      raise AmazonError, "#{mws_response.code}: #{mws_response.message}" if mws_response.accessors.include?("code")
    end

    # Recursive function to process all orders
    def process_orders(mws_response)
      self.check_errors(mws_response)    
      self.init_mws_connection
      #mws_response.orders.each { |mws_order| self.process_order(mws_order) }
      mws_response.orders.each do |mws_order| 
        order_hash = Order.build_hash(mws_order, self.params['api_request_id'])
        FielddayMws::ProcessOrderWorker.perform_async(order_hash, self.params)
      end
      return unless mws_response.next_token
      mws_response = self.mws_connection.list_orders_by_next_token(next_token: mws_response.next_token)
      self.process_orders(mws_response)
    end

    def self.process_order(order_hash, p)
      r = ApiRequest.new
      r.params = p
      r.process_order(order_hash)
    end

    def process_order(order_hash)
      order_hash.merge!(order_items_attributes: self.fetch_items(order_hash['foreign_order_id']))
      order_id = Order.post_create(order_hash, self.params['orders_uri'])
    end

    def fetch_items(amazon_order_id)
      #sleep self.item_sleep_time
      self.init_mws_connection
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

  end

  class AmazonError < StandardError
  end
end