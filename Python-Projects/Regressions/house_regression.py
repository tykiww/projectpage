# -*- coding: utf-8 -*-


# Recall CRISP-DM
#
# Understand the business question
# Understand the data
# Data preparation
# Modeling
# Evaluation
# Understand results
# Evaluate model
# Deployment


# Price........Cost of house
# sqft.........Square Footage of house
# bedrooms.....Number of bedrooms in house
# bathrooms....Number of bathrooms in house
# lot size.....Size of lot in sq feet
# area.........Area
# area_n.......Area code (1 = Uptown, 2 = Downtown, 3 = Suburbs)




import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import matplotlib.pylab as plt
import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split
from statsmodels.stats.outliers_influence import variance_inflation_factor
from patsy import dmatrices

### Load the dataset into dataframe, ensure read-in correctly
houseData = pd.read_csv("~/Dropbox/Stats/Stat420/Lectures/regression/data/house_data.csv")
houseData.head()
houseData[['Price', 'area']]

houseData.dtypes

houseData.columns

### make sure missing data read in as missing
houseData[['Price']]
houseData.Price
houseData = houseData.dropna()
houseData[['Price']]

# remove rows with missing data (regression will fail to run with missing data)
houseData = pd.read_csv("~/Dropbox/Stats/Stat420/Lectures/regression/data/house_data.csv", na_values=["."])
houseData = houseData.dropna()
houseData[['Price']]
houseData.Price

houseData.dtypes

### exploratory data analysis
### obtain summary statistics
### assess regression assumptions

houseData.describe()

# check normality of response variable (need to drop missing data to generate)
plt.hist(houseData.Price, 50)
plt.show()

### split data into training, test
houseTrain, houseTest = train_test_split(houseData, test_size=.3, random_state=123)
houseTrain.shape
houseTest.shape

### basic linear regression (without variable selection)

# adding '1' as a predictor forces the inclusion of an intercept
model = smf.ols(formula='Price ~ 1+ sqft + bedrooms+ bathrooms + lot_size + area', data=houseTrain).fit()
model.summary()

# MUST SPECIFICALLY IDENTIFY CATEGORICAL VARIABLES
# (otherwise, they will be treated as continuous and estimated effect won't make sense)
model_categorical = smf.ols(formula='Price ~ 1+ sqft + bedrooms+ bathrooms + lot_size + C(area_n)', data=houseTrain).fit()
model_categorical.summary()


### Test our residuals

residual = model_categorical.predict(houseTrain) - houseTrain.Price

# Test for normal residuals
plt.hist(residual)
# Test for heteroscedasticity
plt.plot(model_categorical.predict(houseTrain), residual, '.')



