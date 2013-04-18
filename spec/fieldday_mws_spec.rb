# encoding: UTF-8
require 'spec_helper'
include MwsHelpers

require_relative "../lib/fieldday_mws.rb"
require_relative "../lib/models/store.rb"

describe "FielddayMws" do
  
  def app
    @app ||= FielddayMws
  end

  describe "GET '/'" do
    it "should be successful" do
      Store.create(:name=>'Blah')
      get '/'
      last_response.should be_ok
    end
  end
  
  describe "POST '/v1/orders_requests" do
    it "should successfully fetch multiple orders with valid inputs" do

      s = stub_mws_response

      FIXTURE_ORDERS.each do |o|
        stub_request(:post, FielddayMws.create_order_url).with(body:o).to_return(status:[200, "OK"], body:{order_id:1})
      end

      FIXTURE_ITEMS.each do |oi|
        stub_request(:post, FielddayMws.create_order_item_url).with(body:oi).to_return(status:[200, "OK"], body:{order_item_id:1})
      end

      expect {
        expect {
          post '/v1/orders_requests', { store_id:s.id, time_from:Time.now-1.hour, time_to:Time.now }
        }.to change(ApiRequest, :count).by(6)
      }.to change(ApiResponse, :count).by(6)

      FIXTURE_ORDERS.each do |o|
        WebMock.should have_requested(:post, FielddayMws.create_order_url).with(body: o).once      
      end

      FIXTURE_ITEMS.each do |oi|
        WebMock.should have_requested(:post, FielddayMws.create_order_item_url).with(body: oi).once      
      end
    end
    
    it "should error on invalid input" do
      post '/v1/orders_requests'
      last_response.should_not be_ok
    end
  end

  describe "POST '/v1/order_items_requests" do
    it "should successfully fetch items for a single order with valid inputs" do
      s = stub_mws_response
      stub_request(:post, FielddayMws.create_order_item_url).to_return(status:[200, "OK"], body:{order_item_id:1})
      
      expect {
        expect {
          post '/v1/order_items_requests', { store_id:s.id, order_id:1, amazon_order_id:1 }
        }.to change(ApiRequest, :count).by(2)
      }.to change(ApiResponse, :count).by(2)

      WebMock.should have_requested(:post, FielddayMws.create_order_item_url).twice
      WebMock.should_not have_requested(:post, FielddayMws.create_order_url)

      # Confirm request tree
      r = ApiRequest.first
      r.child_requests.count.should eq 1
      r.api_responses.count.should eq 1
      r.child_requests.first.api_responses.count.should eq 1      
    end
    
    it "should error on invalid input" do
      post '/v1/order_items_requests'
      last_response.should_not be_ok
    end
  end

end