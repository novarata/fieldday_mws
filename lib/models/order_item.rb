module FielddayMws
  class OrderItem

    PERMITTED_FIELDS = [:asin, :seller_sku, :title, :quantity_ordered, :quantity_shipped, 
    :item_price, :item_price_currency, :shipping_price, :shipping_price_currency, :gift_price, :gift_price_currency, 
    :item_tax, :item_tax_currency, :shipping_tax, :shipping_tax_currency, :gift_tax, :gift_tax_currency,
    :shipping_discount, :shipping_discount_currency, :promotion_discount, :promotion_discount_currency,
    :gift_wrap_level, :gift_message_text]

    # Take an amazon format order item object and some additional information and construct a hash suitable for POSTing
    def self.build_hash(mws_item, amazon_order_id)
      mws_item.as_hash.select{ |k,v| PERMITTED_FIELDS.include?(k)}.merge({
        foreign_order_item_id:  mws_item.amazon_order_item_id,
        seller_sku:             mws_item.seller_sku,
        foreign_order_id:       amazon_order_id,
      })
    end

  end
end