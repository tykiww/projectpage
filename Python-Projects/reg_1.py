# import packages

{
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import matplotlib.pylab as plt
import statsmodels.formula.api as smf
import statsmodels.api as sma
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LassoLarsCV
from statsmodels.stats.outliers_influence import variance_inflation_factor as vif
import statsmodels.formula.api as sm
from sklearn import preprocessing as prepro
import seaborn
import scipy
}

# Problem 1

{
  
# read height_weight1.csv data
heiwei = pd.read_csv("Linear Regression assignment 2/height_weight1.csv")

# check data
heiwei.head()
heiwei.dtypes
heiwei.columns

# check for NAs
sum(heiwei.height.isna())
sum(heiwei.weight.isna())

# exploratory data analysis 
# obtain summary statistics
# assess regression assumptions

heiwei.describe()

   ##            height      weight
   ## count  500.000000  500.000000
   ## mean    66.151400  164.996400
   ## std      4.878469   19.216684
   ## min     53.300000  107.300000
   ## 25%     62.900000  152.550000
   ## 50%     66.100000  163.900000
   ## 75%     69.400000  178.125000
   ## max     81.600000  242.300000
   

# check for normality by plotting

plt.hist(heiwei.height,50)
plt.hist(heiwei.weight,50)
plt.show() # Both Seem roughly normal, yet has varying spread.
plt.cla()


# split data into train and test

heiweiTrain, heiweiTest = train_test_split(heiwei, test_size=.25, random_state=15)
heiweiTrain.shape
heiweiTest.shape


# Fit a linear model to the height and weight data that includes an intercept. 

model = smf.ols(formula='height ~ 1 + weight', data=heiweiTrain).fit()
model.summary()


# Fit another model that does not include the intercept.

lm = smf.ols(formula='height ~ weight -1', data=heiweiTrain).fit()
lm.summary()

# In terms of our 3 residual assumptions, how do these two models compare? 
    # plot the residuals
plt.hist(model.resid, 50)
plt.hist(lm.resid, 50)
plt.show()
plt.cla()
# The residuals for both 

    # plot heteroscedasticity
plt.plot(model.predict(heiweiTrain), model.resid, '.')
plt.plot(model.predict(heiweiTrain), lm.resid, '.')
plt.show()
plt.cla()

        # We assume the residuals are normally distributed.
        # We assume that the errors are independent from each other.
        # Homoscedasticity of the errors.
    # We see in the residual histogram that both the errors are normally distributed.
    # however, we notice the error plot without the intercept showed heteroscedasticity 
    # and dependence. We see by leaving the intercept term, you ensure the residual term has a zero-mean.

# Can we use R2 or another metric to determine which fits the data better?

    # We cannot use R2 in this case. This is because, mathematically, our intercepts are zero
    # which leads to us using a reference model corresponding only to noise. We can, however
    # use the p-values, R2, and F statistic if the data has a relationship passing the origin.

}

# Problem 2

{

# Using the heigh_weight2.csv data, fit another linear model. This time, do not include an intercept. 

# import heigh_weight2.csv

heiwei2 = pd.read_csv("Linear Regression assignment 2/height_weight2.csv")

# check data
heiwei2.head()
heiwei2.dtypes
heiwei2.columns

# check for NAs
sum(heiwei2.height.isna())
sum(heiwei2.weight.isna())

# exploratory data analysis 
# obtain summary statistics
# assess regression assumptions

heiwei2.describe()

    ##            height      weight
    ## count  500.000000  500.000000
    ## mean    66.151400  165.640400
    ## std      4.878469   20.461088
    ## min     53.300000  121.900000
    ## 25%     62.900000  151.650000
    ## 50%     66.100000  162.800000
    ## 75%     69.400000  177.525000
    ## max     81.600000  239.100000

plt.hist(heiwei2.height,50)
plt.hist(heiwei2.weight,50)
plt.show() # Both Seem roughly normal, yet has varying spread.
plt.cla()

# split data into train and test

heiwei2Train, heiwei2Test = train_test_split(heiwei2, test_size=.25, random_state=15)
heiwei2Train.shape
heiwei2Test.shape

# fit another linear model. do not include an intercept. 

model2 = smf.ols(formula='height ~ weight -1', data=heiwei2Train).fit()
model2.summary()

# Does this model meet the assumptions of residuals? If not, explain why not. 

    # plot the residuals
plt.hist(model2.resid, 50)
plt.show() # The residuals seem normal.
plt.cla()

    # plot homoscedasticity and independence.
plt.plot(model2.predict(heiwei2Train), model2.resid, '.')
plt.show()
plt.cla()
model.predict(heiwei2Test,)
plt.plot(heiwei2.weight,heiwei2.height, '.')
plt.show()
plt.cla()
# This error histogram also shows a normal distribution, however the error plot indicates
# the presence of heteroscedasticity. We see further that the model is dependent of each other.

# Additionally, if one of the assumptions is not met, how do you think that impacts our prediction? 
# Does it impact our point prediction? What about our prediction interval?

## Violating the normality assumption assumes that we are predicting from a false distribution.
## If the tails of the data is large, then we will not have accurate predictions.

## If the independence assumption is not met, any observation in the data will influence or affect 
## the value of other observations.

##  Heteroscedasticity is the violation of the homoscedasticity assumption. When it occurs,
##  the OLS estimates of β are still unbiased (thus suggesting that the point estimates will
##  not change), but become inefficient. This inefficiency is characterized with a 
##  larger standard error. If the standard error is larger, the spread of our prediction 
##  intervals will increase as well. 

}

