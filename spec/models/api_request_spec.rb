require 'spec_helper'
include MwsHelpers

describe ApiRequest do

  before :each do
    @r = ApiRequest.create!(request_type:ApiRequest::LIST_ORDERS, store_id:1)
    @c = stub_mws_connection
  end

  describe "fetching orders" do
  
    describe "via date range" do
      
      before :each do
        mws_response = stub_list_orders(@c)
        @r.stub(:fetch_orders_next_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
        @r.stub(:process_orders_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
      end
      
      it "should fetch orders with from date and to date" do
        @c.should_receive(:list_orders).once
        @r.should_receive(:fetch_orders_next_page).once
        @r.should_receive(:process_orders_page).once
        @r.fetch_orders(Time.now - 1.week, Time.now)
      end

      it "should fetch orders with only a from date" do
        @c.should_receive(:list_orders).once
        @r.should_receive(:fetch_orders_next_page).once
        @r.should_receive(:process_orders_page).once
        @r.fetch_orders(Time.now - 1.week)
      end
      
      it "should raise an exception if no dates are given" do
        @c.should_receive(:list_orders).exactly(0).times
        @r.should_receive(:fetch_orders_next_page).exactly(0).times
        @r.should_receive(:process_orders_page).exactly(0).times
        expect { @r.fetch_orders(nil) }.to raise_exception
      end
    
    end
    
    describe "via next token" do

      it "should fetch orders next page" do
        mws_response = stub_list_orders_next_token(@c)
        Amazon::MWS::Base.any_instance.should_receive(:list_orders_by_next_token).once
        ApiRequest.any_instance.stub(:process_orders_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
        ApiRequest.any_instance.should_receive(:process_orders_page).once
        @r.fetch_orders_next_page('next token')
      end

      it "should fetch orders next page when there is no next token" do
        @r.should_receive(:process_orders_page).exactly(0).times
        @r.fetch_orders_next_page(nil)
      end

    end

    describe "create api response" do
      context "no errors" do

        it "should return a response with orders" do
          mws_response = stub_list_orders(@c)
          expect { 
            @r.create_api_response(mws_response, {last_updated_before: Time.now}).should be_an ApiResponse
          }.to change(ApiResponse, :count).by(1)
        end

        it "should return a response with items" do
          mws_response = stub_list_order_items(@c)
          expect {
            @r.create_api_response(mws_response, {foreign_order_id:mws_response.amazon_order_id}).should be_an ApiResponse
          }.to change(ApiResponse, :count).by(1)
        end
      end
      
      context "with errors" do
        it "should raise an exception" do
          mws_response = stub_list_orders_with_error(@c)
          expect {
            @r.create_api_response(mws_response)
          }.to raise_exception(AmazonError)
        end
      end
    end
  
    it "should process orders page" do
      response = double ApiResponse
      response.stub(:id).and_return(1)
      @r.stub(:create_api_response).and_return(response)
      @r.should_receive(:create_api_response).once
      
      mws_response = stub_list_orders(@c)
      @r.stub(:process_order).and_return(1)
      @r.should_receive(:process_order).exactly(mws_response.orders.count).times
      @r.process_orders_page(mws_response)
    end
  
    it "should process order" do
      mws_order = stub_list_orders(@c).orders.first
      ApiRequest.any_instance.stub(:fetch_items).and_return(nil)
      o = FIXTURE_ORDERS.first
      stub_request(:post, FielddayMws.create_order_url).with(body:o).to_return(status:[200, "OK"], body:{order_id:1})
      @r.process_order(mws_order, o['order']['api_response_id'])
      WebMock.should have_requested(:post, FielddayMws.create_order_url).with(body: o).once
    end
  
  end
  
  describe "fetching items" do
        
    it "should fetch items" do
      mws_response = stub_list_order_items(@c)
      Amazon::MWS::Base.any_instance.should_receive(:list_order_items).once

      ApiRequest.any_instance.stub(:fetch_items_next_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
      ApiRequest.any_instance.should_receive(:fetch_items_next_page).once

      ApiRequest.any_instance.stub(:process_items_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
      ApiRequest.any_instance.should_receive(:process_items_page).once

      @r.fetch_items(1, 1)
    end
  
    it "should fetch items next page when there is a next token" do
      mws_response = stub_list_order_items_next_token(@c)
      Amazon::MWS::Base.any_instance.should_receive(:list_order_items_by_next_token).once
      ApiRequest.any_instance.stub(:process_items_page).and_return(nil) # return nil for next token, otherwise it's an infinite loop
      ApiRequest.any_instance.should_receive(:process_items_page).once
      @r.fetch_items_next_page(1, 'next token')
    end

    it "should fetch items next page when there is no next token" do
      @r.should_receive(:process_items_page).exactly(0).times
      @r.fetch_items_next_page(1, nil)
    end
  
    it "should process items page" do
      response = double ApiResponse
      response.stub(:id).and_return(1)
      @r.stub(:create_api_response).and_return(response)
      @r.should_receive(:create_api_response).once

      mws_response = stub_list_order_items(@c)
      @r.stub(:process_item).and_return(1)
      @r.should_receive(:process_item).exactly(mws_response.order_items.count).times
      @r.process_items_page(1, mws_response)
    end
  
    it "should process item" do
      mws_item = stub_list_order_items(@c).order_items.first
      oi = FIXTURE_ITEMS.first
      stub_request(:post, FielddayMws.create_order_item_url).with(body:oi).to_return(status:[200, "OK"], body:{order_item_id:1})
      @r.process_item(mws_item, oi['order_item']['api_response_id'], 1, oi['order_item']['foreign_order_id'])
      WebMock.should have_requested(:post, FielddayMws.create_order_item_url).with(body: oi).once
    end

  end
  
  it "should init mws connection" do
    @r.mws_connection.should be_nil
    @r.init_mws_connection
    @r.mws_connection.should be_a Amazon::MWS::Base
  end
  
  it "should mark complete" do
    @r.mark_complete
    @r.reload.processing_status.should eq ApiRequest::COMPLETE_STATUS    
  end

end