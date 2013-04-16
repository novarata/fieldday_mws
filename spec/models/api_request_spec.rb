require 'spec_helper'

describe ApiRequest do

  it "get_sleep_time_per_order should work" do
    ApiRequest.get_sleep_time_per_order("text").should be 0
    ApiRequest.get_sleep_time_per_order(-1).should be 0
    ApiRequest.get_sleep_time_per_order(0).should be 0
    ApiRequest.get_sleep_time_per_order(1).should be 0
    ApiRequest.get_sleep_time_per_order(15).should be 0
    ApiRequest.get_sleep_time_per_order(16).should be > 0
    ApiRequest.get_sleep_time_per_order(50.5).should be > 0
    ApiRequest.get_sleep_time_per_order(10000).should be <= 6
  end

  #it "self get_feed_wait" do
  #  ApiRequest.get_feed_wait(2500).should eq 106 # 1 product and subvariant, 1.5 mins
  #  ApiRequest.get_feed_wait(25000).should eq 175 #  10 products and subvariants, 3 mins
  #  ApiRequest.get_feed_wait(250000).should eq 349 # 100 products and subvariants, 6 mins
  #  ApiRequest.get_feed_wait(2500000).should eq 785 # 1000 products and subvariants, 13 mins
  #  ApiRequest.get_feed_wait(25000000).should eq 1881 # 10000 products and subvariants, 31 mins
  #end

end