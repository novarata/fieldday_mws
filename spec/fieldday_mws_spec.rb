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
      get '/'
      last_response.should be_ok
    end
  end
  
  describe "POST '/v1/order_requests" do
    it "should get name" do
      json = { :format => 'json', :order_request => { :name => "Jonathan" } }
      post '/v1/order_requests', json
      last_response.should be_ok
      puts last_response.body
    end
    
  end
  
  
  
  
end