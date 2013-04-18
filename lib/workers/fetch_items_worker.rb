class FetchItemsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :order_items, throttle: { threshold: 1, period: 6.seconds }

  def perform(store_id, order_id, amazon_order_id, parent_request_id=nil)
    ApiRequest.fetch_items(store_id, order_id, amazon_order_id, parent_request_id)
  end
  
end