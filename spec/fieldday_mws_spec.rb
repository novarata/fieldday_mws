# encoding: UTF-8
require 'spec_helper'
include MwsHelpers

require_relative "../lib/fieldday_mws.rb"
require_relative "../lib/models/store.rb"

describe "FielddayMws" do

  #describe "GET '/'" do
  #  it "should be successful" do
  #    Store.create(:name=>'Blah')
  #    get '/'
  #    last_response.should be_ok
  #  end
  #end
  
  describe "POST '/v1/orders_requests" do
    it "should successfully fetch multiple orders with valid inputs" do

      r = stub_mws_request

      FIXTURE_ORDERS.each do |o|
        stub_request(:post, r.params['orders_uri']).with(body:o).to_return(status:[200, "OK"], body:{order_id:1})
      end

      FIXTURE_ITEMS.each do |oi|
        stub_request(:post, r.params['order_items_uri']).with(body:oi).to_return(status:[200, "OK"], body:{order_item_id:1})
      end

      expect {
        expect {
          post '/v1/orders_requests', r.params
        }.to change(ApiRequest, :count).by(6)
      }.to change(ApiResponse, :count).by(6)

      FIXTURE_ORDERS.each do |o|
        WebMock.should have_requested(:post, r.params['orders_uri']).with(body: o).once      
      end

      FIXTURE_ITEMS.each do |oi|
        WebMock.should have_requested(:post, r.params['order_items_uri']).with(body: oi).once      
      end
    end
    
    it "should error on invalid input" do
      post '/v1/orders_requests'
      last_response.should_not be_ok
    end
  end

  describe "POST '/v1/order_items_requests" do
    it "should successfully fetch items for a single order with valid inputs" do
      r = stub_mws_request
      stub_request(:post, r.params['order_items_uri']).to_return(status:[200, "OK"], body:{order_item_id:1})
      
      expect {
        expect {
          post '/v1/order_items_requests', r.params.merge({ 'order_id' => 1, 'amazon_order_id' => 1 })
        }.to change(ApiRequest, :count).by(2)
      }.to change(ApiResponse, :count).by(2)

      WebMock.should have_requested(:post, r.params['order_items_uri']).twice
      WebMock.should_not have_requested(:post, r.params['orders_uri'])

      # Confirm request tree
      r = ApiRequest.order(:id).last
      r.child_requests.count.should eq 0
      r.api_responses.count.should eq 1
      r.parent_request.should_not be_nil
      r.parent_request.api_responses.count.should eq 1
    end
    
    it "should error on invalid input" do
      post '/v1/order_items_requests'
      last_response.should_not be_ok
    end
  end

end