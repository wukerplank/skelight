class TwitterCrawler
  
  def self.run
    logger = Logger.new(STDOUT)
    
    logger.info "Connecting to firehose..."
    fire_hose = TwitterFirehose.new
    last_log_time = Time.now
    last_log_tweet_count = 0
    
    logger.info "Starting run..."
    
    fire_hose.run do |tweet|
      
      Tweet.create(raw_tweet: tweet.attrs)
      
      # let's have some metrics ---------------------------------------------------
      last_log_tweet_count += 1
      time_delta = Time.now - last_log_time
      if time_delta > 5
        logger.info "Going at #{"%.02f" % (last_log_tweet_count / time_delta)} tweets/sec"
        
        last_log_time = Time.now
        last_log_tweet_count = 0
      end
    end
  end
  
end
