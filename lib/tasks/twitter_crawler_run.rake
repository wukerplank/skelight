namespace :twitter do
  
  namespace :crawler do
    
    desc "Connect to the Twitter firehose and put the tweets into the database"
    task :run => :environment do
      
      TwitterCrawler.run
      
    end
    
  end
  
end