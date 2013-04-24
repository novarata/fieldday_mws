module FielddayMws
  class ProcessOrderWorker
    include Sidekiq::Worker
    sidekiq_options queue: :orders, throttle: { threshold: 1, period: 6.seconds }

    def perform(mws_order, p)
      OrdersRequest.process_order(mws_order, p)
    end
  end
end