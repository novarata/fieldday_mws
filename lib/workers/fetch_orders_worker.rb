class FetchOrdersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :orders, throttle: { threshold: 1, period: 6.seconds }

  def perform(store_id, time_from=nil, time_to=nil)
    ApiRequest.fetch_orders(store_id, time_from, time_to)
  end
end