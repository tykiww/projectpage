library("ggplot2")
library("dplyr")
library("car")
library("plotly")
library("magick")
library("outliers")

setwd("~/Desktop")
image_read("regression.png")
# The image comes from 

# Useful functions for each part.


# 1. Draw Scatterplots of the data
{
plot() # you can plot all the values with each other, or individuals
# Visualization of interactive graphs with regression line.
qplot(y=,x=,data=) + geom_smooth(method='lm', formula=y~x)

# normality

qqplot() # checks if the data is distributed normally. Goes through 1st and 3rd quartiles.
shapiro.test() # Ho states that not normal: pvalue set to reject.

cor() # correlation of each value.
}




# 2. Fit a model based on subject matter expertise and/or observation of the scatter plot
{
lm.out <- lm(y~x1+x2+x3, data=)
  
summary(lm.out)
# If factors are involved y has factor levels.

out.lm<-lm(y~x + y + y:x, data=overdue,x=TRUE)

summary(out.lm)
}


# 3. Assess the adequacy of the model in particular.
{
# You can also transform the data the best way possible.
# some strategies include...
log() # either predictor, explanatory, for just some
^2
# If it is a simple linear case, but you want to transform,
# multiplicative is best with logs as it has a trumpet shape.
# if there is curvature with no expansion, do a polynomial
# interaction. 


# Compute R-studentized residuals to see if errors are normal.
R.out <- rstudent(out.lm)
2*(1-pnorm(R.out)) # double-sided p-value
# Compute K-S normality test on the R-Studentized residuals.
# test of normality
# H0 e's are normal
ks.test(R.out,"pnorm")
hist(R.out)


# Check for collinearity
vif(out.lm)


}


# 4. Do outliers and/or leverage points exist?
# http://r-statistics.co/Outlier-Treatment-With-R.html
{
  # Influential observations::
  
  # compute leverage
  leverage.out <- lm.influence(out.lm)$hat
  # leverage cutoffs that show how influential: 2*(p+1)/n 
  p <-ncol()#dataset
  n <- nrow()#dataset
  sum(2*(p+1)/n <leverage.out)
  
  
  # Compute cook's distance for every one of our data points
  cd.out <- cooks.distance(out.lm)
  # Cook's Distance cutoffs that show how influential: 4/(n-(p+1))
  
  
  
  # Find outliers.. 
  t <- qnorm(0.975)
  dataset[abs(rstudent(out.lm)) > t,] # gives you the values greater than 2 stdev.
  
  # Function that takes potential outliers and calculates 
  # R-Studentized Residual point and p-value
    # x is value you want to check
    # linmod is your linear model
    # data is the dataset
    # index is the column you are using
  
  tyki.outlier <- function(x,linmod,data,index) {
    R.out <- rstudent(linmod) 
    part <- subset(R.out,data$index==x)
    pva <- 2*(1-pnorm(abs(part))) # two-tailed p-value
    print(c("Rstud" = part,"P-Value" = pva))
    
  }
  


outlierTest() # is probably the best. It finds the most extreme value, but only one at a time.

# 5. Based on ANOVA, decide if there is a significant association between Y and any of the x's

# Check the difference between a reduced model and full model.
anova(full.out,reduced.out)
confint(model.lm)
predict(model.lm, newdata=data.frame("Include all x values"), interval="confidence")


