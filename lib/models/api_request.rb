class ApiRequest < ActiveRecord::Base

  LIST_ORDERS_MWS = "ListOrders"
  LIST_ORDER_ITEMS_MWS = "ListOrderItems"
  
  LIST_ORDER_ITEMS_REQUEST_QUOTA = 15.0
  LIST_ORDER_ITEMS_RESTORE_RATE = 6.0
  MAX_FAILURE_COUNT = 2
  ORDER_FAIL_WAIT = 60
  FULLY_COMPLETED = 'fully_completed'
  STATUS_DONE = '_DONE_'
  ASIN_ISSUE_MESSAGE_CODE = '8541'

  FEED_POLL_WAIT = 3.minutes
  FEED_INCOMPLETE_WAIT = 1.minute

  FEED_STEPS = %w( product_data product_relationship_data product_pricing product_image_data inventory_availability )
  FEED_MSGS = %w( Product Relationship Price ProductImage Inventory )
  
  belongs_to :store
  belongs_to :parent_request, :class_name => "ApiRequest", :foreign_key => "api_request_id"

  #has_many :orders, -> { order 'orders.purchase_date DESC' }, through: :api_responses
  #has_many :order_items, through: :api_responses
  #has_many :sub_requests, class_name:"ApiRequest", dependent: :destroy
  #has_many :api_responses, dependent: :destroy

  delegate :store_type, to: :store  
  
  # return a value between 0 and 6 for the number of seconds to delay between OrderItem requests to Amazon
  def self.get_sleep_time_per_order(order_count)
    return ((([order_count - LIST_ORDER_ITEMS_REQUEST_QUOTA, 0.0].max) / order_count)*LIST_ORDER_ITEMS_RESTORE_RATE).ceil if (order_count.is_a?(Numeric) && order_count>0)
    return 0
  end      
  
  # accepts a working MWS connection and a ListOrdersResponse, and fully processes these orders
  # calls the Amazon MWS API
  def process_orders(mws_connection, response)
    #puts "  PROCESS_ORDERS: response type #{response.class.to_s}, request type #{self.request_type}"
    next_token = process_response(mws_connection, response,0,0)
    return next_token if next_token.is_a?(Numeric)

    page_num = 1
    failure_count = 0
    while next_token.is_a?(String) && page_num<self.store.max_order_pages do
      #puts "  PROCESS_ORDERS: back, next_token present, getting orders list by next token"
      response = mws_connection.get_orders_list_by_next_token(:next_token => next_token)
      #puts "  PROCESS_ORDERS: got orders by next token, going to process_response"
      n = process_response(mws_connection,response,page_num,ORDER_FAIL_WAIT)
      if n.is_a?(Numeric)
        failure_count += 1
        if failure_count >= MAX_FAILURE_COUNT
          return n
        end
      else
        page_num += 1
        next_token = n
      end
    end
    return true
    #puts "  PROCESS_ORDERS: finishing"
  end

  # accepts a working MWS connection and the XML model of the response, and incorporates this information into the database
  # calls process_order or process_order_item in turn, which call the Amazon MWS API
  def process_response(mws_connection,response_xml,page_num,sleep_if_error)

    #puts "PROCESS_RESPONSE: request_type is #{self.request_type}"
    # Update the request_id in our request parent object if not set already
    self.update_attributes!(:foreign_request_id=>response_xml.request_id) if self.foreign_request_id.nil?

    # Create a new response object, link to the initial request
    response = ApiResponse.new(
      :request_type => self.request_type,
      :api_request_id => self.id,
      :foreign_request_id => response_xml.request_id,
      :page_num => page_num
    )

    # If there is an error code, save the error in the record, sleep for some time to recover, and return the response id, indicating error
    if response_xml.accessors.include?("code")
      #puts "PROCESS_RESPONSE: error code #{response_xml.message}"
      response.update_attributes!(:error_code => response_xml.code, :error_message => response_xml.message)
      #sleep sleep_if_error
      return response.id
    end
    #puts "no error code"

    # assign next token if given
    response.next_token = response_xml.next_token

    # if this is a response containing orders
    if self.request_type==::ApiRequest::LIST_ORDERS_MWS
      response.last_updated_before = response_xml.last_updated_before
      response.save!

      #puts "    PROCESS_RESPONSE: ListOrders response contains #{response_xml.orders.count} orders"

      # Process all orders first
      amazon_orders = Array.new
      response_xml.orders.each do |o|
        amz_order = ::Order.find_by_foreign_order_id(o.amazon_order_id)
        if amz_order.nil?
          amz_order = ::Order.create(:foreign_order_id => o.amazon_order_id, :api_response_id=>response.id, :store_id=>self.store_id, :purchase_date=>o.purchase_date, :order_channel=>self.store.omx_keycode)
          #puts "      PROCESS_RESPONSE: new order #{amz_order.foreign_order_id} created, id:#{amz_order.id}, adding to array"
        else
          #puts "      PROCESS_RESPONSE: existing order #{amz_order.foreign_order_id} being updated, id:#{amz_order.id}, adding to array"
        end
        h = o.as_hash
        h[:api_response_id] = response.id #TODO creating an orphan api_response object by changing the response pointer

        amz_order.update_attributes( h.select{|k,v| Order::PERMITTED_ORDER_FIELDS.include?(k) })

        amazon_orders << amz_order
        #puts "      PROCESS_RESPONSE: now #{amazon_orders.count} orders in array"
      end

      #puts "    PROCESS_RESPONSE: done building array, #{amazon_orders.count} orders"
      # Then get item detail behind each order
      sleep_time = ::ApiRequest.get_sleep_time_per_order(amazon_orders.count)
      amazon_orders.each_with_index do |amz_order,i|
        ProcessOrderWorker.perform_at((sleep_time*i).seconds.from_now, amz_order.id)
      end
      self.update_attributes(:processing_status=>"Complete")

    # else if this is a response containing items
    elsif self.request_type=="ListOrderItems"
      response.foreign_order_id = response_xml.amazon_order_id
      response.save!

      #puts "            PROCESS_RESPONSE: ListOrderItems response contains #{response_xml.order_items.count} items"

      amz_order = ::Order.find_by_foreign_order_id(response.foreign_order_id)
      if !amz_order.nil?
        response_xml.order_items.each do |i|
          #puts "            PROCESS_RESPONSE: going to process item"
          amz_order.process_order_item(i,response.id)
        end
        #puts "            PROCESS_RESPONSE: finished processing #{response_xml.order_items.count} items"
        self.update_attributes(:processing_status=>'Complete')
      else
        self.update_attributes(:processing_status=>"Couldn't find #{response.foreign_order_id}")
      end
    end
    #puts "PROCESS_RESPONSE: finished, returning next token or error code"
    return response.next_token
  end

