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
  
  # ======================================================================================================
  def self.map_tweet_words
    <<-MAP
      function() {
        // print(" -- this -- " + JSON.stringify(this));
        
        var words = this.raw_tweet.text.split(/\s+/);
        
        for(var i=0; i<words.length; i++) {
          // emit({tweet_id: this._id, word: words[i]}, {words: words});
          emit(this._id, {words: words});
        }
      }
    MAP
  end
  
  def self.reduce_normalized_tweets
    <<-REDUCE
      function(key, values) {
        var slangWords = #{SlangWord.all.to_json};
        
        // print("values for key '" + JSON.stringify(key) + "': " + values.length);
        
        var words = values[0]['words'];
        
        // print("XXXXXXXXX -------> " + JSON.stringify(words));
        
        for (var i=0; i<words.length; i++) {
          slangWords.forEach(function(slangWord){
            if (words[i].toLowerCase()==slangWord.slang.toLowerCase()) {
              print(" replace! " + slangWord.slang + " -> " + slangWord.word);
              words[i] = slangWord.word;
            }
          });
        }
        // print("normalized -------> " + JSON.stringify(words));
        
        return {tweet_id: key, words: words};
      }
    REDUCE
  end
  
  def self.normalize_tweets
    r = self.collection.map_reduce(map_tweet_words, reduce_normalized_tweets, {out: 'normalized_tweets'}).find
    return r
  end
  
  # ======================================================================================================
  
  def lat_lang
    
  end
end