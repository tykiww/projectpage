
# This assignment should be done in your groups. Feel free to use Python or R for this assignment.
# 1. The data in icudata.csv are 200 observations from a much larger study on survival of patients admitted to the ICU.
    ## a. Fit a logistic regression model that uses age (AGE), race (RACE), 
      ## whether or not CPR was administered (CPR, 0 for no, 1 for had been administered), 
      ## systolic blood pressure at admission (SYS), heart rate at admission (HRA), and type of admission (TYP). 
      ## Do not do any parameter selection. Create a table with the coefficients from the regression.

    ## b. Explain the effect CPR has on survival. How much does receiving CPR increase your likelihood to survive?
    ## c. Now, using the same variables fit a model using the lasso technique. Using cross-validation, what is the optimal alpha value?
    ## d. Using the alpha value and model from part (c), what are the coefficients for each of the parameters that were originally put in the model?

# import packages
library("car")
library("tidyverse")

# setwd("~/Dropbox (HR Ally)/stat 420/Regression Assignment 2")
# read in data
icu.data <- read_csv("icudata.csv")
icu <- icu.data[c("STA","AGE","RACE","CPR","SYS","HRA","TYP")]
# change variables into an R type factor
icu$STA <- factor(icu$STA)
icu$RACE <- factor(icu$RACE)
icu$CPR <- factor(icu$CPR)
icu$TYP <- factor(icu$TYP)


### plots for categorical and numerical variables ###
{
par(mfrow = c(3,3)) # set plot range
icu$STA %>% # Proportion of survival
  table %>% 
  barplot(names.arg = c("Died","Survived"), main = "Proportion of Survival")
    ## 0   1 
    ## 160  40 
icu$RACE %>%  # Proportion of Racial Status
  table %>%
  barplot(names.arg = c("race 1", "race 2", "race 3"), main = "Proportion of Racial Status")
    ## 1   2   3 
    ## 175  15  10
icu$CPR %>%# Proportion of CPR administered
  table %>%
  barplot(names.arg = c("Not","Administered"), main = "Proportion of CPR administerd")
    ## 0   1 
    ## 187  13 
icu$TYP %>%# Proportion of Type
  table %>%
  barplot(names.arg = c("Type 0","Type 1"), main = "Proportion of Type")
    ## 0   1 
    ## 53 147 
hist(icu$AGE, main = "Age") # Age histogram
c("mean" = mean(icu$AGE),"sd" = sd(icu$AGE),"IQR" =  IQR(icu$AGE))
    ## mean       sd      IQR 
    ## 57.54500 20.05465 25.25000 
hist(icu$HRA, main = "Heartrate") # Heartrate histogram
c("mean" = mean(icu$HRA),"sd" = sd(icu$HRA),"IQR" =  IQR(icu$HRA))
    ## mean       sd      IQR 
    ## 98.92500 26.82962 38.25000 
hist(icu$SYS, main = "Systolic BP") # Heartrate histogram
c("mean" = mean(icu$SYS),"sd" = sd(icu$SYS),"IQR" =  IQR(icu$SYS))
## mean       sd      IQR 
## 98.92500 26.82962 38.25000 


par(mfrow = c(1,1)) # close plot range
}

# Create training and test datasets:
dim(icu)
seeds <- floor(runif(1,1,101)) # 84
set.seed(seeds) # random seed. Keep data constant.

total.length <- nrow(icu[,1])
train.length <- nrow(icu[,1])*.80
train.ind <- sample(total.length,train.length)
icu.train <- icu[train.ind,]
icu.test <- icu[-train.ind,]
# confirm that they are similar. They must be roughly similar, or no point in analysis.
summary(icu.train)
summary(icu.test) # use if necessary


# Fit logistic regression model

icu.out <- glm(STA ~ AGE + RACE + CPR + SYS + HRA + TYP, data = icu, family = c("binomial"))
summary(icu.out)

    ## Coefficients:
    ##                Estimate Std. Error z value Pr(>|z|)   
    ##   (Intercept) -3.121326   1.482158  -2.106  0.03521 * 
    ##   AGE          0.035030   0.011488   3.049  0.00229 **
    ##   RACE2       -0.826682   1.093817  -0.756  0.44978   
    ##   RACE3        0.264006   0.889242   0.297  0.76655   
    ##   CPR1         1.387793   0.647425   2.144  0.03207 *  # coefficient is positive suggesting that the higher 
    ##   SYS         -0.012837   0.006393  -2.008  0.04466 * 
    ##   HRA         -0.007946   0.007742  -1.026  0.30473   
    ##   TYP1         2.303172   0.781847   2.946  0.00322 **

exp(coef(icu.out)) # 4.00600078
exp(confint(icu.out)) # 1.128113473 14.8989259

logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}


# how important is it to get CPR?

logit2prob(4.00600078) # probability of survival for those that have had CPR is 98.21%

# There is a statistically significant effect of CPR on survival after adjusting 
# for all other variables (p-value < 0.05). For each additional time CPR is adminsterd, 
# the estimated odds of survival increases by 4 times holding all else constant.
# (95% CI: 1%, 14%)





# Now, using the same variables fit a model using the lasso technique. 
# Using cross-validation, what is the optimal alpha value?


















