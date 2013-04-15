class FetchOrdersWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :orders

  def perform(api_request_id, store_id, from_time=nil, to_time=nil)
    Store.find(store_id).fetch_mws_orders(from_time, to_time)
  end
end