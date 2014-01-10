Skelight
========

Count the tweets
----------------

    use skelight_development;
    
    // the map function -------------------------------------------------------------------
    var map = function() {
      emit('count', 1);
    }
    
    // the reduce function ----------------------------------------------------------------
    var reduce = function(key, values) {
      var count = 0;
      
      // print("values for key '"+key+"': ", values.length);
      
      values.forEach(function(v) {
        count += v;
      });
      
      // print("count: ", count);
      
      return count;
    }
    
    // run the job ------------------------------------------------------------------------
    db.tweets.mapReduce(
      map,
      reduce,
      {
        out: "tweets_count"
      }
    )

Normalize the weets
--------------------

    use skelight_development;
    
    var escapeRegex = function(str) {
      return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
    }
    
    // build the slangword Map ------------------------------------------------------------
    var slangWordMap = {};
    db.slang_words.find().forEach(function(sw, i){
      var regex = new RegExp("\\b"+escapeRegex(sw.slang.toString())+"\\b", "img");
      slangWordMap[regex] = sw.word;
    });
    
    // the map function -------------------------------------------------------------------
    var map = function() {
      emit(this._id, {tweet: this.raw_tweet.text});
    }
    
    // the reduce function ----------------------------------------------------------------
    var reduce = function() {
      // won't be called
    }
    
    // the finalize function --------------------------------------------------------------
    var finalize = function(key, values) {
      tweet = values['tweet'];
      
      for(var regex in slangWordMap) {
        tweet = tweet.replace(regex, slangWordMap[regex]);
      }
      
      return {tweet_id: key, tweet: tweet};
    }
    
    // run the job ------------------------------------------------------------------------
    db.tweets.mapReduce(
      map,
      reduce,
      {
        scope: {
          slangWordMap: slangWordMap
        },
        out: "normalized_tweets", 
        finalize: finalize
      }
    )

Calculating the sentiment of the tweets
---------------------------------------

    use skelight_development;
    
    // build the score Map ----------------------------------------------------------------
    var sentimentMap = {};
    db.subjective_words.find().forEach(function(sw, i){
      if (sw.polarity=='positive') {
        sentimentMap[sw.word] = 1;
      }
      else if (sw.polarity=='negative') {
        sentimentMap[sw.word] = -1;
      }
      else {
        // skip neutral words
      }
    });
    
    // build the emoticon Map -------------------------------------------------------------
    //   -> emoticons take from http://en.wikipedia.org/wiki/List_of_emoticons
    var emoticonMap = {};
    ":-) :) :o) :] :3 :c) :> =] 8) =) :} :^) :っ) :-D :D 8-D 8D x-D xD X-D XD =-D =D =-3 =3 B^D :-)) :'-) :') :* :^* ( '}{' ) ;-) ;) *-) *) ;-] ;] ;D ;^) :-, >:P :-P :P X-P x-p xp XP :-p :p =p :-Þ :Þ :þ :-þ :-b :b o/\o ^5 >_>^ ^<_< \o/ <3".split(' ').forEach(function(e){
      emoticonMap[e] = 1;
    });
    ">:[ :-( :(  :-c :c :-<  :っC :< :-[ :[ :{ ;( :-|| :@ >:( :'-( :'( D:< D: D8 D; D= DX v.v D-': >:) >;) >:-) ಠ_ಠ </3".split(' ').forEach(function(e){
      emoticonMap[e] = -1;
    });
    
    // the map function -------------------------------------------------------------------
    var map = function() {
      words = this.value.tweet.split(/[\b\s]+/)
      
      emit(this._id, words);
    }
    
    // the reduce function ----------------------------------------------------------------
    var reduce = function() {
      // won't be called
    }
    
    // the finalize function --------------------------------------------------------------
    var finalize = function(key, words) {
      var score = 0;
      
      words.forEach(function(word, i){
        if (sentimentMap[word]!=undefined) {
          score += sentimentMap[word];
        }
        else if (emoticonMap[word]!=undefined) {
          score += emoticonMap[word];
        }
      })
      
      return {tweet_id: key, score: score};
    }
    
    // run the job ------------------------------------------------------------------------
    db.normalized_tweets.mapReduce(
      map,
      reduce,
      {
        scope: {
          sentimentMap: sentimentMap,
          emoticonMap: emoticonMap
        },
        out: "scored_tweets", 
        finalize: finalize
      }
    )
    
    // save the computed scores back to the original tweets -------------------------------
    db.scored_tweets.find().forEach(function(nt){
      db.tweets.update(
        {_id: nt.value.tweet_id},
        {'$set': {score: nt.value.score}}
      );
    });

Appendix
--------

**Slang Dictionary**

The provided `slangdict.csv` is separated with `;`, but `mongoimport` can only handle `,`. To fix this:

    mv slangdict.csv slangdict_old.csv
    cat slangdict_old.csv | sed 's/;/,/g' > slangdict.csv
    
Now we can do the import the import:
    
    mongoimport --db skelight_development --collection slang_words --type csv --fields slang,word < slangdict.csv

**Subjective Lexicon**

The lexicon is downloadable at http://mpqa.cs.pitt.edu/lexicons/subj_lexicon/

It is in a very odd format, so I wrote a custom importer. It can be executed like this:

    bundle exec rake subjectivity_lexicon:import[/path/to/the/lexicon.tff]

The code of this rake task is in `lib/tasks/subjectivity_lexicon_import