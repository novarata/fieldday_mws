class ProcessOrderWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :orders

  def perform(id)
    Order.find(id).reprocess_order
  end
  
end