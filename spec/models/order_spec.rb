require 'spec_helper'
include MwsHelpers

describe Order do

  it "should post and order to localhost" do
    order_id = 1
    orders_uri = 'blah'
    
    stub_request(:post, orders_uri).to_return(status:[200, "OK"], body:{order_id:order_id})
    order_id = Order.post_create({ :foreign_order_id => 'asdlfkjasdf' }, orders_uri)
    order_id.should eq order_id
  end

end