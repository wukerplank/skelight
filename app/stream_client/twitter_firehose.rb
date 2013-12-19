class TwitterFirehose
  
  def initialize(key=nil, secret=nil, token=nil, token_secret=nil)
    @client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = key          || ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = secret       || ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = token        || ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = token_secret || ENV['TWITTER_ACCESS_SECRET']
    end
  end
  
  def run(options={}, &block)
    @client.filter(language: 'en', locations: '-180,-90,180,90') do |tweet|
      # Tweet Doku: http://rdoc.info/gems/twitter/Twitter/Tweet
      # https://dev.twitter.com/docs/platform-objects/tweets
      
      yield tweet
    end
  end
end
