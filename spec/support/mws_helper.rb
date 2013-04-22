#encoding:UTF-8

module MwsHelpers
  include Amazon::MWS

  TEST_ORDERS_URI = "http://www.testing.com/orders"
  ORDER_RESPONSE = {order:{id:1}}.to_json
  ORDER_ITEM_RESPONSE = {order_item:{id:1}}.to_json

  FIXTURE_ITEM = {
    asin: "B034534547IMY", 
    seller_sku: "024345345651", 
    title: "Wilson Basketball", 
    quantity_ordered: 1, 
    quantity_shipped: 0, 
    item_price: 57.07, 
    item_price_currency: "USD", 
    shipping_price: 0.0, 
    shipping_price_currency: "USD", 
    gift_price: 0.0, 
    gift_price_currency: "USD", 
    item_tax: 0.0, 
    item_tax_currency: "USD", 
    shipping_tax: 0.0, 
    shipping_tax_currency: "USD", 
    gift_tax: 0.0, 
    gift_tax_currency: "USD", 
    shipping_discount: 0.0, 
    shipping_discount_currency: "USD", 
    promotion_discount: 0.0, 
    promotion_discount_currency: "USD", 
    gift_wrap_level: nil, 
    gift_message_text: nil, 
    foreign_order_item_id: "4067343455435394", 
    foreign_order_id: "058-1233752-8214740"
  }
  FIXTURE_ITEM2 = FIXTURE_ITEM.merge({foreign_order_item_id:'406733453459999999'})
  
  FIXTURE_ORDER1 = {
    :purchase_date => "2010-10-05T00:06:07+00:00",
    :last_update_date=>"2010-10-05T12:43:16+00:00", 
    :order_status=>"Unshipped", 
    :fulfillment_channel=>"MFN", 
    :sales_channel=>"Checkout by Amazon", 
    :order_channel=>nil, 
    :ship_service_level=>"Std DE Dom", 
    :amount=>4.78, 
    :currency_code=>"USD", 
    :name=>"John Smith", 
    :address_line_1=>"2700 First Avenue", 
    :address_line_2=>nil, 
    :address_line_3=>nil, 
    :city=>"Seattle", 
    :county=>nil, 
    :district=>nil, 
    :state_or_region=>"WA", 
    :postal_code=>"98102", 
    :country_code=>nil, 
    :phone=>nil, 
    :number_of_items_shipped=>0, 
    :number_of_items_unshipped=>1, 
    :marketplace_id=>"ATVPDKIKX0DER", 
    :buyer_name=>"Amazon User", 
    :buyer_email=>"5vlh04mgfmjh9h5@marketplace.amazon.com", 
    :shipment_service_level_category=>nil, 
    :foreign_order_id=>"058-1233752-8214740",
    :order_items_attributes=>[FIXTURE_ITEM, FIXTURE_ITEM2]
  }

  FIXTURE_ORDER2 = {
    :purchase_date=>"2012-04-18T04:07:38+00:00", 
    :last_update_date=>"2012-04-18T04:37:56+00:00", 
    :order_status=>"Unshipped", 
    :fulfillment_channel=>"MFN", 
    :sales_channel=>"Amazon.com", 
    :order_channel=>nil, 
    :ship_service_level=>"Std Cont US Street Addr", 
    :amount=>57.07,
    :currency_code=>"USD", 
    :name=>"Mike Smith", 
    :address_line_1=>"781 2nd Ave", 
    :address_line_2=>nil, 
    :address_line_3=>nil, 
    :city=>"New York", 
    :county=>nil, 
    :district=>nil, 
    :state_or_region=>"NEW YORK", 
    :postal_code=>"11222", 
    :country_code=>"US", 
    :phone=>"30553423431", 
    :number_of_items_shipped=>0,
    :number_of_items_unshipped=>1,
    :marketplace_id=>"ATVPDKIKX0DER", 
    :buyer_name=>"John Smith", 
    :buyer_email=>"8v234234324234tyxv8@marketplace.amazon.com", 
    :shipment_service_level_category=>"Standard", 
    :foreign_order_id=>"134-5622222326-223434325", 
    :order_items_attributes=>[FIXTURE_ITEM, FIXTURE_ITEM2]
  }

  CONNECTION_PARAMS = {
    'access_key' => 'DUMMY',
    'secret_access_key' => 'DUMMY',
    'merchant_id' => 'DUMMY',
    'marketplace_id' => 'ATVPDKIKX0DER',    
  }

  def xml_for(name, code)
    file = File.open(Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("fixtures/xml/#{name}.xml"),'rb')
    mock_response(code, {:content_type=>'text/xml', :body=>file.read})
  end

  def mock_response(code, options={})
    body = options[:body]
    content_type = options[:content_type]
    response = Net::HTTPResponse.send(:response_class, code.to_s).new("1.0", code.to_s, "message")
    response.instance_variable_set(:@body, body)
    response.instance_variable_set(:@read, true)
    response.content_type = content_type
    return response
  end

  def stub_api_request
    r = FielddayMws::ApiRequest.new
    r.params = CONNECTION_PARAMS.merge({
      'orders_uri' => TEST_ORDERS_URI,
      'time_from' => Time.now-1.hour
    })
  
    c = r.init_mws_connection
    c.stub(:post).and_return(xml_for('submit_feed',200))
    c.stub(:get).and_return(xml_for('get_feed_submission_list',200))
    c.stub(:get_feed_submission_result).and_return(GetFeedSubmissionResultResponse.format(xml_for('get_feed_submission_result',200)))    
    return r
  end

  def stub_mws_connection
    stub_api_request.mws_connection 
  end

  def stub_mws_request
    r = stub_api_request
    #c = s.mws_connection
    stub_orders_response(r.mws_connection)
    #stub_products_response(r.mws_connection)
    return r
  end

