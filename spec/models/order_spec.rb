require 'spec_helper'
include MwsHelpers

describe Order do

  it "should post and order to localhost" do
    ORDER_ID = 1
    stub_request(:post, FielddayMws.create_order_url||='blah').to_return(status:[200, "OK"], body:{order_id:ORDER_ID})
    order_id = Order.post_create({ :foreign_order_id => 'asdlfkjasdf' })
    order_id.should eq ORDER_ID
  end

end