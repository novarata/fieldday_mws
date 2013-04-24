require 'spec_helper'
include MwsHelpers

# Test client library to FielddayMws service
describe FielddayMws::Client do

  describe "fetching orders for a time period" do

    it "should work with valid inputs" do
      store = stub_mws_request
      p = CONNECTION_PARAMS.merge({ 
        'orders_uri' => TEST_ORDERS_URI, 
        'api_request_id' => API_REQUEST_ID,
        'time_from' => Time.now - 1.hour,
        'time_to' => Time.now,
      })
      stub_request(:post, p['orders_uri']).with(body:{order:FIXTURE_ORDER1}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      stub_request(:post, p['orders_uri']).with(body:{order:FIXTURE_ORDER2}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      response = FielddayMws::Client.fetch_orders(p)
      WebMock.should have_requested(:post, p['orders_uri']).twice    
    end
    
    it "should fail with missing amazon credentials" do
      expect { FielddayMws::Client.fetch_orders({ 'time_from' => Time.now - 1.hour, 'time_to' => Time.now }) }.to raise_error
    end
    
    it "should fail with missing time from" do
      p = CONNECTION_PARAMS.merge({ 'orders_uri' => TEST_ORDERS_URI, 'api_request_id' => API_REQUEST_ID })
      expect { FielddayMws::Client.fetch_orders(p) }.to raise_error
    end
    
  end 

  describe "fetching a specific order" do

    it "should fetch a specific order" do
      store = stub_order_response
      p = CONNECTION_PARAMS.merge({ 
        'orders_uri' => TEST_ORDERS_URI, 
        'api_request_id' => API_REQUEST_ID,
        'amazon_order_id' => FielddayMws::Client::STUBBED_ORDER_ID,
      })
      stub_request(:post, p['orders_uri']).with(body:{order:FIXTURE_ORDER1}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      response = FielddayMws::Client.fetch_order(p)
      WebMock.should have_requested(:post, p['orders_uri']).once
    end

    it "should fail with missing amazon credentials" do
      expect { FielddayMws::Client.fetch_order({ amazon_order_id:FielddayMws::Client::STUBBED_ORDER_ID}) }.to raise_error
    end
    
    it "should fail with missing amazon order id" do
      p = CONNECTION_PARAMS.merge({ 'orders_uri' => TEST_ORDERS_URI, 'api_request_id' => API_REQUEST_ID })
      expect { FielddayMws::Client.fetch_order(p) }.to raise_error
    end

  end

end