=begin
  def stub_products_response(c)
    c.stub(:post).and_return(xml_for('submit_feed',200))
    submit_feed_response = c.submit_feed(FielddayMws::ApiRequest::FEED_STEPS[0].to_sym, FielddayMws::ApiRequest::FEED_MSGS[0], [{}])
    submit_feed_response.should be_a SubmitFeedResponse
    Amazon::MWS::Base.any_instance.stub(:submit_feed).and_return(submit_feed_response)

    c.stub(:get).and_return(xml_for('get_feed_submission_list',200))
    feed_list_response = c.get_feed_submission_list({})
    feed_list_response.should be_a GetFeedSubmissionListResponse
    Amazon::MWS::Base.any_instance.stub(:get_feed_submission_list).and_return(feed_list_response)

    c.stub(:get).and_return(xml_for('get_feed_submission_result',200))
    feed_result_response = c.get_feed_submission_result('23423423432')
    feed_result_response.should be_a GetFeedSubmissionResultResponse
    Amazon::MWS::Base.any_instance.stub(:get_feed_submission_result).and_return(feed_result_response)
  end
=end

  # Stub response for a specific order (with no next page)
  def stub_order_response
    r = stub_mws_request
    c = r.init_mws_connection
    orders_response = stub_get_orders(c)
    orders_response.stub(:next_token).and_return(nil) # Pretend there was no next token
    return r
  end


  def stub_orders_response(c)
    stub_list_orders(c)
    stub_list_orders_next_token(c)
    stub_list_order_items(c)
    stub_list_order_items_next_token(c)
  end

  def stub_get_orders(c)
    c.stub(:post).and_return(xml_for('list_orders',200))
    orders_response = c.get_orders({:amazon_order_id => ['058-1233752-8214740']})
    orders_response.should be_a RequestOrdersResponse
    Amazon::MWS::Base.any_instance.stub(:get_orders).and_return(orders_response)
    return orders_response
  end

  def stub_list_orders(c)
    c.stub(:post).and_return(xml_for('list_orders',200))
    orders_response = c.list_orders(
      :last_updated_after => Time.now.iso8601,
      :results_per_page => 100,
      :fulfillment_channel => FielddayMws::ApiRequest::FULFILLMENT_CHANNELS,
      :order_status => ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"],
      :marketplace_id => ['ATVPDKIKX0DER']
    )
    orders_response.should be_a RequestOrdersResponse
    Amazon::MWS::Base.any_instance.stub(:list_orders).and_return(orders_response)
    return orders_response
  end

  def stub_list_orders_next_token(c)
    c.stub(:post).and_return(xml_for('list_orders_by_next_token',200))
    orders_response2 = c.list_orders_by_next_token(:next_token => '2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=')
    orders_response2.should be_a RequestOrdersByNextTokenResponse
    Amazon::MWS::Base.any_instance.stub(:list_orders_by_next_token).and_return(orders_response2)
    return orders_response2
  end

  def stub_list_order_items(c)
    c.stub(:post).and_return(xml_for('list_order_items',200))
    items_response = c.list_order_items(:foreign_order_id => '134-562342326-223434325')
    items_response.should be_a RequestOrderItemsResponse
    Amazon::MWS::Base.any_instance.stub(:list_order_items).and_return(items_response)
    return items_response
  end

  def stub_list_order_items_next_token(c)
    c.stub(:post).and_return(xml_for('list_order_items_by_next_token',200))
    items_response2 = c.list_order_items_by_next_token(:next_token => '2YgYW55IGNhcm99999999Vhc3VyZS4=')
    items_response2.should be_a RequestOrderItemsByNextTokenResponse
    Amazon::MWS::Base.any_instance.stub(:list_order_items_by_next_token).and_return(items_response2)
    return items_response2  
  end

  def stub_list_orders_with_error(c)
    c.stub(:post).and_return(xml_for('error',500))
    error_response = c.list_orders(
      :last_updated_after => Time.now.iso8601,
      :marketplace_id => ['ATVPDKIKX0DER']
    )
    error_response.should be_a ResponseError
    return error_response
  end


end