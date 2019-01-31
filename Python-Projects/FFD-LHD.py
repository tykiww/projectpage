

# PYTHON SCRIPT.


# It seems that the largest difference between the Full-Factorial and latin hypercube is 
# the discrete vs continuous nature between the two. The Full-Factorial design may take 
# a discrete set of values in a given range, and create a cartesian product of three ranges.
# However, the LHS design takes n independent distributions and samples from each in a more
# continuous manner.

# Below is the implementation of both experimental designs

# python packages
from pyDOE import lhs
import numpy as np
from itertools import product
from math import acos, degrees

amps = np.linspace(-10,10.,20) # 
phirange = np.linspace(0,360,40) # 40
thetrange = []
for theta in np.linspace(1,0,20): # 20
  thetrange.append(degrees(acos(theta)))

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
for theta in np.linspace(1,0,18): # 20
  thetrange.append(abs(np.random.normal(degrees(acos(theta)))))

thetrange.append(90.)

ffd = list(product(amps,phirange,thetrange))
len(ffd)


# Here is the latin hypercube design. It is fairly straightforward
# and is as easy as the cartesian product. By generating three
# discrete parameters that are uniformly distributed from 0 to 1, 
# we are able to produce a random set of numbers that follow
# any set of distributions.


cube = lhs(5-,3) # 26 x 26 x 26

thetrange = [degrees(acos(i)) for i in cube[0,]] # theta
thetrange.insert(0,0.0) ; thetrange.append(90.)
phirange = np.random.uniform(0,360,len(cube[0,])).tolist() # phi
phirange.insert(0,0.0) ; phirange.append(90.)
amps = np.random.uniform(-10,10,len(cube[0,])).tolist() # p
amps.insert(0,-10) ; amps.append(10.)

lhd = list(product(amps,phirange,thetrange))
len(lhd) # 17576





