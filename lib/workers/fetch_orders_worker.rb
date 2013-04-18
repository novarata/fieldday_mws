class FetchOrdersWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :orders

  def perform(store_id, time_from=nil, time_to=nil)
    ApiRequest.fetch_orders(store_id, time_from, time_to)
  end
end