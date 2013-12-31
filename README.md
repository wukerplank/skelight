Skelight
========

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