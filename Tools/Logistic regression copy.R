# Logistic Regression instructions!

# Basic Explanation:

# We find explanatory variables that explain 
# probability that the response variable is 
# in a certain class. What I will be working
# with is a logistic regressions given two
# different classes. Yes / No. In other words,
# methods for binary response variables (the
# yes/no can also be written as {0,1}).

# A logistic regression works with probabilities
# and odds, so the CDF will look like a sigmoidal
# (S-shaped) curve. Due to the multiplicative
# nature of this curve (Bernoulli distribution), 
# a log transformation will become necessesary 
# to perform a regression.

# For a simple linear regression case, the model
# will look like this:

# ln[P(1|x)/P(0|x)] = bo + b1x

# Notice here that there is no epsilon. This 
# does not mean that there is no error, but
# that the errors don't follow a normal 
# distribution. In other words, there's no 
# common error distribution independent of 
# the predictor values. 

# If you're not familiar with [odds](https://en.wikipedia.org/wiki/Odds) 
# or log odds here's a little conversion table for you.

# ![](http://www.restore.ac.uk/srme/www/fac/soc/wie/research-new/srme/modules/mod4/4/odds_to_log_table.jpg)

## Probability | odds | Log Odds
## -------------------------------
##     0.5     |   1  |    0
##    0.20     | 0.25 |  -1.38
##    0.95     |  19  |   2.94

    ## prob scale        1 ------ 0.5 ------ 0
    ## Log odds scale    <====-====0====+===> 
    ##       anywhere on the real line

# The bigger the log odds, the bigger the probability gets to 1.
# Smaller than one corresponds with smaller probability.


# Creating explanatory/response variables
data$y <- ifelse(data$y=="Passed",1,0) # if this was an exam pass/fail q.


# Create boxplots for numerical values

L <- ggplot(data,aes(x,y)) + 
  geom_boxplot(fill="slateblue", alpha=.8) +
  geom_jitter(fill="grey", alpha = .5, width = .05) +
  xlab("X values") + ylab("Y value") +
  ggtitle("distribution") +
  theme(plot.title = element_text(hjust = 0.5))
ggplotly(L)


# Create Contingency table for categorical values

rbind("var1" = tapply(data$x1,data$y,sum),
      "var2" = tapply(data$x2,data$y,sum),
      "var3" = tapply(data$x3,data$y,sum))
table(data$y,data$x1)
table(data$y,data$x2)
table(data$y,data$x3)

prop.table()

# Make sure to change your variables into an R-type factor!
data$y <- factor(data$y)
data$x <- as.factor(data$x)
  # In some cases, releveling is necessary 
  # to establish a reference point
data$x1 <- relevel(data$x1, ref = "1") 
  # Choosing 1st factor element in x1 as reference points.


# FIT MODEL

# g stands for generalized; glm is the model for any exponential 
# family; bernulli is one type of binomial.
out.data <- glm(y ~ x1 + x2, + x3,data=data,family="binomial") # use train if you are going to predict.
# parameter estimates and standard errors
summary(out.data) 

# Report the interpretation of the x effect on y
exp(coef(out.data))
exp(confint(out.data)) # Don't freak out if it gives you a warning!
  # Interpreting effect differences (Outcomes are in Log odds):
    # For every additional x1, the estimated odds of y increases / 
    # decreases by an estimated 2.24 (ie.) times holding all else 
    # constant (95% CI: 0.3405583, 2.2411349).
    exp(confint(data)[5,]) - 1 # 1- for odds that are around 1.
    exp(coef(data)[-1]) - 1 # learn more how to interpret odds!
    # There is a statistically significant effect of x2 on y after adjusting 
    # for x1, x3, and x4 (p-value < 0.0001) For each additional x2, we estimate 
    # a decrease / increase of 8 percent in the odds of winning holding all else 
    # constant. (95% CI: 7%, 10%)
  
# PLOTTING EACH ß value (if confused, reference LOL.R)
    # sequence is the range of x1. Table values are each 
    # median/mean value of other explanatory variables.
x.star <- data.frame(x1=seq(0,10,length=100),x2=2,x3=6,x4=34)
    # 
