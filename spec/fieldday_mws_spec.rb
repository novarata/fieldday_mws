# encoding: UTF-8
require 'spec_helper'

require_relative "../lib/fieldday_mws.rb"
require_relative "../lib/models/store.rb"

describe "FielddayMws" do
  
  def app
    @app ||= FielddayMws
  end

  describe "GET '/'" do
    it "should be successful" do
      Store.create(:name=>'Blah')
      get '/'
      last_response.should be_ok
    end
  end
  
  describe "POST '/v1/order_requests" do
    it "should get name" do
      s = Store.create(:name=>'Blah')
      json = { :format => 'json', :order_request => { :store_id => s.id, :time_from=>Time.now-1.week, :time_to=>Time.now } }
      post '/v1/order_requests', json
      last_response.should be_ok
    end
    
  end

end