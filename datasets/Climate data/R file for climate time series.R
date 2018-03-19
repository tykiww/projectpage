


climaties <- climate
climaties$year <- factor(climate$year)

cot <- tapply(climaties$co2,climaties$year, sum)
meth <- tapply(climaties$methane,climaties$year, sum)
teemp <- tapply(climaties$temp,climaties$year, sum)

2016-199

seq(1999:2016,1817,1)


plot(x = 1999:2016, y = cot) # from 2011
plot(x = 1999:2016, y = meth) # from 2011
plot(x = 1999:2016, y = teemp) # from 2011

library(astsa)
# forecast for recent data
sarima(log(teemp)[-(1:9)],1,1,1)
fut.temp <- sarima.for(log(teemp)[-(1:9)], n.ahead = 5, 1,1,1)
fut.cot <- sarima.for(cot[-(1:11)], n.ahead = 5, 1,1,1)
fut.meth <- sarima.for(meth[-(1:11)], n.ahead = 5, 1,1,1)

# forecast for historical data

fut.temp$pred <- exp(fut.temp$pred)
fut.cot$pred
fut.meth$pred


t <- qnorm(0.975)
temp.L <- fut.temp$pred - t* exp(fut.temp$se)
temp.U <- fut.temp$pred + t* exp(fut.temp$se)


#The *pretty* not so pretty graph

plot(x = 1999:2016, y = teemp,type="o",                        #Data up until the current year
     ylab="Yearly Temperature (in C˚)",
     xlab="Time in Years",
     xlim=c(1999,2021),
     ylim=c(200,2000))
lines(2017:2021,temp.L,col="blue",lty=2)                         #lower bounds
lines(2017:2021,temp.U,col="blue",lty=2)                         #upper bounds
polygon(c(2017:2021,rev(2017:2021)),c(temp.L,rev(temp.U)), #Filling in the lines between the upper
        col = "light gray",                                            #and lower bounds in the prediction.
        border = NA)
lines(2017:2021,fut.temp$pred,col="red",type="b",pch=5)
lines(2017:2021,fut.temp$pred,col="red",type="b",pch=3)





cot.L <- fut.cot$pred - t* fut.cot$se
cot.U <- fut.cot$pred + t* fut.cot$se

plot(x = 1999:2016, y = cot,type="o",                       #Data up until the current year
     ylab="CO2 Frequency (in ppm)",
     xlim=c(1999,2021),
     ylim=c(1800,6000))
lines(2017:2021,cot.L,col="blue",lty=2)                         #lower bounds
lines(2017:2021,cot.U,col="blue",lty=2)                         #upper bounds
polygon(c(2017:2021,rev(2017:2021)),c(cot.L,rev(cot.U)), #Filling in the lines between the upper
        col = "light gray",                                            #and lower bounds in the prediction.
        border = NA)
lines(2017:2021,fut.cot$pred,col="red",type="b",pch=5)
lines(2017:2021,fut.cot$pred,col="red",type="b",pch=3)



meth.L <- fut.meth$pred - t* fut.meth$se
meth.U <- fut.meth$pred + t* fut.meth$se

plot(x = 1999:2016, y = meth,type="o",                       #Data up until the current year
     ylab="Methane Frequency (in ppm)",
     xlim=c(1999,2021),
     ylim=c(9000,28000))
lines(2017:2021,meth.L,col="blue",lty=2)                         #lower bounds
lines(2017:2021,meth.U,col="blue",lty=2)                         #upper bounds
polygon(c(2017:2021,rev(2017:2021)),c(meth.L,rev(meth.U)), #Filling in the lines between the upper
        col = "light gray",                                            #and lower bounds in the prediction.
        border = NA)
lines(2017:2021,fut.meth$pred,col="red",type="b",pch=5)
lines(2017:2021,fut.meth$pred,col="red",type="b",pch=3)

