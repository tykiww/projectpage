

# PYTHON SCRIPT.


# It seems that the largest difference between the Full-Factorial and latin hypercube is 
# the discrete vs continuous nature between the two. The Full-Factorial design may take 
# a discrete set of values in a given range, and create a cartesian product of three ranges.
# However, the LHS design takes n independent distributions and samples from each in a more
# continuous manner.

# Below is the implementation of both experimental designs
python
# python packages
from pyDOE import lhs
import numpy as np
from itertools import product
from math import acos, degrees



amps = np.linspace(-10,10.,20) # 
phirange = np.linspace(0,360,40) # 40
thetrange = []
for theta in np.linspace(1,0,9): # 20
  thetrange.append(degrees(acos(theta)))

thetrange
ffd = list(product(amps,phirange,thetrange))
len(ffd)


# The merit in doing the cartesian product is its ease.
# Because the distribution of theta is to be sampled using
# cosine angles from 0 to 90, it can be done simply by applying
# a function to the ranges. However, noise will need to be added
# to produce a more "continuous" feel. This can be done below:


amps = np.random.uniform(-10,10,18).tolist()
amps.sort() ; amps.insert(0,-10.) ; amps.append(10.) # 20

phirange = np.random.uniform(0,360,38).tolist()
phirange.sort() ; phirange.insert(0,0.) ; phirange.append(360.) # 40

thetrange = [0]
for theta in np.linspace(1,0,28): # 30
  thetrange.append(abs(np.random.normal(degrees(acos(theta)))))

thetrange.append(90.)


ffd = list(product(amps,phirange,thetrange))
len(ffd)





# Here is the latin hypercube design. It is fairly straightforward
# and is as easy as the cartesian product. By generating three
# discrete parameters that are uniformly distributed from 0 to 1, 
# we are able to produce a random set of numbers that follow
# any set of distributions.


cube = lhs(13,3) 

# theta 25
thetrange = [degrees(acos(i)) for i in cube[0,]] 
thetrange += np.linspace(0,90,12).tolist() # 115
thetrange.sort() # we were not sure if point values were necessary, so we included them in the data.
len(thetrange) # made it huge.
# phi 55
phirange = np.random.uniform(0,360,len(cube[0,])).tolist()  # inserted 1/3 of point values
phirange += np.linspace(0,360,42).tolist() 
phirange.sort()
len(phirange)
# amps 15
amps = np.random.uniform(-10,10,len(cube[0,])).tolist() # inserted 1/3 of point values 
amps += np.linspace(-10,10,2).tolist() # Do we need to add point values?
amps.sort()
len(amps)

lhd = list(product(amps,phirange,thetrange))
len(lhd) # 17576 = 25 X 55 X 15 after playing around with dimensions


# using ray tracing takes a while to load.




############################### OVERALL METHOD USED ################################

# Cartesian Product after adding noise.
from pyDOE import lhs
import numpy as np
from itertools import product
from math import acos, degrees


amps = np.random.uniform(-10,10,18).tolist()
amps.sort() ; amps.insert(0,-10.) ; amps.append(10.) # 20

phirange = np.random.uniform(0,360,38).tolist()
phirange.sort() ; phirange.insert(0,0.) ; phirange.append(360.) # 40

thetrange = [0]
for theta in np.linspace(1,0,28): # 30
  thetrange.append(abs(np.random.normal(degrees(acos(theta)))))

thetrange.append(90.)


ffd = list(product(amps,phirange,thetrange)) # 24000


half = ffd[0:12000]
quart = ffd[0:6000]
eighth = ffd[0:3000]
sixteenth = ffd[0:1500]

# Write the file as filename, specify directory.
open('full_params_parallel.txt', 'w').write('\n'.join('%s %s %s' % x for x in ffd))
open('half_params_parallel.txt', 'w').write('\n'.join('%s %s %s' % x for x in half))
open('quarter_params_parallel.txt', 'w').write('\n'.join('%s %s %s' % x for x in quart))
open('eighth_params_parallel.txt', 'w').write('\n'.join('%s %s %s' % x for x in eighth))
open('sixtnth_params_parallel.txt', 'w').write('\n'.join('%s %s %s' % x for x in sixteenth))


quit()
