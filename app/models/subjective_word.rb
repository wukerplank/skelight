class SubjectiveWord
  include MongoMapper::Document
  
  key :type, String
  key :len, Integer
  key :word, String
  key :pos, String
  key :stemmed, String
  key :polarity, String
  
end