# coding: utf-8

# # Logistic Regression

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sklearn


from pylab import rcParams
from sklearn import preprocessing
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.metrics import classification_report



titanic =  pd.read_csv("~/Dropbox/Stats/Stat420/Lectures/regression/data/titanic_train.csv")
titanic.columns = ['PassengerId', 'Survived', 'Pclass', 'Name', 'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 'Fare', 'Embarked']
titanic.head()

# ##### VARIABLE DESCRIPTIONS
#
# Survived - Survival (0 = No; 1 = Yes)<br>
# Pclass - Passenger Class (1 = 1st; 2 = 2nd; 3 = 3rd)<br>
# Name - Name<br>
# Sex - Sex<br>
# Age - Age<br>
# SibSp - Number of Siblings/Spouses Aboard<br>
# Parch - Number of Parents/Children Aboard<br>
# Ticket - Ticket Number<br>
# Fare - Passenger Fare (British pound)<br>
# Cabin - Cabin<br>
# Embarked - Port of Embarkation (C = Cherbourg; Q = Queenstown; S = Southampton)


# ### Checking for missing values
titanic.isnull().sum()

# Well, how many records are there in the data frame anyway?

# In[6]:


titanic.info()

# We see there are 891 rows. Most columns have all data. A few are missing data. We'll impute age. The rest
# we'll drop. we will also drop a few columns that don't seem relevant to surviving

titanic_data = titanic.drop(['PassengerId', 'Name', 'Ticket'], 1)
titanic_data.head()

# Now we have the dataframe reduced down to only relevant variables,
# but now we need to deal with the missing values in the age variable.
#
# #### Imputing missing values


def age_approx(cols):
    Age = cols[0]
    Pclass = cols[1]

    if pd.isnull(Age):
        if Pclass == 1:
            return 37
        elif Pclass == 2:
            return 29
        else:
            return 24
    else:
        return Age


# When we apply the function and check again for null values, we see that there are no more null values in the age variable.

titanic_data['Age'] = titanic_data[['Age', 'Parch']].apply(age_approx, axis=1)
titanic_data.isnull().sum()

# There are 2 null values in the embarked variable. We can drop those 2 records without loosing too much important information from our dataset, so we will do that.

titanic_data.dropna(inplace=True)
titanic_data.isnull().sum()

# ### Converting categorical variables to a dummy indicators

gender = pd.get_dummies(titanic_data['Sex'], drop_first=True)
gender.head()

embark_location = pd.get_dummies(titanic_data['Embarked'], drop_first=True)
embark_location.head()

titanic_data.head()

titanic_data.drop(['Sex', 'Embarked'], axis=1, inplace=True)
titanic_data.head()


titanic_dummy = pd.concat([titanic_data, gender, embark_location], axis=1)
titanic_dummy.head()

# Now we have a dataset with all the variables in the correct format!


# Fare and Pclass are not independent of each other, so I am going to drop these.

titanic_dummy.drop(['Fare', 'Pclass'], axis=1, inplace=True)
titanic_dummy.head()


X = titanic_dummy.ix[:, (1, 2, 3, 4, 5, 6)].values
y = titanic_dummy.ix[:, 0].values

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=.3, random_state=25)

# ### Deploying and evaluating the model

LogReg = LogisticRegression()
LogReg.fit(X_train, y_train)

y_pred = LogReg.predict(X_test)
y_prob = LogReg.predict_proba(X_test)

LogReg.intercept_
1/ (1 + np.exp(LogReg.intercept_))
LogReg.coef_
titanic_dummy.head()
