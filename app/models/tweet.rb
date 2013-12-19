class Tweet
  include MongoMapper::Document
  
  key :raw_tweet, Hash
  
  def lat_lang
    
  end
end