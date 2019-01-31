# practicing a regression...
library("car")
library("outliers")
library("ggplot2")
library("gridExtra")
library("dplyr")
library("plotly")
library("caret")


# greenhouse Gasses. Is there evidence of greenhouse Gasses and Global warming?


link1 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/Nasa%20Temp"
link2 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/CO2"
link3 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/Methane"
link4 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/N2O"
link5 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/HCFC"
link6 <- "https://raw.githubusercontent.com/tykiww/projectpage/master/datasets/Climate%20data/SF6"

nasatemp <- read_csv(link1, col_names = T)


nasatemp <- nasatemp[-1]

# what your next task is... Reshape dataset to show month as column..

nasatemp <- nasatemp[,1:13]

newtemps <- data.frame(temp=matrix(t(nasatemp[2:13]),ncol=1))
newtemps$month <- rep(1:12)
newtemps$year <- rep(1880:2017,each=12)


newtemp <- subset(newtemps,newtemps$year>=1969)

dim(newtemp)


# CO2
maunaloa1 <- read.csv(link2)
maunaloa1 <- maunaloa1[,-1]
# Methane
maunaloa2 <- read.csv(link3)
maunaloa2 <- maunaloa2[,-1]




# merge datasets and clean up
climate <- merge(merge(newtemp,maunaloa1,by=c("year","month"), all.x=TRUE),maunaloa2,by=c("year","month"),all.x=TRUE)
climate <- subset(climate,!is.na(where.x) & !is.na(where.y))
climate <- climate[,c("year","month","temp","co2","methane")]

# Add other 3 gasses.

# N20
maunaloa3 <- read.csv(link4)
maunaloa3 <- maunaloa3[,2:4]
# Hydrochloroflurocarbon 
maunaloa4 <- read.csv(link5)
maunaloa4 <- maunaloa4[,2:4]
# sulfer hexaflouride (SF6) 
maunaloa5 <- read.csv(link6)
maunaloa5 <- maunaloa5[,2:4]

# merge additional datasets and clean up
climate <- merge(climate,maunaloa3,by=c("year","month"), all.x=TRUE)
climate <- subset(climate,!is.na(n2o))
climate <- merge(climate,maunaloa4,by=c("year","month"), all.x=TRUE)
climate <- subset(climate,!is.na(hcfc))
climate <- merge(climate,maunaloa5,by=c("year","month"), all.x=TRUE)
climate <- subset(climate,!is.na(sf6))
#with so many observations removed for missing data, renumber the rows
rownames(climate) <- 1:dim(climate)[1]
# delete old datasets now that we have our latest climate data.
rm(maunaloa1,maunaloa2,maunaloa3,maunaloa4,maunaloa5,nasatemp,newtemps,newtemp)
rm(link1,link2,link3,link4,link5,link6)
glimpse(climate)

# what I want to model is... Gasses to temperature..

# first, do some summary statistics.

climatex <- climate[-c(1:2)]


summary(climatex)

cbind("sd" = sapply(climatex,sd),"mean" = sapply(climatex,mean),"correlation" = cor(climatex)[,1])


sd <- sapply(climate,sd)[-c(1:3)]
mean <- sapply(climate,mean)[-c(1:3)]
cor <- cor(climate)[3,-c(1:3)] # High correlation
cbind(mean,sd,cor) # cbind all 3 summary statistics.

colnames(climatex)


# linearity assumptions..
a <- qplot(y=temp,x=co2,data=climate) + geom_smooth(method='lm', formula=y~x)
b <- qplot(y=temp,x=methane,data=climate) + geom_smooth(method='lm', formula=y~x)
c <- qplot(y=temp,x=n2o,data=climate) + geom_smooth(method='lm', formula=y~x)
d <- qplot(y=temp,x=hcfc,data=climate) + geom_smooth(method='lm', formula=y~x)
e <- qplot(y=temp,x=sf6,data=climate) + geom_smooth(method='lm', formula=y~x)
grid.arrange(a,b,c,d,e,ncol = 2) # same as aov plot.


# check for normality..

for (i in 1:ncol(climatex)) {
  print(colnames(climatex[i]))
  print(0.05 > shapiro.test(climatex[,i])$p.value) 
}

# check residual conditions.
glimpse(climatex)
out.climate <- lm(temp ~ co2 + methane + n2o + hcfc + sf6, data = climatex)

hist(residuals(out.climate)) 
# technically if these residuals are run by shapiro wilk test, they are NON NORMAL, however..
# We can still assume normal residuals with these conditions.


# homoscedasticity check
climatex$resids <- residuals(out.climate)
ggplot(climatex,aes(temp,resids)) + geom_point(col = 'blue') # the data seems heteroskedastic. 
                                                             # unequal variances

# independence of errors : assume unless you see collinearity..


vif(out.climate) #holy collinearity.. The variance each variable is explaining in each other is extremely high.
# !:1 is the ratio of variance explained by an explanatory to response variable. The higher the ratio,
# the more it means the values are explaining things within the model where unnecessary.
plot(~co2 + methane + n2o + hcfc + sf6,data=climate)




# 1. choose variables of interest

# 2. clean the data

# 3. EDA summary statistics for continuous, boxplots/contingency tables for categorical

# 4. Check normality, linearity, and error assumptions, if not use a generalized least squares or transformation.
# any model that fits the criteria. boxcoxtrans... 

# 5. Fit model.

# 6. Assess collinearity, re-fit model accordingly..





