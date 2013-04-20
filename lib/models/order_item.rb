class OrderItem

  PERMITTED_FIELDS = [:asin, :seller_sku, :title, :quantity_ordered, :quantity_shipped, 
  :item_price, :item_price_currency, :shipping_price, :shipping_price_currency, :gift_price, :gift_price_currency, 
  :item_tax, :item_tax_currency, :shipping_tax, :shipping_tax_currency, :gift_tax, :gift_tax_currency,
  :shipping_discount, :shipping_discount_currency, :promotion_discount, :promotion_discount_currency,
  :gift_wrap_level, :gift_message_text]

  # Send a POST HTTP request to create an order item
  def self.post_create(item_hash, order_items_uri)
    response = FielddayMws.post_callback(order_items_uri, {order_item:item_hash})
    return response[:order_item_id]
  end

  # Take an amazon format order item object and some additional information and construct a hash suitable for POSTing
  def self.build_hash(mws_item, response_id, order_id, amazon_order_id)
    mws_item.as_hash.select{ |k,v| PERMITTED_FIELDS.include?(k)}.merge({
      foreign_order_item_id:  mws_item.amazon_order_item_id,
      seller_sku:             mws_item.seller_sku,
      api_response_id:        response_id,
      order_id:               order_id,
      foreign_order_id:       amazon_order_id,
    })
  end

end