# encoding: UTF-8
require 'spec_helper'

require_relative "../lib/fieldday_mws.rb"

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
end