namespace :subjectivity_lexicon do
  
  desc "Imports the subjectivity lexicon of the University of Pittsburg / Call: rake subjectivity_lexicon:import[path/to/file]"
  task :import, [:tff_file_name] => :environment do |t, args|
    args.with_defaults(tff_file_name: '')
    
    if File.exist? args[:tff_file_name]
      File.open(args[:tff_file_name], 'r') do |f| 
        f.each_line do |l|
          a = l.split(' ')
          w = SubjectiveWord.create({
            type:     a[0].split('=').last,
            len:      a[1].split('=').last,
            word:     a[2].split('=').last,
            pos:      a[3].split('=').last,
            stemmed:  a[4].split('=').last,
            polarity: a[5].split('=').last
          })
        end
      end
    else
      puts "\nNo filename given! Be sure to call this script with an argument, e.g.:\nrake subjectivity_lexicon:import[path/to/file]\n\n"
    end
  end
  
end