# Taming Big Data with ApacheSpark and Python


### Estimate Pi ###

  # setup
import random
NUM_SAMPLES = 5000000

  # parallelize
samplerdd = spark.sparkContext.parallelize(range(0,NUM_SAMPLES)) 

  # define inside function
def inside(p):
    x, y = random.random(), random.random()
    return x*x + y*y < 1


  # pi sample
insiderdd = samplerdd.filter(inside)

  # see first 5 values
insiderdd.take(5)
count = insiderdd.count()
print("Pi is roughly %f" % (4.0 * count / NUM_SAMPLES))