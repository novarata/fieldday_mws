#encoding:UTF-8
include Amazon::MWS

module MwsHelpers

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
    c.stub(:post).and_return(xml_for('list_orders',200))
    orders_response = c.get_orders_list(
      :last_updated_after => Time.now.iso8601,
      :results_per_page => 100,
      :fulfillment_channel => Store::FULFILLMENT_CHANNELS,
      :order_status => ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"],
      :marketplace_id => ['ATVPDKIKX0DER']
    )
    orders_response.should be_a RequestOrdersResponse
    Amazon::MWS::Base.any_instance.stub(:get_orders_list).and_return(orders_response)

    c.stub(:post).and_return(xml_for('list_order_items',200))
    items_response = c.get_list_order_items(:foreign_order_id => '134-562342326-223434325')
    items_response.should be_a RequestOrderItemsResponse
    Amazon::MWS::Base.any_instance.stub(:get_list_order_items).and_return(items_response)

    c.stub(:post).and_return(xml_for('list_order_items_by_next_token',200))
    items_response2 = c.get_list_order_items_by_next_token(:next_token => '2YgYW55IGNhcm99999999Vhc3VyZS4=')
    items_response2.should be_a RequestOrderItemsByNextTokenResponse
    Amazon::MWS::Base.any_instance.stub(:get_list_order_items_by_next_token).and_return(items_response2)    

    c.stub(:post).and_return(xml_for('list_orders_by_next_token',200))
    orders_response2 = c.get_orders_list_by_next_token(:next_token => '2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=')
    orders_response2.should be_a RequestOrdersByNextTokenResponse
    Amazon::MWS::Base.any_instance.stub(:get_orders_list_by_next_token).and_return(orders_response2)    
  end

end