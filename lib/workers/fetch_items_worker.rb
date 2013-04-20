#class FetchItemsWorker
#  include Sidekiq::Worker
#  sidekiq_options queue: :orders, throttle: { threshold: 1, period: 6.seconds }

#  def perform(params)
#    ApiRequest.fetch_items(params)
#  end
  
#end