plot(x.star$x1,predict(out.data,newdata=x.star,type="response"),
     type = "l", ylim = c(0,1), xlab="x1", ylab = "P(y), all other factors at median value")
# plot that says as you increase the number of x1, the probability of 
# y increases / decreases. This is holding all others constant. You can 
# do this for each x variable. 


# WAYS TO DO HYPOTHESIS TESTING
  # ANOVA (IS THERE A DIFFERENCE IN effects?)
summary(out.examp) # Look at intercept values.
    # We reject / accept Ho: b1=0 in favor of Ha: b1!= 0 at the alpha = 0.05 level
    # beta values have a statistically significant effect on y (pval = 0.0329).
  # LRT X^2 test (Chi-square)
reduced.data <- glm(y ~ +1, data=p,family="binomial") # Reduced model: +1 for no effects.
anova(reduced.data, out.data,test = "Chisq")
    # pval .01055 (smaller # better information out of data for this example).
    # We reject Ho: b1=0 in favor of Ha: b1!= 0 at the alpha = 0.05 level
    # betas have a statistically significant effect on y (pval = 0.01055)
  # 95% CI on beta 1
exp(confint(data)[-1,]) # check this line again (code may be wrong)
exp(confint(out.data))[-1,]
# (1.58895, 111.76680)
# for a one unit increase in y (for a one unit increase in y 
# we estimate the odds of y increase 10 times (95% CI: 1.59,111.77)


# TRAIN & TEST

# NOW, if you are worried about prediction, we will do a TRAIN/TEST model.
# The reason behind this training and test model is to create a training 
# model with 80% of the data, making our model, then predicting. If our
# training and test models are similar, then we know that our prediction
# is close to accurate. Of course, this is only useful with large datasets
# If the data is too small, we cannot accurately make similar train and test
# dataset.

# We are extrapolating beyond the reach of descriptive statistics. We must have
# a way to assess the accuracy, reliability, and credibility of the predictive models 
# we create. PREDICTION IS DONE WITH TRAIN DATA MODEL. Make sure to do everything above
# with a train dataset.


# Create train & Test ( DO THIS TOWARDS THE BEGINNING)

glimpse(data)
dim(data)
set.seed(15) # random seed. Keep data constant.

total.length <- length(data[,1])
train.length <- length(data[,1])*80
train.ind <- sample(total.length,train.length)
data.train <- data[train.ind,]
data.test <- data[-train.ind,]
# confirm that they are similar. They must be roughly similar, or no point in analysis.
summary(data.train)
summary(data.test)
out.train <- glm(y ~ x1 + x2 + x3 + x4,data=data.train,family="binomial")

# Make sure to do all the analysis with the training dataset. Then, when we are doing an
# assesment.

# PREDICT WITH ORIGINAL DATASET.

# Case 1

  # Predictions for characteristic 1.
  phat <- predict(out.train, newdata = data.frame(x1=2, x2=3, x3=8, x4=40), type="response") # spits out prob
  # predicted probability of this person achieving y is: 0.6666673 
  
  # CI predictions vertically on the sigmoidal curve.
  char.logit <- predict(out.train, newdata = data.frame(x1=2,x2=3,x3=8,x3=40), type="link", se.fit=TRUE)
  p.hat <- char.logit$fit 
  t <- qnorm(0.975) # standard errors are NOT probabilities, but log odds.
  logit.L <- p.hat - t*char.logit$se.fit
  logit.U <- p.hat + t*char.logit$se.fit
  char.phat.L <- 1/(1 + exp(-logit.L))
  char.phat.U <- 1/(1 + exp(-logit.U))
  c("prob" = phat, "Lower" = char.phat.L, "Upper" = char.phat.U)
  # The probability of Faker winning is 66% (95% CI: 63 , 70)

# NEED TO REVISE!!!!
  
  
  
  
  
  
  
# Prediction Performance in a Logistic Regression Model:
# Classification: Try to give me a yhat that is 0 or 1
# Choose a cutoff, if the predicted probability is greater than the cutoff,
# then yhat is = 1, the opposite is true if the predicted probability is < c = 0.

