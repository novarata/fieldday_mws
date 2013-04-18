#encoding:UTF-8
include Amazon::MWS

module MwsHelpers

  FIXTURE_ORDERS = [
    {"order"=>{"purchase_date"=>"2010-10-05T00:06:07+00:00", "last_update_date"=>"2010-10-05T12:43:16+00:00", "order_status"=>"Unshipped", "fulfillment_channel"=>"MFN", "sales_channel"=>"Checkout by Amazon", "order_channel"=>"", "ship_service_level"=>"Std DE Dom", "amount"=>"4.78", "currency_code"=>"USD", "name"=>"John Smith", "address_line_1"=>"2700 First Avenue", "address_line_2"=>"", "address_line_3"=>"", "city"=>"Seattle", "county"=>"", "district"=>"", "state_or_region"=>"WA", "postal_code"=>"98102", "country_code"=>"", "phone"=>"", "number_of_items_shipped"=>"0", "number_of_items_unshipped"=>"1", "marketplace_id"=>"ATVPDKIKX0DER", "buyer_name"=>"Amazon User", "buyer_email"=>"5vlh04mgfmjh9h5@marketplace.amazon.com", "shipment_service_level_category"=>"", "foreign_order_id"=>"058-1233752-8214740", "api_response_id"=>"1", "store_id"=>"1"}},
    {"order"=>{"purchase_date"=>"2012-04-18T04:07:38+00:00", "last_update_date"=>"2012-04-18T04:37:56+00:00", "order_status"=>"Unshipped", "fulfillment_channel"=>"MFN", "sales_channel"=>"Amazon.com", "order_channel"=>"", "ship_service_level"=>"Std Cont US Street Addr", "amount"=>"57.07", "currency_code"=>"USD", "name"=>"Mike Smith", "address_line_1"=>"781 2nd Ave", "address_line_2"=>"", "address_line_3"=>"", "city"=>"New York", "county"=>"", "district"=>"", "state_or_region"=>"NEW YORK", "postal_code"=>"11222", "country_code"=>"US", "phone"=>"30553423431", "number_of_items_shipped"=>"0", "number_of_items_unshipped"=>"1", "marketplace_id"=>"ATVPDKIKX0DER", "buyer_name"=>"John Smith", "buyer_email"=>"8v234234324234tyxv8@marketplace.amazon.com", "shipment_service_level_category"=>"Standard", "foreign_order_id"=>"134-5622222326-223434325", "api_response_id"=>"4", "store_id"=>"1"}}
  ]

  FIXTURE_ITEMS = [
    {"order_item"=>{"asin"=>"B034534547IMY", "seller_sku"=>"024345345651", "title"=>"Wilson Basketball", "quantity_ordered"=>"1", "quantity_shipped"=>"0", "item_price"=>"57.07", "item_price_currency"=>"USD", "shipping_price"=>"0.0", "shipping_price_currency"=>"USD", "gift_price"=>"0.0", "gift_price_currency"=>"USD", "item_tax"=>"0.0", "item_tax_currency"=>"USD", "shipping_tax"=>"0.0", "shipping_tax_currency"=>"USD", "gift_tax"=>"0.0", "gift_tax_currency"=>"USD", "shipping_discount"=>"0.0", "shipping_discount_currency"=>"USD", "promotion_discount"=>"0.0", "promotion_discount_currency"=>"USD", "gift_wrap_level"=>"", "gift_message_text"=>"", "foreign_order_item_id"=>"4067343455435394", "api_response_id"=>"2", "order_id"=>"1", "foreign_order_id"=>"058-1233752-8214740"}},
    {"order_item"=>{"asin"=>"B034534547IMY", "seller_sku"=>"024345345651", "title"=>"Wilson Basketball", "quantity_ordered"=>"1", "quantity_shipped"=>"0", "item_price"=>"57.07", "item_price_currency"=>"USD", "shipping_price"=>"0.0", "shipping_price_currency"=>"USD", "gift_price"=>"0.0", "gift_price_currency"=>"USD", "item_tax"=>"0.0", "item_tax_currency"=>"USD", "shipping_tax"=>"0.0", "shipping_tax_currency"=>"USD", "gift_tax"=>"0.0", "gift_tax_currency"=>"USD", "shipping_discount"=>"0.0", "shipping_discount_currency"=>"USD", "promotion_discount"=>"0.0", "promotion_discount_currency"=>"USD", "gift_wrap_level"=>"", "gift_message_text"=>"", "foreign_order_item_id"=>"406733453459999999", "api_response_id"=>"3", "order_id"=>"1", "foreign_order_id"=>"058-1233752-8214740"}},
    {"order_item"=>{"asin"=>"B034534547IMY", "seller_sku"=>"024345345651", "title"=>"Wilson Basketball", "quantity_ordered"=>"1", "quantity_shipped"=>"0", "item_price"=>"57.07", "item_price_currency"=>"USD", "shipping_price"=>"0.0", "shipping_price_currency"=>"USD", "gift_price"=>"0.0", "gift_price_currency"=>"USD", "item_tax"=>"0.0", "item_tax_currency"=>"USD", "shipping_tax"=>"0.0", "shipping_tax_currency"=>"USD", "gift_tax"=>"0.0", "gift_tax_currency"=>"USD", "shipping_discount"=>"0.0", "shipping_discount_currency"=>"USD", "promotion_discount"=>"0.0", "promotion_discount_currency"=>"USD", "gift_wrap_level"=>"", "gift_message_text"=>"", "foreign_order_item_id"=>"4067343455435394", "api_response_id"=>"5", "order_id"=>"1", "foreign_order_id"=>"058-1233752-8214740"}},
    {"order_item"=>{"asin"=>"B034534547IMY", "seller_sku"=>"024345345651", "title"=>"Wilson Basketball", "quantity_ordered"=>"1", "quantity_shipped"=>"0", "item_price"=>"57.07", "item_price_currency"=>"USD", "shipping_price"=>"0.0", "shipping_price_currency"=>"USD", "gift_price"=>"0.0", "gift_price_currency"=>"USD", "item_tax"=>"0.0", "item_tax_currency"=>"USD", "shipping_tax"=>"0.0", "shipping_tax_currency"=>"USD", "gift_tax"=>"0.0", "gift_tax_currency"=>"USD", "shipping_discount"=>"0.0", "shipping_discount_currency"=>"USD", "promotion_discount"=>"0.0", "promotion_discount_currency"=>"USD", "gift_wrap_level"=>"", "gift_message_text"=>"", "foreign_order_item_id"=>"406733453459999999", "api_response_id"=>"6", "order_id"=>"1", "foreign_order_id"=>"058-1233752-8214740"}},
  ]

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

  def stub_mws_store
    s = Store.create(
      store_type: 'MWS',
      omx_store_code: 'Amazon.com MFN DUMMY',
      name: 'FieldDay-1',
      public_name: 'FieldDay-1',
      mws_access_key: 'DUMMY',
      mws_secret_access_key: 'DUMMY',
      mws_merchant_id: 'DUMMY',
      mws_marketplace_id: 'ATVPDKIKX0DER'
    )
    s.init_store_connection
    s.mws_connection.stub(:post).and_return(xml_for('submit_feed',200))
    s.mws_connection.stub(:get).and_return(xml_for('get_feed_submission_list',200))
    s.mws_connection.stub(:get_feed_submission_result).and_return(GetFeedSubmissionResultResponse.format(xml_for('get_feed_submission_result',200)))    
    c = s.mws_connection
    Store.any_instance.stub(:mws_connection).and_return(c)
    return s
  end

  def stub_mws_connection
    s = stub_mws_store
    c = s.mws_connection
    return c    
  end

  def stub_mws_response
    s = stub_mws_store
    c = s.mws_connection
    stub_orders_response(c)
    #stub_products_response(c)
    return s
  end

=begin
  def stub_products_response(c)
    c.stub(:post).and_return(xml_for('submit_feed',200))
    submit_feed_response = c.submit_feed(ApiRequest::FEED_STEPS[0].to_sym, ApiRequest::FEED_MSGS[0], [{}])
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

  def stub_orders_response(c)
    stub_list_orders(c)
    stub_list_orders_next_token(c)
    stub_list_order_items(c)
    stub_list_order_items_next_token(c)
  end

  def stub_list_orders(c)
    c.stub(:post).and_return(xml_for('list_orders',200))
    orders_response = c.list_orders(
      :last_updated_after => Time.now.iso8601,
      :results_per_page => 100,
      :fulfillment_channel => Store::FULFILLMENT_CHANNELS,
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