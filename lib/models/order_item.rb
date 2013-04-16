class OrderItem < ActiveRecord::Base

  PERMITTED_ITEM_ATTRS = [:asin, :seller_sku, :title, :quantity_ordered, :quantity_shipped, 
  :item_price, :item_price_currency, :shipping_price, :shipping_price_currency, :gift_price, :gift_price_currency, 
  :item_tax, :item_tax_currency, :shipping_tax, :shipping_tax_currency, :gift_tax, :gift_tax_currency,
  :shipping_discount, :shipping_discount_currency, :promotion_discount, :promotion_discount_currency,
  :gift_wrap_level, :gift_message_text]


end