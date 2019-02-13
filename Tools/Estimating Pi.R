# Cartesian Estimation, Pi

simulation <- function(long){
  c <- rep(0,long)
  numberIn <- 0
  for (i in 1:long){
    x <- runif(2,-1,1)
    
    if(sqrt(x[1]*x[1] + x[2]*x[2]) <= 1){
      numberIn <- numberIn + 1
    }
    prop <- numberIn / i
    piHat <- prop *4
    c[i] <- piHat
  }
  return(c)
}

set.seed(15)
size <- 100000
res <- simulation(size)
ini <- 1
plot(res[1:size], type = 'l')
lines(rep(pi, size)[1:size], col = 'red')

x <- seq(0,34.5,length.out = 100)
dat <- ((.6034)*((20.9/25.9)+ (x/34.5))/2)+((.3966)*1)

cbind(x,dat)

# Leibniz Method, Pi

leibniz <- function(fin) {
  options(warn=-1)
  estimate <- 1/seq(1,fin,2)*c(1,-1)
  options(warn=0)
  sum(estimate)*4 

}

size <- 1000
plot(1:size,sapply(1:size,function(x) leibniz(x)), type = 'l')
abline(h = pi, col = "red")


# 1 Quadrant Dart method
est.pi <- function(n){
  
  # drawing in  [0,1] x [0,1] covers one quarter of square and circle
  # draw random numbers for the coordinates of the "dart-hits"
  a <- runif(n,0,1)
  b <- runif(n,0,1)
  # use the pythagorean theorem
  c <- sqrt((a^2) + (b^2) )
  
  inside <- sum(c<1)
  #outside <- n-inside
  
  pi.est <- inside/n*4
  
  return(pi.est)
}

est.pi(10000)

# circle plot.

N <- 100000
R <- 1
x <- runif(N, min= -R, max= R)
y <- runif(N, min= -R, max= R)
is.inside <- (x^2 + y^2) <= R^2
pi.estimate <- 4 * sum(is.inside) / N


plot.new()
plot.window(xlim = 1.1 * R * c(-1, 1), ylim = 1.1 * R * c(-1, 1))
points(x[ is.inside], y[ is.inside], pch = '.', col = "blue")
points(x[!is.inside], y[!is.inside], pch = '.', col = "red")




