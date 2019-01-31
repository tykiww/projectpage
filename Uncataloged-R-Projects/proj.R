#life expectacy "https://data.cdc.gov/api/views/w9j2-ggv5/rows.csv?accessType=DOWNLOAD"

hi <- read.csv("https://data.cityofchicago.org/api/views/xzkq-xp2w/rows.csv?accessType=DOWNLOAD",
               header= TRUE,stringsAsFactors = FALSE)
#Taking out dollar signs
hi$Annual.Salary<- as.numeric(gsub("\\$", "",hi$Annual.Salary ))
hi$Hourly.Rate<- as.numeric(gsub("\\$", "",hi$Hourly.Rate ))

#Creating annual salary amounts for those that have hourly wages.
for (i in 1:length(hi$Name)) {
  if (is.na(hi$Typical.Hours[i])) {
    hi$Ansal[i] <- hi$Annual.Salary[i]
  } else if (hi$Typical.Hours[i] > 0) {
    hi$Ansal[i] <- hi$Typical.Hours[i]*hi$Hourly.Rate[i]*52
  }
}
str(hi)
hi <- hi[,-c(6:8)]

#Delete all NAs



#Adding a random sample of marital status, race, and gender
hi$status<- sample(c("married","single"),size = length(hi$Name), prob = c(.3,.7), replace=TRUE)
g <- c("White","Black","Other","Asian","2 or more","American Indian")
prg <- c(.45,.329,.134,.055,.027,.005)
hi$race <- sample(g,size = length(hi$Name), prob = prg, replace = TRUE)
hi$gender <- sample(c("f","m"),size = length(hi$Name), prob = c(.42,.58), replace=TRUE)


#Filter out name variable
hello <- hi[,-1]
#summary and hist of salary
summary(hello$Ansal)
hist(hello$Ansal)

#Create Train and Test
#Create a SRS without replacement of 80% the length of hello$Ansal
set.seed(14) #Set seed so the same data is used for both train and test datasets.
length(hello$Ansal)*.80
train.length <- sample(1:length(hello$Ansal),26000)
hey.train <- hello[train.length,]
hey.test <- hello[-train.length,]

#Check to see the data dimensions and summary 
dim(hey.test)
summary(hey.train)
summary(hey.test)

names(hey.train)

library("randomForest")
out.money <- randomForest(x=hey.train[,-5], y=hey.train$Ansal,
                          xtest=hey.test[,-5], ytest=hey.test$Ansal,
                          replace=TRUE, #Bootstrap SRS with replacement
                          keep.forest=TRUE, ntree=100, mtry=4, nodesize=6)
out.money