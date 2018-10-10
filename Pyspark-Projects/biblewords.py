# Modify the program to eliminate all the chapter and verse numbers from your counts and 
# eliminate punctuation so that “light” and “light:” and “light,” all count as occurrences 
# of the word “light”. Next, delete all the stop-words (the, in, of, etc). Lastly, sort your 
# output by the number of occurrences to show the words in order of most frequently used.

# Find working directory
# "~/Dropbox/Pythonwd"


# read in the lines
linesrdd = spark.sparkContext.textFile('bible.txt')
# check lines
linesrdd.first()
# Import regex and nltk
import re
# import nltk
# nltk.download("stopwords")
# create a word and number cleaning function

def wordclean(x):
  return re.sub("[^a-zA-Z0-9\s]+","", x).lower().strip()


def numclean(x):
  return re.sub('[0-9]+','', x)


# clean the bible
clean1rdd = linesrdd.map(lambda x : wordclean(x))
cleanrdd = clean1rdd.map(lambda x : numclean(x))


# split the words by spaces
wordsrdd = cleanrdd.flatMap(lambda l: l.split(' '))
# confirm
wordsrdd.sample(withReplacement = False, fraction = 0.0002, seed = 80).collect()

# mapreduce wordsrdd
wcountlistrdd = wordsrdd.map(lambda w: (w,1)).reduceByKey(lambda x,y: x+y)

# remove stopwords and blank list items
# from nltk.corpus import stopwords as sw
# stopwords = sw.words('english')
# keyvrdd = wcountlistrdd.filter(lambda x : x[0] not in stopwords)
kkrdd = wcountlistrdd.filter(lambda x : x[0] not in '')

# sort the RDD descending
finalrdd = kkrdd.sortBy(lambda a: a[1], ascending = False)
finalrdd.take(20) # only the first 20


