require 'spec_helper'

describe Store do

  it "fetch recent orders" do
    @s = stub_mws_response
    r = ApiRequest.create!(:request_type => ApiRequest::LIST_ORDERS_MWS, :store_id => @s.id)
    expect{
      expect{ 
        @s.fetch_mws_orders(r.id, Time.now - 1.week, Time.now)
      }.to change(OrderItem, :count).by(2)
    }.to change(Order, :count).by(2)
  end

end