library(datasets)
library(stats)
library(dbscan)
library(tidyverse)
# grab the iris dataset
# hw from http://dml.cs.byu.edu/~cgc/docs/CS401R/Clustering%20HW.pdf
data(iris)

# remove target
glimpse(iris)
# identify target cluster and computed clusters
sets <- iris[1:4]
tc <- iris[5]




#### 3 ####


#### a #### run k-means for each center c(2, 3, 4, 5, 7, 9, 11) ####
centers <- c(2, 3, 4, 5, 7, 9, 11)
iris.models <- lapply(centers, function(x) kmeans(sets,centers = x) )


#### b #### For each value of k, report the size of the clusters and the F-measure 
#### (see the slide deck Basic Clustering for details; there is a link to it 
#### on our class schedule). Both size and cluster assignments are available 
#### in variables computed during k-means (see the documentation in the R 
#### stats package under kmeans). You will need the target values from the 
#### original iris dataset to compute the F-score. You may write a small 
#### program in R to do this (this is the preferred method as it will give 
#### you further experience with R and you will use that program again below) 
#### or export the data and compute elsewhere.


## display each size and compute F-scores ##

# clean clusters as vectors
cluster.result <- lapply(1:length(centers), function(x) as.vector(iris.models[[x]]$cluster))
# check for null values
sapply(1:length(centers), 
       function(x) iris.models[[x]]$cluster %>% is.null) %>% sum 
# grab all sizes
sizes <- sapply(1:length(centers), function(x) iris.models[[x]]$size)
names(sizes) <- centers
sizes


# grab all f-measures
f1 <- function(x) {
  
  ## Function for a ##
  aa <- function(x,dataset = iris) {
    # ' Only works for iris
    # ' x stands for cluster results
    # ' dataset is predifined as iris. 
    # ' calculating a (number of pairs of items that
    # ' belong to the same cluster in both CC and TC)
    
    
    check <- 0
    for(i in 1:nrow(dataset)){
      for (j in 1:nrow(dataset)){
        if (x[i]==x[j] & dataset$Species[i]==dataset$Species[j]) {
          check <- check + 1
        }
      }
    }
    ifelse(check >=1, check <- check+1, check)
  }
  
  
  
  
  ## Function for b ##
  bb <- function(x,dataset = iris) {
    # ' Only works for iris
    # ' x stands for cluster results
    # ' dataset is predifined as iris. 
    # ' calculating b (number of pairs of items that  
    # ' belong to different clusters in both CC and TC)
    
    check <- 0
    for(i in 1:nrow(dataset)){
      for (j in 1:nrow(dataset)){
        if (x[i]!=x[j] & dataset$Species[i]!=dataset$Species[j]){
          check <- check + 1
        }
      }
    }
    ifelse(check >=1, check <- check - 1, check)
  }
  ## Function for c ##
  cc <- function(x,dataset = iris) {
    check <- 0
    for(i in 1:nrow(dataset)){
      for (j in 1:nrow(dataset)){
        if (x[i]==x[j] & dataset$Species[i] != dataset$Species[j]){
          check <- check + 1
        }
      }
    }
    ifelse(check >=1, check <- check - 1, check)
  }
  ## Function for d ##
  dd <- function(x,dataset = iris) {
    check <- 0
    for(i in 1:nrow(dataset)){
      for (j in 1:nrow(dataset)){
        if (x[i]!=x[j] & dataset$Species[i]==dataset$Species[j]) {
          check <-check + 1
        }
      }
    }
    ifelse(check >=1, check <- check - 1, check)
  }
  ## precision calculation ##
  prec <- function(x) {
    aa(x) / (aa(x)+cc(x))
  }
  ##   recall calculation  ##
  rec <- function(x) {
    aa(x) / (aa(x) + dd(x))
  }
  ## f-measure calculation ##
  precision <- prec(x)
  recall <- rec(x)
  fmeasure <- (2 * precision * recall) / (precision + recall)
  
  # c(fmeasure,recall,precision)
  
  c("f-measure" = fmeasure, "recall" = recall, "precision" = precision)
}
lapply(cluster.result, function(x) f1(x)[1]) %>% 
  unlist -> fmez
names(fmez) <- centers
#### c #### Best F-score (highest) ####
which.max(fmez) # 3 clusters.
hullplot(sets, iris.models[[2]], main = "k-means") # graphical representation of 3-means.

#### d ####
# Interesting how the k-means procedure allowed for automatic clustering with specified means.
# However, this method will not work with categorical datasets (use k-medioids). Another thing
# to recognize is how our criterion for f-measure is calculated on the proportion of false 
# positives and false negatives. Though this took a while to calculate, it depicts 3 means as
# the best f-value.

#### 4 ####
#### Run the hierarchical agglomerative clustering algorithm (hclust in R) on the iris dataset
#### using complete link for the distance. Be mindful that hclust requires a distance matrix
#### rather than a set of points as input. You can easily transform a set of points into its
#### equivalent distance matrix using the dist() function. From iris_copy, you could thus
#### construct iris_dist with the command: 'iris_dist <- dist(iris_copy)'. You can then run
#### hclust on iris_dist.



## hierarchical agglomerative clustering algorithm using complete linkage (maximum dist.) ##

d <- dist(sets) # By default, the complete linkage method is used. for distance matrix
fit <- hclust(d, method="complete") 

plot(fit)
rect.hclust(fit,k=3) # we see 3 or 4 clusters