=begin

  def handle_error_response(response)
    #puts "** HANDLE ERROR RESPONSE **"
    raise 'Unknown Amazon Response' unless response.is_a? Amazon::MWS::ResponseError

    #puts "  #{response.code}, #{response.message}, #{response.detail}"
    ApiResponse.create(
      :request_type => self.request_type,
      :api_request_id => self.id,
      :error_code => response.code,
      :error_message => [response.type, response.message, response.detail].compact.join(','),
      :processing_status => 'Error')
  end    

  # Parent request
  def submit_mws_feed(store, chain=true)
    #puts "*** BEGIN SUBMIT MWS FEED ***"
    #puts "#{self.feed_type}, #{self.message_type}, #{self.message}"
    store.init_store_connection
    response = store.mws_connection.submit_feed(self.feed_type.to_sym,self.message_type,self.message)
    return self.handle_error_response(response) if !response.is_a? Amazon::MWS::SubmitFeedResponse

    r = ApiResponse.create(
      :request_type => self.request_type,
      :api_request_id => self.id,
      :foreign_request_id => response.request_id,
      :feed_submission_id => response.feed_submission.id,
      :processing_status => response.feed_submission.feed_processing_status)
    #puts "  SUBMIT_MWS_FEED response="+r.inspect

    # But also save it in the request for easy access to current information
    self.update_attributes!(:feed_submission_id => r.feed_submission_id, :processing_status => r.processing_status)

    # Schedule job for get_mws_feed_status in x.minutes if this is the product feed.  Otherwise, don't because the product feed will schedule it.
    FeedWorker.perform_in(self.get_feed_wait, 'get_mws_feed_status', self.id) if chain && self.feed_type==FEED_STEPS[0]
    return r
  end

  # return a list of feed submission ids for those requests that are not fully completed
  # only called on parent request
  def get_feed_submission_id_list
    id_list = {}
    requests = self.sub_requests.order('id ASC').to_a
    requests.unshift self
    i = 1
    requests.each do |r|
      if r.processing_status != FULLY_COMPLETED && !r.feed_submission_id.nil?
        id_list["FeedSubmissionIdList.Id.#{i}"] = r.feed_submission_id
        i += 1
      end
    end
    return id_list
  end

  # Child request, STATUS, only called on parent request
  def get_mws_feed_status(store, chain=true)
    #puts "<<<< BEGIN GET_MWS_FEED_STATUS >>>>"
    store.init_store_connection
    # Get the list of ids that are not yet fully complete
    feed_submission_id_list = self.get_feed_submission_id_list
    #puts "  Feed submission id list: #{feed_submission_id_list.inspect}"

    # create a child request for this feed submission list request
    child_request = ::ApiRequest.create(:store_id=>store.id, :request_type=>'GetFeedSubmissionList', :api_request_id=>self.id)
    response = store.mws_connection.get_feed_submission_list(feed_submission_id_list)
    return self.handle_error_response(response) unless response.is_a? Amazon::MWS::GetFeedSubmissionListResponse

    # create a response for this request
    r = ::ApiResponse.create(
      :request_type => child_request.request_type,
      :api_request_id => child_request.id,
      :foreign_request_id => response.request_id,
      :processing_status => "Found #{response.feed_submissions.length} submissions")
    #puts "  Response is #{r.inspect}"

    # for each feed_submission in the result, determine if it is complete, and if so, schedule a fetch of the result
    num_incomplete = 0
    #puts "  Found #{response.feed_submissions.length} feed submissions, going through each:"
    response.feed_submissions.each do |fs|

      # find the request with this feed_submission_id
      req = ::ApiRequest.find_by_feed_submission_id(fs.id)
      #puts "    Original request for submission #{fs.id} was #{req.inspect}"
      unless req.nil?

        req.update_attributes!(
          :processing_status => fs.feed_processing_status,
          :submitted_at => fs.submitted_date,
          :started_at => fs.started_processing_date,
          :completed_at => fs.completed_processing_date
          )

        # if this feed is now done, then schedule getting the result, otherwise note we need to do another call to this method
        if fs.feed_processing_status == STATUS_DONE
          #puts "    DONE: feed_processing_status is #{fs.feed_processing_status}, scheduling get feed result"
          FeedWorker.perform_async('get_mws_feed_result', req.id) if chain
        else
          #puts "    INCOMPLETE: feed_processing_status is #{fs.feed_processing_status}, num incomplete now #{num_incomplete}"
          num_incomplete += 1
        end
      else
        #puts "  ERROR: could not find original request"
      end
    end

    # if any feeds are still incomplete, schedule a follow up to check on them again
    if num_incomplete>0
      feed_wait = self.get_feed_wait
      #puts "  There are #{num_incomplete} incomplete feeds, getting feed status again in #{feed_wait}"
      child_request.update_attributes(:processing_status=>"#{num_incomplete} incomplete feeds")
      FeedWorker.perform_in(self.get_feed_wait, 'get_mws_feed_status', self.id)
    else
      child_request.update_attributes(:processing_status=>"All feeds complete")
    end

  end

  # Child request
  def get_mws_feed_result(store, chain=true)
    #puts "<<<<< BEGIN GET_MWS_FEED_RESULT >>>>>"
    store.init_store_connection
    #puts "init store connection"

    # Create a request for the feed result and send this request
    #puts "create request - mws_feed_result"
    child_request = ::ApiRequest.create(:store_id=>store.id, :request_type=>'GetFeedSubmissionResult', :api_request_id=>self.id)

    #puts "added child_request"
    response = store.mws_connection.get_feed_submission_result(self.feed_submission_id)
    #puts "got feed submission result"
    return self.handle_error_response(response) unless response.is_a? Amazon::MWS::GetFeedSubmissionResultResponse
    #puts "no error"

    # Save key response elements
    r = ::ApiResponse.create(
      :request_type => child_request.request_type,
      :api_request_id => child_request.id,
      :processing_status => response.message.status_code)
    #puts "  GET_MWS_FEED_RESULT response is #{r.inspect}"
    self.update_attributes!(:processing_status => FULLY_COMPLETED) #response.message.status_code)
    child_request.update_attributes(:processing_status=>"Results received")

    #puts "  MESSAGES: #{response.message.processing_summary.messages_successful} successful, #{response.message.results.count} error"
    #puts "  MESSAGE DETAIL: #{response.to_xml.to_s}"
    #puts "  Going through each message now:"

    # Go through each of the messages in the response body and save the details
    response.message.results.each do |mr|
      #puts "    RESULT: Message #{mr.message_id}, #{mr.result_code}: #{mr.message_code}.  #{mr.description}"
      #puts "    FULL DETAIL: #{mr.to_xml.to_s}"

      m = nil
      begin
        m = ::ApiMessage.find(mr.message_id)
        #puts "    Found and updated message #{mr.message_id} appropriately"
      rescue ActiveRecord::RecordNotFound # Dealing with situations where Amazon returns message id of 1
        m = self.api_messages.first if self.api_messages.length>0
        #puts "    Couldn't find message, so updating the first message"
      end
      return if m.nil?

      description = nil
      if m.result_description.blank?
        description = mr.description
      elsif mr.description.present?
        description = [m.result_description.strip,mr.description.strip].join('\n')
      end
      m.update_attributes(:result_code => mr.result_code, :message_code => mr.message_code, :result_description => description)
      m.find_asin_and_resubmit if mr.message_code.to_s == ASIN_ISSUE_MESSAGE_CODE
    end

    # If we are on the product feed, the parent request, and chaining, then schedule the subsequent feeds
    if self.feed_type == FEED_STEPS[0] && self.api_request_id.nil?
      #puts "  Feed type is #{self.feed_type} and this is the parent request so scheduling subsequent feeds"
      self.schedule_subsequent_feeds(store) if chain && self.any_update_listings?

      #puts "  Scheduling done, now collecting my listings to update status"
      self.listings.collect { |l| l.update_status! }
    elsif !self.parent_request.nil?
      #puts "  Not doing the scheduling, now collecting my listings to update status"
      # Update all the listings to the latest status
      self.parent_request.listings.collect { |l| l.update_status! }
    end
    #puts "  Done, returning r"
    # return the response
    return r
  end

  def any_update_listings?
    self.listings.where(:operation_type=>'Update').any?
  end

  # Check that this is the product feed, and if so, submit next feed for the 4 dependent feeds
  # Only call this if chaining
  def schedule_subsequent_feeds(store)
    #puts "<<<<<< SCHEDULE SUBSEQUENT FEEDS >>>>>>"
    #puts self.inspect
    step = 1
    while step<FEED_STEPS.length
      self.submit_next_feed(store, step)
      step += 1
    end

    #feed_wait = self.get_feed_wait
    #puts "  Feed wait is #{feed_wait}, would have been #{FEED_POLL_WAIT}"
    FeedWorker.perform_in(self.get_feed_wait, 'get_mws_feed_status', self.id)
  end

  # Accepts a step number between 1 and FEED_STEPS.length, and builds the messages for this step and then submits
  # Only call this if chaining
  def submit_next_feed(store, step)
    #puts "<<<<<<< SUBMIT NEXT FEED FOR STEP: #{step} >>>>>>>"
    return nil if step>=FEED_STEPS.length

    pre_existing_count = self.sub_requests.where(:request_type=>SUBMIT_MWS, :feed_type=>FEED_STEPS[step]).count
    #puts "pre existing count is #{pre_existing_count}"
    return unless pre_existing_count==0

    #puts "create request - submit_next_feed"
    child_request = ::ApiRequest.create!(:store_id=>store.id, :request_type=>SUBMIT_MWS, :api_request_id=>self.id,
      :feed_type=>FEED_STEPS[step], :message_type=>FEED_MSGS[step])

    # Build messages for the next batch
    m = self.listings.collect { |l| l.build_api_messages(child_request) }.flatten

    # If no messages have come through for this step, proceed to the next step.  Happens when a feed is 100% delete, has no images, etc.
    if m.empty?
      child_request.destroy # destroy the request because we never make it, the messages are actually empty
      #puts "  There are no messages, skipping step #{step}"
      return nil
    else
      child_request.update_attributes(:message => m) # Otherwise, if messages have come through, send the child request
      #puts "  There are messages, going ahead with submit_mws_feed for step #{step}"
      FeedWorker.perform_async(::ApiRequest::SUBMIT_MWS, child_request.id)
    end
  end

  def get_feed_length
    self.message.present? ? self.message.join.length : 0
  end

  def get_feed_wait
    self.class.get_feed_wait(self.get_feed_length)
  end

  def self.get_feed_wait(feed_length); ((feed_length**(2/5.0) + 30)*2).ceil.seconds end
=end
  
end