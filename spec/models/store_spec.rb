require 'spec_helper'
include MwsHelpers

describe Store do

  it "store should have an mws_connection" do
    s = stub_mws_store
    s.init_store_connection
    s.mws_connection.should be_a Amazon::MWS::Base
  end
    
end