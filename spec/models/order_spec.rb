require 'spec_helper'
include MwsHelpers

describe Order do

  it "mws stores should have mws_connection" do
    s = stub_mws_store
    s.init_store_connection
    s.mws_connection.should be_a Amazon::MWS::Base
  end

  it "order should have an associated MWS connection" do
    s = stub_mws_store
    o = Order.create(:store_id=>s.id)

    s2 = o.reload.store
    s2.init_store_connection
    s2.name.should eq s.name
    s2.store_type.should eq 'MWS'
    s.mws_connection.should be_a Amazon::MWS::Base
  end

  it "should post and order to localhost" do
    RestClient.post '/orders', :order => { :foreign_order_id => 'asdlfkjasdf' }
  end

end