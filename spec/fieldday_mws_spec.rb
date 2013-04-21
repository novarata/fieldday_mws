# encoding: UTF-8
require 'spec_helper'
include MwsHelpers

#require_relative "../lib/fieldday_mws.rb"
#require_relative "../lib/models/api_requesd.rb"
#require_relative "../lib/models/store.rb"

describe "App" do

  #describe "GET '/'" do
  #  it "should be successful" do
  #    Store.create(:name=>'Blah')
  #    get '/'
  #    last_response.should be_ok
  #  end
  #end

  describe "POST '/v1/order_requests" do
    it "should successfully fetch specified orders with valid inputs" do
      r = stub_mws_request
      c = r.init_mws_connection
      orders_response = stub_get_orders(c)
      orders_response.stub(:next_token).and_return(nil) # Pretend there was no next token
      
      stub_request(:post, r.params['orders_uri']).with(body:{order:FIXTURE_ORDER1}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)

      p = CONNECTION_PARAMS.merge({
        'orders_uri' => 'http://localhost:3000/orders',
        'store_id' => 1,
        'amazon_order_id' => 'TESTING',
      })
    
      post '/v1/order_requests', p.to_json
      WebMock.should have_requested(:post, r.params['orders_uri']).once
    end
    
    it "should error on missing params entirely" do
      post '/v1/order_requests'
      last_response.should_not be_ok
      last_response.body.should eq 'A JSON text must at least contain two octets!'
    end
  end

  
  describe "POST '/v1/orders_requests" do
    it "should successfully fetch multiple orders with valid inputs" do
      r = stub_mws_request
      stub_request(:post, r.params['orders_uri']).with(body:{order:FIXTURE_ORDER1}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      stub_request(:post, r.params['orders_uri']).with(body:{order:FIXTURE_ORDER2}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      post '/v1/orders_requests', r.params.to_json
      WebMock.should have_requested(:post, r.params['orders_uri']).twice
    end
    
    it "should error on missing params entirely" do
      post '/v1/orders_requests'
      last_response.should_not be_ok
      last_response.body.should eq 'A JSON text must at least contain two octets!'
    end
  end

end