clusterCut <- cutree(clusters, 3)
# visual plot of 3 clusters.
ggplot(iris, aes(Petal.Length, Petal.Width, color = iris$Species)) + 
  geom_point(alpha = 0.4, size = 3.5) + geom_point(col = clusterCut) + 
  scale_color_manual(values = c('black', 'red', 'green'))



# From the plot of dendrogram,we notice 3 or 4 clusters to be a ideal. This is because
# the clusters are tightly bound until the number of clusters gets to 4. However, because
# there is a slight jump from 3 to 4, we can reasonably conclude 3 clusters.


## cluster size and composition comparison between hclust and kmeans ##

# kmeans clusters
iris.models[[2]]$cluster %>% as.vector %>%
  factor -> kmeans

# heiarchial clusters
cutree(fit,k=3) %>% as.vector %>%
  factor -> hclusts

sapply(1:3, function(x) sum(kmeans==x)) # size of k-meanscluster # 1, 2, 3
sapply(1:3, function(x) sum(hclusts==x)) # size of hcluster # 1, 2, 3

lapply(1:3, function(x) which(kmeans==x)) # Datapoints of each kmeanscluster 1,2,3
lapply(1:3, function(x) which(hclusts==x)) # Datapoints of each hcluster 1,2,3



# For the group of 3 clusters, we realize that both clusters are sized differently.
# However, some of the datapoints overlap in similar groups of clusters we see how 
# similar each group is in the code below. 2 of the groups have very similar cluster
# points, however one of the clusters is not equal to each other.

lapply(c(2,1,3), function(x) which(kmeans==x))[[1]] %in% 
  lapply(1:3, function(x) which(hclusts==x))[[1]] %>% sum # 50 similar
lapply(c(2,1,3), function(x) which(kmeans==x))[[2]] %in% 
  lapply(1:3, function(x) which(hclusts==x))[[2]] %>% sum # 34 similar
lapply(c(2,1,3), function(x) which(kmeans==x))[[3]] %in% 
  lapply(1:3, function(x) which(hclusts==x))[[3]] %>% sum # 0



#### 5 ####
#### Run the density-based clustering algorithm (dbscan in R) on the iris dataset. Be mindful
#### that dbscan requires a numeric matrix rather than a set of points as input. You can easily
#### transform a set of points into its equivalent numeric matrix using the as_matrix()
#### function. From iris_copy, you could thus construct iris_mat with the command: 'iris_mat
#### <- as.matrix(iris_copy)'. You can then run dbscan on iris_mat.

iris.mat <- as.matrix(sets)


epsilons <- c(0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0)

dbscans <- lapply(epsilons,function(x) dbscan(iris.mat,eps = x))


# grab all sizes
db.sizes <- sapply(1:length(epsilons), function(x) dbscans[[1]]$cluster %>% table)
names(db.sizes) <- epsilons
sizes


# grab all f-measures
lapply(1:length(epsilons),function(x) f1(dbscans[[x]]$cluster)[1]) %>%
  unlist -> db.fmez

max(db.fmez) # maximum is 1.0

## comments.
# we notice here that our epsilon of 1 is ideal. This means that the distance of our points 
# are spread by 1. We notice that our accuracy increases as we specify more correct distances 
# between each of our points. However, even with epsilon of 1, we only get 2 clusters.


## cluster size and composition comparison between dbscan, hclust, and kmeans

# kmeans clusters
iris.models[[2]]$cluster %>% as.vector %>%
  factor -> kmeans

# heiarchial clusters
cutree(fit,k=3) %>% as.vector %>%
  factor -> hclusts

# dbscan clusters

dbscans[[7]]$cluster %>% as.vector %>%
  factor -> dbscanss



sapply(1:3, function(x) sum(kmeans==x)) # size of k-means cluster # 1, 2, 3
sapply(1:3, function(x) sum(hclusts==x)) # size of hcluster # 1, 2, 3
sapply(1:2, function(x) sum(dbscanss==x)) # size of dbscan cluster 1, 2


lapply(1:3, function(x) which(kmeans==x)) # Datapoints of each kmeans cluster 1,2,3
lapply(1:3, function(x) which(hclusts==x)) # Datapoints of each hcluster 1,2,3
lapply(1:2, function(x) which(dbscanss==x)) # Datapoints of each dbscan cluster 1,22

# To compare the cluster compositions of dbscan with the other two would be unfair.
# This is because we are comparing 2 clusters against 3. We also notice different
# compositions of clusters. The optimal method seemed to be with the k-means.




#### 6 ####
#### Consider the swiss dataset (swiss was loaded above when you loaded the R datasets
#### package). Use a clustering algorithm, whichever of the three studied here seems to make
#### most sense, to produce a list of the Swiss cities predominantly protestant and those
#### predominantly catholic. You may produce a graph or simply a list of the cities.

data("swiss")
glimpse(swiss)
plot(swiss$Catholic)
# run dbscan becacuse we already know to look for 2 clusters of predominantly catholic and 
# protestant. Also, the clusters may not be spherical nor convex. Works well for compact and 
# well separated cluster The best epsilon is given by kNNdistplot().


kNNdistplot(swiss[,5] %>% as.matrix,k=2)
abline(h = 2,col="red")

gg <- dbscan(swiss_mat,eps = 6,minPts = 5)


cbind("cities" = rownames(swiss),"cluster" = gg$cluster,
      "group" = ifelse(gg$cluster==0,"noise",ifelse(gg$cluster==1,"Protestant","Catholic")),
      "%" = swiss$Catholic) %>% 
  data.frame

plot(swiss$Catholic,col = gg$cluster+1,pch=20)

# Fortunately, we observe only 4 "noise" points. We may consider noise points to be cities 
# that are neither predominantly catholic nor Protestant