#class FetchOrdersWorker
#  include Sidekiq::Worker
#  sidekiq_options queue: :orders, throttle: { threshold: 1, period: 6.seconds }
#  def perform(params)
#    ApiRequest.fetch_orders(params)
#  end
#end