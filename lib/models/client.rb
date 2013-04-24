module FielddayMws
  class Client

    # get orders from Amazon storefront between two times
    def self.fetch_orders(params)
      FielddayMws::Client.fetch("#{FielddayMws::App.base_uri}/v1/orders_requests", params)
    end

    # get orders from Amazon storefront between two times
    def self.fetch_order(params)
      FielddayMws::Client.fetch("#{FielddayMws::App.base_uri}/v1/order_requests", params)
    end  



    # TEST STUBBING

    STUBBED_ORDER_ID = '134-5622222326-223434325'
    MWS_GET_ORDER = /mws.amazonservices.com\/Orders\/.*Action=GetOrder.*#{STUBBED_ORDER_ID}/
    MWS_LIST_ORDERS = /mws.amazonservices.com\/Orders\/.*Action=ListOrders/
    MWS_LIST_ORDERS_NEXT_TOKEN = /mws.amazonservices.com\/Orders.*Action=ListOrdersByNextToken.*NextToken=2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=/
    MWS_LIST_ORDER_ITEMS = /mws.amazonservices.com\/Orders\/.*Action=ListOrderItems.*AmazonOrderId=058-1233752-8214740/
    MWS_LIST_ORDER_ITEMS_B = /mws.amazonservices.com\/Orders\/.*Action=ListOrderItems.*AmazonOrderId=134-5622222326-223434325/
    MWS_LIST_ORDER_ITEMS_NEXT_TOKEN = /mws.amazonservices.com\/Orders\/.*Action=ListOrderItemsByNextToken.*NextToken=2YgYW55IGNhcm99999999Vhc3VyZS4=/
    MWS_LIST_ORDER_ITEMS_NEXT_TOKEN_B = /mws.amazonservices.com\/Orders\/.*Action=ListOrderItemsByNextToken.*NextToken=2YgYW55IGNhcm99999999Vhc3VyZS4b=/
  
    def self.stub_all
      stub_mws_xml(:post, MWS_GET_ORDER, 'get_order')
      stub_mws_xml(:post, MWS_LIST_ORDERS, 'list_orders')
      stub_mws_xml(:post, MWS_LIST_ORDERS_NEXT_TOKEN, 'list_orders_by_next_token')
      stub_mws_xml(:post, MWS_LIST_ORDER_ITEMS, 'list_order_items')
      stub_mws_xml(:post, MWS_LIST_ORDER_ITEMS_B, 'list_order_items_b') # Distinct order items for the second order
      stub_mws_xml(:post, MWS_LIST_ORDER_ITEMS_NEXT_TOKEN, 'list_order_items_by_next_token') # Distinct order items for second page of first order
      stub_mws_xml(:post, MWS_LIST_ORDER_ITEMS_NEXT_TOKEN_B, 'list_order_items_by_next_token_b') # Distinct order items for second page of second order
      return STUBBED_ORDER_ID
    end

    protected
    
    def self.fetch(uri, params)
      begin
        response = RestClient.post uri, params.to_json
      rescue RestClient::InternalServerError => e
        return e.message
      end
      return response.body      
    end

    def self.xml_body(name)
      File.open(Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("../spec/fixtures/xml/#{name}.xml"),'rb').read
    end

    def self.stub_mws_xml(method, regexp, xml_file, code=200)
      stub_request(method, regexp).to_return(:body => xml_body(xml_file), :status => code,  :headers => { 'Content-Type' => 'text/xml' } )
    end

  end
end