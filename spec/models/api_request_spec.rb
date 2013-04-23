require 'spec_helper'
include MwsHelpers

describe FielddayMws::ApiRequest do

  before :each do
    @r = stub_api_request
    @c = @r.mws_connection
  end

  describe "fetching a specified order" do

    it "should fetch order from params" do
      FielddayMws::ApiRequest.any_instance.should_receive(:fetch_order).once      
      FielddayMws::ApiRequest.fetch_order(@r.params)
    end

    it "should fetch order" do
      @c.should_receive(:get_orders).once
      @r.should_receive(:process_orders).once
      @r.fetch_order(FielddayMws::Client::STUBBED_ORDER_ID)
    end

  end

  describe "fetching orders" do
    
    it "should fetch orders from params" do
      FielddayMws::ApiRequest.any_instance.should_receive(:fetch_orders).once      
      FielddayMws::ApiRequest.fetch_orders(@r.params)
    end
    
    it "should fetch orders with from date and to date" do
      @c.should_receive(:list_orders).once
      @r.should_receive(:process_orders).once
      @r.fetch_orders(Time.now - 1.week, Time.now)
    end

    it "should fetch orders with only a from date" do
      @c.should_receive(:list_orders).once
      @r.should_receive(:process_orders).once
      @r.fetch_orders(Time.now - 1.week)
    end

    it "should raise an exception if no dates are given" do
      @c.should_receive(:list_orders).exactly(0).times
      expect { @r.fetch_orders(nil) }.to raise_exception
    end
  end
    

  describe "check errors" do    
    it "should raise an exception when there is an error" do
      mws_response = stub_list_orders_with_error(@c)
      expect {
        @r.check_errors(mws_response)
      }.to raise_exception(FielddayMws::AmazonError)
    end
  end
    
  describe "process orders" do

    it "should process orders with next token" do
      mws_response = stub_list_orders(@c)      
      mws_response2 = stub_list_orders_next_token(@c)
      mws_response2.stub(:next_token).and_return(nil)
      @r.should_receive(:process_order).exactly(mws_response.orders.count + mws_response2.orders.count).times
      @r.should_receive(:check_errors).twice # we are making a subsequent request, so we have to check
      @r.process_orders(mws_response)
    end
    
    it "should process orders without next token" do
      mws_response = stub_list_orders(@c)
      mws_response.stub(:next_token).and_return(nil)
      @r.stub(:process_order).and_return({})
      @r.should_receive(:process_order).exactly(mws_response.orders.count).times
      @r.mws_connection.should_not_receive(:list_orders_by_next_token)
      @r.should_receive(:check_errors).once
      @r.process_orders(mws_response)
    end

    # without actually going into logic to fetch individual items
    # test that this method results in an HTTP request to the orders_uri callback
    it "should process order" do
      mws_order = stub_list_orders(@c).orders.first
      FielddayMws::ApiRequest.any_instance.stub(:fetch_items).and_return([FIXTURE_ITEM, FIXTURE_ITEM2])
      stub_request(:post, @r.params['orders_uri']).with(body:{order:FIXTURE_ORDER1}.to_json).to_return(status:[200, "OK"], body:ORDER_RESPONSE)
      @r.process_order(mws_order)
      WebMock.should have_requested(:post, @r.params['orders_uri']).once
    end

  end
  
  describe "fetching items" do
    
    it "should fetch items" do
      mws_response = stub_list_order_items(@c)
      Amazon::MWS::Base.any_instance.should_receive(:list_order_items).once
      @r.should_receive(:process_items).once
      @r.fetch_items(FielddayMws::Client::STUBBED_ORDER_ID)
    end

    it "should process items with next token" do
      mws_response = stub_list_order_items(@c)      
      mws_response2 = stub_list_order_items_next_token(@c)
      #mws_response2.stub(:next_token).and_return(nil)
      @r.should_receive(:process_item).exactly(mws_response.order_items.count + mws_response2.order_items.count).times
      @r.should_receive(:check_errors).twice
      @r.process_items(mws_response)
    end
  
    it "should process items without next token" do
      mws_response = stub_list_order_items(@c)
      mws_response.stub(:next_token).and_return(nil)
      @r.stub(:process_item).and_return({})
      @r.should_receive(:process_item).exactly(mws_response.order_items.count).times
      @r.mws_connection.should_not_receive(:list_order_items_by_next_token)
      @r.should_receive(:check_errors).once
      @r.process_items(mws_response)
    end
  
    it "should process item" do
      mws_item = stub_list_order_items(@c).order_items.first
      hash = @r.process_item(mws_item,  FIXTURE_ITEM[:foreign_order_id])
      hash.should eq FIXTURE_ITEM
    end

  end
  
  it "should init mws connection" do
    r = stub_api_request
    r.mws_connection.should be_a Amazon::MWS::Base
  end

end