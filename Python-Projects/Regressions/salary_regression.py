import pandas as pd
import numpy as np
import matplotlib.pylab as plt
import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split

# Salary - Annual Salary of individual
# Age - Age of Individual
# Profession - 1 if Accountant, 2 if Data Scientist, 3 if Marketer


salaryData = pd.read_csv("~/Dropbox/Stats/Stat420/Lectures/regression/data/salary.csv")
salaryData.head()

salaryData.dtypes


salaryData.describe()

### split data into training, test
salaryTrain, salaryTest = train_test_split(salaryData, test_size=.3, random_state=123)
salaryTrain.shape
salaryTest.shape

plt.plot(salaryTrain[['Age']], salaryTrain[['Salary']], '.')

model = smf.ols(formula='Salary ~ 1 + Age', data=salaryTrain).fit()
model.summary()

### Test our residuals
residual = model.resid
# Test for normal residuals
plt.hist(residual, 50)
plt.show()
# Test for heteroscedasticity
plt.plot(model.predict(salaryTrain), residual, '.')

model_log = smf.ols(formula='Salary ~ 1 + np.log(Age)', data=salaryTrain).fit()
model_log.summary()

### Test our residuals
residual = model_log.resid
# Test for normal residuals
plt.hist(residual, 75)
# Test for heteroscedasticity
plt.plot(model_log.predict(salaryTrain), residual, '.')


model_log_prof = smf.ols(formula='Salary ~ 1 + np.log(Age) + Profession', data=salaryData).fit()
model_log_prof.summary()

model_log_prof_cat = smf.ols(formula='Salary ~ 1 + np.log(Age) + C(Profession)', data=salaryTrain).fit()
model_log_prof_cat.summary()

### Test our residuals
residual = model_log_prof_cat.resid
# Test for normal residuals
plt.hist(residual, 50)
# Test for heteroscedasticity
plt.plot(model_log_prof_cat.predict(salaryTrain), residual, '.')


