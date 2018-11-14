# Regression practice in Python..

# run python.
python

# import packages
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import matplotlib.pylab as plt
import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split as tts
from patsy import dmatrices as dm
from statsmodels.stats.outliers_influence import variance_inflation_factor as vif
from pandas.plotting import scatter_matrix

# read in dataset..
dir = '~/Dropbox (HR Ally)/PythonWD/Linear Regression assignment 2/car.csv'
cars = pd.read_csv(dir)
# clean dataset..
cars = cars.dropna()
# EDA
    # understanding data
plt.hist(cars.Price,50) # Price not very normal looks inverted 1/x
plt.show()
plt.hist(cars.Age) # Age distribution looks uniform. Not too big of a deal.
plt.show()
plt.hist(cars.Miles,50) # Roughly normal miles distribution.
plt.show()

plt.plot(cars.Miles,cars.Price, 'bo')
plt.show()

plt.plot(cars.Age,cars.Price, 'bo')
plt.show()

    # Summary statistics

{'mean':np.mean(cars.Price),'sd':np.std(cars.Price),'corr':np.corrcoef(cars.Price)}
{'mean':np.mean(cars.Age),'sd':np.std(cars.Age),'corr':np.corrcoef(cars.Age,cars.Price)[0,1]}
{'mean':np.mean(cars.Miles),'sd':np.std(cars.Miles),'corr':np.corrcoef(cars.Miles,cars.Price)[0,1]}

# fit model with all variables

car_lm = smf.ols('Price ~ 1 + Age + C(Make) + C(Type) + Miles', data = cars).fit() 

car_lm.summary()

    # variance inflation plot.
y, X = dm('Price ~ 1 + Age + C(Make) + C(Type) + Miles', cars, return_type='dataframe')
yy, lnX = dm('np.log(Price) ~ 1 + Age + C(Make) + C(Type) + Miles', cars, return_type='dataframe') # for logged values
# For each X, calculate VIF and save in dataframe
vifs = pd.DataFrame()
vifs["VIF Factor"] = [vif(X.values, i) for i in range(X.shape[1])]
vifs["features"] = X.columns

vifs # looks like vifs for values are not so high. No collinearity.


    # normality of errors
plt.hist(car_lm.resid)
plt.show() # roughly normal residuals. but with mean -2 and high stdev.
    # homoscedasticity.
plt.plot(car_lm.fittedvalues,car_lm.resid,'bo') # residuals are NOT approximately equal for all predicted
plt.show() # however, when plotting residuals with fitted values we notice some heteroscedastic qualities

# evaluation of model, transform some variables.

# Price seems to be left skewed. Where people paying disproportionately large amounts of money on cars
# pulls the mean past the median. Using the log will improve heteroscedastic qualities, but it may be
# better to use a GLS. However, for the sake of simplicity, will use log transformation..


# log transformation:: does a bit better with krutotsis near normal and skew near 0. The Rsq
# value is much higher along at .4

car_lnm = smf.ols('np.log(Price) ~ 1 + Age + C(Make) + C(Type) + Miles', data = cars).fit() 
car_lnm.summary()


quit()


