class FetchOrdersWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :orders

  def perform(store)
  	Store.find_by_name(store).fetch_recent_orders
  end
end