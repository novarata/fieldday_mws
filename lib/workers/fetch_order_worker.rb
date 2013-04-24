module FielddayMws
  class FetchOrderWorker
    include Sidekiq::Worker
    sidekiq_options queue: :orders

    def perform(p)
      FielddayMws::ApiRequest.fetch_order(p)
    end
  end
end