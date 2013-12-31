class NormalizedTweet
  include MongoMapper::Document
  
  key :text, String
  key :original_tweet_id, String
  
end