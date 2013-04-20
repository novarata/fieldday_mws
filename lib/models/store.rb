class Store
  #attr_accessor :mws_connection
  #has_many :api_requests, :dependent => :destroy

  FBA_CHANNEL = 'AFN'
  MFN_CHANNEL = 'MFN'
  FULFILLMENT_CHANNELS = [MFN_CHANNEL, FBA_CHANNEL]
  FULFILLMENT_STATUSES = ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"]

  #def init_store_connection
  #  return unless self.mws_connection.nil? && self.mws_access_key.present?
    #Amazon::MWS::Base.debug=true
  #  self.mws_connection = Amazon::MWS::Base.new(
  #    "access_key"=>self.mws_access_key,
  #    "secret_access_key"=>self.mws_secret_access_key,
  #    "merchant_id"=>self.mws_merchant_id,
  #    "marketplace_id"=>self.mws_marketplace_id )
  #  return self.mws_connection
  #end

=begin
  # Try again to fetch the order items for orders that are missing items
  def reprocess_orders_missing_items
    self.init_store_connection
    orders_array = get_orders_missing_items
    sleep_time = ::ApiRequest.get_sleep_time_per_order(orders_array.count)
    orders_array.each_with_index { |o,i| ProcessOrderWorker.perform_in((sleep_time*i).seconds, o.id) }
  end
=end

  #def fetch_items(order_id, amazon_order_id)
  #  ApiRequest.fetch_items(self.id, order_id, amazon_order_id)
  #end

  # get orders from Amazon storefront between two times
  #def fetch_orders(time_from, time_to)
  #  ApiRequest.fetch_orders(self.id, time_from, time_to)
  #end

=begin
  def sync_listings_mws
    # create a new api_request, with request_type SubmitFeed
    request = ::ApiRequest.create!(
      :store_id=>self.id,
      :request_type=>::ApiRequest::SUBMIT_MWS,
      :feed_type=>ApiRequest::FEED_STEPS[0],
      :message_type=>ApiRequest::FEED_MSGS[0])

    # Take all listings that are unsynchronized (queued for synchronization, have now api_request_id), by order of listing creation
    request.update_attributes!(:message => self.queued_listings.collect { |l| l.assign_amazon!(request) })
    FeedWorker.perform_async(::ApiRequest::SUBMIT_MWS, request.id)
    return request    
  end
=end
  
end