class Tweet
  include MongoMapper::Document
  
  key :raw_tweet, Hash
  
  # ======================================================================================================
  def self.count_tweets_map
    <<-MAP
      function() {
        emit('count', 1);
      }
    MAP
  end
  
  def self.count_tweets_reduce
    <<-REDUCE
      function(key, values) {
        var count = 0;
        
        // print("values for key '"+key+"': ", values.length);
        
        values.forEach(function(v) {
          count += v;
        });
        
        // print("count: ", count);
        
        return count;
      }
    REDUCE
  end
  
  def self.count_with_map_reduce
    r = self.collection.map_reduce(count_tweets_map, count_tweets_reduce, {out: 'map_tweets_count'}).find
    r = r.first
    return r['value']['count']
  end
  def lat_lang
    
  end
end