# classification:
  # Values between 0.4:0.65 are advised.
  # Classification is the opposite of hypothesis test, we are looking at the times 
  # we are right. we’ll have to choose a cutoff value, or you can say its a threshold 
  # value. Scores above this cutoff value will be classified as positive, those below 
  # as negative. We will not focus on the optimum cutoff values, but will just say 50%
  # is the cutoff. 
yhat.class <- as.numeric(predict(out.train, type = "response") > 0.5) 
# change 0.5 depending on misclassification rate you are looking for. 
table(yhat.class,out.train$y)
# Top is the actual
# left column is the predicted.
    ##     0     1
    ##  .___________.
    ## 0|  A  |  B  |
    ## 1|  C  |  D  |
    ##  -------------


# Let's judge the fit by taking a look at the misclassification rate!
  # overall misclassification (getting something wrong)
C*B / (C+B)
  # 2 main types of misclassification (for our graph)
    # Sensitivity: proportion of true positives "said they will win and the player won" 
D / (B+D)
    # Specificity: proportion of false negative "said they lost and they actually lose"
A / (A+C)

# range of misclassification
cutoff <- seq(0.4,0.5, length.out = 100)

sensitivity <- seq(0.94, 0.86, length.out = 100)

specificity <- seq(0.75, 0.88, length.out = 100)
tab <- cbind(cutoff,sensitivity,specificity)
plot(x = sensitivity,y = 1-specificity)
# We can see here that there is a clear tradeoff. 
# As you try to increase the sensitivity, There 
# is an increase in the False positive rate.


# To view the measure of prediction performance,
# These values can be graphed. As they are plotted, we can see the strength of the
# predictions using the ROC (Receiver Operating Characteristic) curve, and measuring
# the AUC (area under the curve). The wider the ROC, the better our prediction. Our
# ROC curve is measured against a 1:1 line which signifies 50% prediction. Remember,
# 50% means that we are pretty much tossing a coin to make a prediction. Useless. 
# The further away we are from the 1:1 line, the better off we are overall. Of course,
# depending on the specificity the curve will look different. High sensitivity is great
# as we are able to predict correctly at a higher rate. Higher specificity, is better
# for any case (especially for biostats, false positives can be extremely fatal). High
# specificity and sensitivity will fill out the upper left hand corner of our graph.

# The AUC curve is a broad measure of prediction performance from 0.5 to 1 (where 0.5 would 
# be prediction based on random chance to 1 being perfect prediction). Depending on how 
# specific and sensitive the prediction performance is, this value will calculate how accurate 
# either the prediction of the true positive (getting something right when you predict it) and 
# true negative (being correct when you predict it) will be.

# AUROC is similar to AUC, but this is looking at the specific area under the curve
# given a type of misclassification rate!


# Create ROC curve
  # y axis: sensitivity (being right)
  # x axis: 1-specificity (being wrong)
  library("ROCR")
  
  train.pred <- prediction(predict(out.data,type="response"),data.train$y)
  train.perf <- performance(train.pred, measure = "tpr", x.measure="fpr")
  plot(train.perf,xlab="1-specificity",ylab="sensitivity", main="ROC Curve")
  # AUC value TRAIN
  performance(train.pred,measure="auc") # 0.9310008
  
  # Compare to test(out of sample validation)
  test.pred <- prediction(predict(out.train,newdata=data.test, type="response"),data.test$y)
  test.perf <- performance(test.pred,measure="tpr",x.measure="fpr")
  plot(test.perf,col="red",add=TRUE)
  abline(0,1,col="grey") # worst case scenario line.
  # AUC value TEST 
  performance(test.pred,measure="auc") # 0.9315501
  # Now this is unlikely, but sometimes the AUC value for test can be higher than for train.
  # This usually happnes just because of the peculiarity from our sample. It's a good thing!

# It is usually good practice to report your prediction performance along with our prediction.
  
  # robust analysis: Sometimes when  effects are so large, it doesn't matter which model you use. 
  # It can be applied to different distributions. Some logistic regression research can use RF or
  # a Bayes' heiarchial model.
  
  
# Problem with machine learning. 
# There is lack of thoughtfulness 
# especially when there isn't enough 
# data. I guess there isn't much
# We don't have deeper covariates
# that may be more influential. We
# can even eliminate intentional and
# unintentional biases. 








