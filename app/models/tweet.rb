class Tweet
  include MongoMapper::Document
  
  key :raw_tweet, Hash
  key :score, Integer
  
end