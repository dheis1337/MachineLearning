# Chapter 7 focuses on optimization problems that arise when creating machine 
# learning models. The chapter begins by introducing the optim() function in 
# R through a simple example of predicting weight ~ height. 

library(ggplot2)

# Set working directory
setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter7")

# Read in files
h.w <- read.csv("data/01_heights_weights_genders.csv")

# Create a function to predict weight ~ height
height.to.weight <- function(height, a, b) {
  a + b * height
}

# Create a function to measure the squared error of our predictions
squ.err <- function(h.w, a, b) {
  predictions <- with(h.w, height.to.weight(Height, a, b))
  errors <- with(h.w, Weight - predictions)
  sum(errors ^ 2)
}

# Evaluate our error function using a few values for a and b
for (a in seq(-1, 1, by = 1)) {
  for (b in seq(-1, 1, by = 1)) {
    print(squ.err(h.w, a, b))
  }
}

# We can see that some a and b values lead to much smaller squared errors, thus being
# better predictor values for our model. Now let's evaluate this using the optim()
# function in R. 
optim(c(0, 0), function (x) {
  squ.err(h.w, x[1], x[2])
})

# There's a few lines of output here. The $par are the optimum parameters for your 
# model. The $value is the value we got for our squared error (the minimum). Next, 
# the book dives into ridge regression. Ridge regression is similar to least-squares
# regression, but it encourages the coefficients to be small, i.e. it encourages 
# a simpler model. In order to run a ridge regression, we need to add a regularizing
# lambda paramter (a hyperparamter) to our error function. 
ridge.err <- function(h.w, a, b, lambda) {
  predictions <- with(h.w, height.to.weight(Height, a, b))
  errors <- with(h.w, Weight - predictions)
  sum(errors ^ 2) + lambda * (a ^ 2 + b ^ 2)
}

# The value lambda would be found using cross validation in the same way that was 
# done in the Chapter6 example. The book assumes this has been completed, and the 
# value for lambda is 1. 
lambda <- 1

optim(c(0, 0), function (x) {
  ridge.err(h.w, x[1], x[2], lambda)
})

# Using ridge regression, we've decreased the parameters (a and b) of our regression
# model, which leads to a more simplified model. Since we're doing such a simple model,
# there really wasn't a huge change in our paraments. However, when performing 
# more large-scale models, this improvement would increase. 

# At this point, we're going to begin our case study, which is code deciphering. 
# We're going to create an algorithm that can crack a code and we'll try to optimize
# it using the Metropolis method. To build up to our code deciphering algorithm, the 
# book goes through a very simple 

