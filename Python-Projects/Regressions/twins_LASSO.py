# -*- coding: utf-8 -*-



# Improving simple linear model by replacing OLS estimation with some alternative fitting procedure
# recall OLS estimators have the least variance for unbiased estimators
# Why should we use an alternative fitting procedure? 1. prediction accuracy 2. model interpretability

# as models become more complex, we can pick up more local structure/curvature. This is because of a tradeoff
# of useful information with non-useful information.

# In essence, I am trying to add biasto minimize or reduce some of the variance.

# we can add bias by removing terms. Several ways we can determine the removal of factor (p-values, AIC/BIC).
# However, as n gets larger, p-values start to get useless and AIC/BIC values become computationally heavy.
# This is why we need to "regularize" the coefficient estimates. This means to shrink/minimize the OLS estimates
# Mathematically, there is a penalty that reduces the coefficients and creates scale equivalents.

# lambda parameter. This is the tuning parameter that minimizes the penalty and selects the smalles error rate.
# We select a grid of potential values and use cross-validations to estimate the error rate on test data and select the value that gives the smallest error rate.



# DLHRWAGE.....the difference (twin 1 minus twin 2) in the logarithm of 
#              hourly wage, given in dollars.                                              
# DEDUC1.......the difference (twin 1 minus twin 2) in self-reported 
#  	       education, given in years.                                        
# AGE..........Age in years of twin 1.                                                 
# AGESQ........AGE squared. 
# HRWAGEH......Hourly wage of twin 2. 
# WHITEH.......1 if twin 2 is white, 0 otherwise.
# MALEH........1 if twin 2 is male, 0 otherwise.
# EDUCH........Self-reported education (in years) of twin 2.
# HRWAGEL......Hourly wage of twin 1.
# WHITEL.......1 if twin 1 is white, 0 otherwise.
# MALEL........1 if twin 1 is male, 0 otherwise.
# EDUCL........Self-reported education (in years) of twin 1.
# DEDUC2.......the difference (twin 1 minus twin 2) in cross-reported 
#              education. Twin 1's cross-reported education, for example,
#              is the number of years of schooling completed by twin 1 as
#              reported by twin 2.                                     
# DTEN.........the difference (twin 1 minus twin 2) in tenure, or number of 
#	       years at current job.
# DMARRIED.....the difference (twin 1 minus twin 2) in marital status, where
#              1 signifies "married" and 0 signifies "unmarried". 
# DUNCOV........the difference (twin 1 minus twin 2) in union coverage, where
#              1 signifies "covered" and 0 "uncovered". 
 
                                                      
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import matplotlib.pylab as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LassoLarsCV

 
### Load the dataset into dataframe, ensure read-in correctly
twinData = pd.read_csv("pythondata/twinstudy/twins.txt")
twinData.head()

twinData.dtypes

twinData.columns

### make sure missing data read in as missing
twinData[['DLHRWAGE','EDUCH']]
twinData[['DLHRWAGE']]
twinData = twinData.dropna()
twinData[['DLHRWAGE']]

# remove rows with missing data (regression will fail to run with missing data)
twinData = pd.read_csv("pythondata/twinstudy/twins.txt", na_values=["."])
twinData = twinData.dropna()
twinData[['DLHRWAGE']]
twinData.DLHRWAGE


### exploratory data analysis 
### obtain summary statistics
### assess regression assumptions

twinData.describe()

# check normality of response variable (need to drop missing data to generate)
import matplotlib.pyplot as plt
#plt.hist(twinData.DLHRWAGE.dropna())
plt.hist(twinData.DLHRWAGE,50)
plt.show()



### basic linear regression (without variable selection)

import statsmodels.api as sm

# if I needed to convert one of my variables to factors, could do so
twinData.MALEL
twinData['MALEL'] = pd.Categorical(twinData.MALEL).codes # convert text categories to numeric codes
X = twinData.drop('DLHRWAGE',axis=1)
X.columns
y = twinData[['DLHRWAGE']]

# include intercept in model
X1 = sm.add_constant(X)

model = sm.OLS(y, X1).fit()
model.summary()

recode1 = {-1:0, 0:0, 1:1}
recode2 = {-1:0, 0:1, 1:0}
recode3 = {-1:1, 0:0, 1:0}

# transform levels of categorical variablies into 0/1 dummy variables
twinData['DMARRIED1'] = twinData.DMARRIED.map(recode1)
twinData['DMARRIED0'] = twinData.DMARRIED.map(recode2)
twinData.head(10)

twinData['DUNCOV1'] = twinData.DUNCOV.map(recode1)
twinData['DUNCOV0'] = twinData.DUNCOV.map(recode2)
twinData.head(10)

#select predictor variables and target variable as separate data sets  
predvar= twinData[['DEDUC1','AGE','AGESQ','WHITEH','MALEH','EDUCH','WHITEL','MALEL','EDUCL','DEDUC2','DTEN','DMARRIED0','DMARRIED1','DUNCOV0','DUNCOV1']]

target = twinData.DLHRWAGE
 
# standardize predictors to have mean=0 and sd=1 (required for LASSO)
predictors=predvar.copy()
from sklearn import preprocessing
predictors['DEDUC1']=preprocessing.scale(predictors['DEDUC1'].astype('float64'))
predictors['AGE']=preprocessing.scale(predictors['AGE'].astype('float64'))
predictors['AGESQ']=preprocessing.scale(predictors['AGESQ'].astype('float64'))
predictors['WHITEH']=preprocessing.scale(predictors['WHITEH'].astype('float64'))
predictors['MALEH']=preprocessing.scale(predictors['MALEH'].astype('float64'))
predictors['EDUCH']=preprocessing.scale(predictors['EDUCH'].astype('float64'))
predictors['WHITEL']=preprocessing.scale(predictors['WHITEL'].astype('float64'))
predictors['MALEL']=preprocessing.scale(predictors['MALEL'].astype('float64'))
predictors['EDUCL']=preprocessing.scale(predictors['EDUCL'].astype('float64'))
predictors['DEDUC2']=preprocessing.scale(predictors['DEDUC2'].astype('float64'))
predictors['DTEN']=preprocessing.scale(predictors['DTEN'].astype('float64'))
predictors['DMARRIED0']=preprocessing.scale(predictors['DMARRIED0'].astype('float64'))
predictors['DMARRIED1']=preprocessing.scale(predictors['DMARRIED1'].astype('float64'))
predictors['DUNCOV0']=preprocessing.scale(predictors['DUNCOV0'].astype('float64'))
predictors['DUNCOV1']=preprocessing.scale(predictors['DUNCOV1'].astype('float64'))

# split data into train and test sets
pred_train, pred_test, resp_train, resp_test = train_test_split(predictors, target, test_size=.3, random_state=123)

# specify the lasso regression model
# precompute=True helpful for large data sets
model=LassoLarsCV(cv=10, precompute=True).fit(pred_train,resp_train)

# print variable names and regression coefficients
# note: we standardized variables so we can look at size of coefficients to assess which variables have the most predictive power
dict(zip(predictors.columns, model.coef_))

# plot mean square error for each fold
m_log_alphascv = -np.log10(model.cv_alphas_)
plt.figure()
plt.plot(m_log_alphascv, model.cv_mse_path_, ':')
plt.plot(m_log_alphascv, model.cv_mse_path_.mean(axis=-1), 'k', label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model.alpha_), linestyle='--', color='k', label='alpha CV')
plt.legend()
plt.xlabel('-log(alpha)')
plt.ylabel('Mean squared error')
plt.title('Mean squared error on each fold')
plt.savefig('Fig02')


model.coef_
model.intercept_

pred_train.head()
