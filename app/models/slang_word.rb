class SlangWord
  include MongoMapper::Document
  
  key :slang, String
  key :clean, String
  
  def self.words_map
    <<-MAP
      function() {
        emit(this.id, { slang: this.slang, clean: this.clean });
      }
    MAP
  end
  
end
