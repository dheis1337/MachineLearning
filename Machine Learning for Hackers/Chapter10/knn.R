# Chapter 10 is about k nearest neighbor classification. The chapter begins
# with a simple example using some example data, and then works on 
# a case study regarding website recommendation. First, we'll begin by reading
# in the example data.  

setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter10")

library(ggplot2)
library(class)

practice <- read.csv("data/example_data.csv")

# Inspect data
head(practice)

# The practice data set is simple. There are X and Y coordinates and a Label -
# either 0 or 1 - for each observation. In order to conduct our k-NN model, 
# we'll need to calculate distances among the points. To do this, we'll create
# a function that uses our data and produces a matrix where each [i, j] element
# is the distance for each [i, j] pair. 
distance.mat <- function(df) {
  distance <- matrix(rep(NA, times = (nrow(df) ^ 2)), nrow = nrow(df))
  
  for (i in 1:nrow(df)) {
    for (j in 1:nrow(df)) {
      distance[i, j] <- sqrt((df[i, 'X'] - df[j, 'X']) ^ 2 + (df[i, 'Y'] - df[j, 'Y']) ^ 2)
    }
  }
  return(distance)
}

# This function will be used in another function, so no need to call it right now. 
# We need to create another function that will return the k-nearest neighbors
# for a point. This isn't too bad due to our distance matrix that we'll use
# as a preprocessing step in our ultimate funciton.
k.nearest <- function(i, distance, k = 5) {
  return(order(distance[i, ])[2:(k + 1)])
}

# Now, we'll create our final function that will perform the k-NN classification. 
# In the case study, we'll use a k-NN implementation from the 'class' package, 
# but we're building this to gain some intuition about how k-NN works. 
knn <- function(df, k = 5) {
  distance <- distance.mat(df)
  predictions <- rep(NA, nrow(df)) 
  
  for (i in 1:nrow(df)) {
    indices <- k.nearest(i, distance, k = k)
    predictions[i] <- ifelse(mean(df[indices, 'Label']) > .5, 1, 0)
  }
  return(predictions)
}

# This is our final function, that uses the first two functions we created. 
# We'll append the output of this function to our original data frame using transform().
df <- transform(practice, kNNPredictions = knn(practice))

# Now what we have is our original data set with a new column - our kNN predictions. 
# Let's check out how our predictions ended up. 
sum(with(df, Label != kNNPredictions))

# The output of this represents the number of points we predicted incorrectly. 

