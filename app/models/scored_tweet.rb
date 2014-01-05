class ScoredTweet
  include MongoMapper::Document
  
  key :value, Hash
  
  def self.find_by_tweet_id(tweet_id)
    where({"value.tweet_id" => tweet_id}).all
  end
end