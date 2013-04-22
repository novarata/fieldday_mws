require 'spec_helper'
include MwsHelpers

describe FielddayMws::Order do

  it "should post and order to localhost" do
    order_id = 1
    orders_uri = 'blah'
    
    stub_request(:post, orders_uri).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
    order_id = FielddayMws::Order.post_create({ :foreign_order_id => 'asdlfkjasdf' }, orders_uri)
    order_id.should eq order_id
  end

  it "should build a hash" do
    
  end
  
end