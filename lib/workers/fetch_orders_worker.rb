module FielddayMws
  class FetchOrdersWorker
    include Sidekiq::Worker
    sidekiq_options queue: :orders

    def perform(p)
      FielddayMws::ApiRequest.fetch_orders(p)
    end
  end
end