# Problem 3

# Age   --- age of the car (in years) 
# Make  --- the brand/make of a car (Toyota 1, Ford 2, or BMW 3) 
# Type  --- the type (1 for SUV, 2 for sedan, and 3 for convertible)
# Miles --- number of miles 
# Price --- price the car recently sold for

cardat = pd.read_csv("Linear Regression assignment 2/car.csv")



# check data
cardat.head()

# re-code Make as 1 toyota, 2 ford, 3 bmw
recode = {'Toyota' : 1 ,'Ford' : 2 ,'BMW' : 3}
cardat['Make'] = cardat.Make.map(recode)


emp = [] # Na values
names = list(cardat)
for i in names:
  print ( sum( cardat[i].isna() ) )

# exploratory data analysis 
# obtain summary statistics
# assess regression assumptions

cardat.describe()

    ##                Age         Make         Type         Miles          Price
    ## count  2500.000000  2500.000000  2500.000000   2500.000000    2500.000000
    ## mean      5.521600     1.976000     1.994800  50389.142000   17241.662044
    ## std       2.857411     0.710793     0.712584  28560.807428   23109.823412
    ## min       1.000000     1.000000     1.000000    530.000000     461.790000
    ## 25%       3.000000     1.000000     1.000000  25481.500000    4906.322500
    ## 50%       6.000000     2.000000     2.000000  50734.500000    9893.495000
    ## 75%       8.000000     2.000000     3.000000  74332.500000   20217.267500
    ## max      10.000000     3.000000     3.000000  99836.000000  259914.300000

fig, axes = plt.subplots(nrows=2, ncols=2)
axes[0,0].scatter(cardat.Age , cardat.Price)
axes[1,0].scatter(cardat.Make , cardat.Price)
axes[0,1].scatter(cardat.Type , cardat.Price)
axes[1,1].scatter(cardat.Miles , cardat.Price)
plt.show()


# separate into train and test variables.

cardatTrain, cardatTest = train_test_split(cardat, test_size=.25, random_state=15)
cardatTrain.shape
cardatTest.shape

# Check for collinearity.

corr_df = cardatTrain.corr(method = 'pearson')
mask = np.zeros_like(corr_df)
mask[np.triu_indices_from(mask)] = True

seaborn.heatmap(corr_df,cmap='RdYlGn_r', vmax = 1.0, vmin = -1.0, mask = mask, linewidths = 2.5)
plt.yticks(rotation = 0)
plt.xticks(rotation = 90)
plt.show() # Seems like we are doing okay. No collinearity.
corr_df**2 # None of the values are above the R^2 value
fig = plt.figure(figsize=(12,8))
sma.graphics.plot_partregress_grid(model3, fig = fig)
plt.show()

# 1. multiple regression without transformation.

model3 = smf.ols('Price ~ 1 + Miles + Type + Make + Age', data = cardatTrain).fit()
model3.summary() # 0.128 for Rsq


# 2. multiple regression with transformation.
cardatTrain['lnPrice'] = np.log(cardatTrain['Price']) # log transformation for higher R^2 criterion

model_log = smf.ols('lnPrice ~ 1 + Miles + Type + Make + Age', data = cardatTrain).fit()
model_log.summary() # 0.187 for Rsq


# 3. Categorical multiple regression with a log transforamtion.


model_log = smf.ols('lnPrice ~ 1 + Miles + C(Type) + C(Make) + Age', data = cardatTrain).fit()
model_log.summary() # 0.461 for Rsq


plt.plot(cardatTrain.Price)
plt.show()
# The value we use will depend on parsimony, explanatory, or predictive power. 
# In this situation I will use R^2 as it shows a measure of explained variance which helps
# with predictive power. Also, another reason to use the R^2 value, is because the adjusted 
# R^2 is not heavily penalizing the model, suggesting that the model is not too biased.
# However, it is good to keep in mind that the p-values also indicate that the model has explanatory power as well.




# predictions using best_mod- make=1, 7 years old, 67,000 miles

pred_df = pd.DataFrame(dict(Age=[7],Make=[1],Type=[3],Miles=[67000]))

predds = model_log.predict(pred_df)

np.exp(predds)

# We would get a prediction of $9394.84 given a convertible Toyota that is 7 years old with 67,000 miles on it.

