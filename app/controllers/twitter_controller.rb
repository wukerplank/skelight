class TwitterController < ApplicationController
  
  include ActionController::Live
  
  def stream
    headers['Content-Type'] = 'text/event-stream'
    @tsg = TwitterStreamGenerator.new response.stream
    client.filter(language: 'en', locations: '-180,-90,180,90') do |tweet|
      # Tweet Doku: http://rdoc.info/gems/twitter/Twitter/Tweet
      # https://dev.twitter.com/docs/platform-objects/tweets
      next if tweet.deleted===true
      
      @tsg.write tweet.attrs, event: 'new_tweet'
    end
  rescue IOError
  ensure
    @tsg.close
  end
  
private
  def client
    @client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end
end
