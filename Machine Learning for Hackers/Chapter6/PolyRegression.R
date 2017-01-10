# Chapter 6 covers polynomial regression as well as some common pitfalls with 
# regression models. This is the first introduction to model overfitting, and
# the chapter covers two different topics on how to ensure a given model isn't 
# overfitting training data - cross validation and regularization. Before using 
# any data, the chapter begins by building the foundation of polynomial regression
# with a generated example. 

library(ggplot2)
library(glmnet)

# First, begin by creating a data frame with a sin function to model a wave 
set.seed(1)

x <- seq(-10, 10, by = .01)
y <- 1 - x ^ 2 + rnorm(length(x), 0, 5)
wave <- data.frame(X = x, Y = y)

ggplot(wave, aes(x = X, y = Y)) + 
  geom_point() +
  geom_smooth(se = FALSE)

# Now that our generated data is created, the book begins to explain how regression
# can be applied to nonlinear problems through input transformation. The example
# the book uses is squaring the model inputs, i.e. x values
x.squared <- x ^ 2
wave <- cbind(wave, x.squared)

ggplot(wave, aes(x = x.squared, y = Y)) +
  geom_point() +
  geom_smooth()

# What this has done is essentialy transform our nonlinear problem into a problem 
# that satisfies the linearity assumption of linear regression. We can test to 
# see how well our transformation worked by comparing the R squared values for each 
# regression fit.
summary(lm(y ~ x, data = wave))$r.squared
summary(lm(y ~ x.squared, data = wave))$r.squared

# The difference is really incredible, as we go from a near 0 R squared to a near 1
# R squared. The next part of the chapter dives into polynomial regression and 
# the poly() function in R. This example uses a sin function to create wave data 
# but it's slightly varied than before.
set.seed(1)

x <- seq(0, 1, by = .01)
y <- sin(2 * pi * x) + rnorm(length(x), 0, .1)

wave <- data.frame(X = x, Y = y)

ggplot(wave, aes(x = X, y = Y)) +
  geom_point()

# To hit home the point that polynomial regression is a better model to implement 
# on this example, we begin by running a linear regression as a benchmark
wave.line <- lm(y ~ x, data = wave)
summary(wave.line)

# We can see that our R squared is .5866, so not that spectacular at all. Now 
# we'll begin using polynomial regression without the poly() function.
wave <- transform(wave, X2 = x ^ 2)
wave <- transform(wave, X3 = x ^ 3)
wave.poly <- lm(Y ~ X + X2 + X3, data = wave)
summary(wave.poly)

# Now we have an R squared of .9687, which is much better than what we had before. 
# The first problem with running polynomial regression is presented next, which 
# is adding higher degree terms until a singularity is reached. Which essentially
# happens when additional columns aren't providing any new information since they're
# so correlated. This is where the poly() function is so useful, because we can 
# create higher degree term columns that are orthognal from one another with one 
# simply function call. 
wave.poly <- lm(Y ~ poly(X, degree = 14), data = wave)
summary(wave.poly)

# While higher degree polynomials fit your data better and better, there are also
# diminishing returns associated with degree increases. Here's an example proving 
# this using scatterplots and different degree polynomial regressions. 

wave.poly <- lm(Y ~ poly(X, degree = 1), data = wave)
wave <- transform(wave, PredictedY = predict(wave.poly))

ggplot(wave, aes(x = X, y = PredictedY)) + 
  geom_point() +
  geom_smooth()


wave.poly <- lm(Y ~ poly(X, degree = 3), data = wave)
wave <- transform(wave, PredictedY = predict(wave.poly))

ggplot(wave, aes(x = X, y = PredictedY)) + 
  geom_point() +
  geom_smooth()


wave.poly <- lm(Y ~ poly(X, degree = 5), data = wave)
wave <- transform(wave, PredictedY = predict(wave.poly))

ggplot(wave, aes(x = X, y = PredictedY)) + 
  geom_point() +
  geom_smooth()


wave.poly <- lm(Y ~ poly(X, degree = 15), data = wave)
wave <- transform(wave, PredictedY = predict(wave.poly))

ggplot(wave, aes(x = X, y = PredictedY)) + 
  geom_point() +
  geom_smooth(se = FALSE)



wave.poly <- lm(Y ~ poly(X, degree = 25), data = wave)
wave <- transform(wave, PredictedY = predict(wave.poly))

ggplot(wave, aes(x = X, y = PredictedY)) + 
  geom_point() +
  geom_smooth()


# We can see through the various plots that as the degree gets greater and greater, 
# the prediction actually begins to introduce a lot of errors and produce its own noise. 
# This is where the chapter begins to talk about cross validation and regularization 
# as methods to ensure our model isn't overfitting our data. Let's begin with the 
# former. 

# The book begins with a simple example conitnuing with our sin wave. 
set.seed(1)

x <- seq(0, 1, by = .01)
y <- sin(2 * pi * x) + rnorm(length(x), 0, .1)

# Now, let's split our data. 
n <- length(x)
index <- sample(1:n, size = round(.5 * n))
index <- sort(index) # sort data so sin wave structure still holds

# Split data into training and test
training.x <- x[index]
training.y <- y[index]

test.x <- x[-index]
test.y <- y[-index]

# Create two data frames for test and training data
training.df <- data.frame(X = training.x, Y = training.y)
test.df <- data.frame(X = test.x, Y = test.y)

# We're going to measure our model accuarcy using RMSE. Since it's being called
# multiple times, let's create a function to calculate it. 
rmse <- function(y, h) {
  sqrt(mean((y - h) ^ 2))
}

# Now we'll loop over a set of polynomial degrees, from 1 to 12. 
performance <- data.frame()

for (i in 1:12) {
  poly.fit <- lm(Y ~ poly(X, degree = i), data = training.df)
  
  performance <- rbind(performance, 
                       data.frame(Degree = i,
                                  Data = 'Training',
                                  RMSE = rmse(training.y, predict(poly.fit))))
  performance <- rbind(performance, 
                       data.frame(Degree = i,
                                  Data = 'Test',
                                  RMSE = rmse(test.y, predict(poly.fit, 
                                                              newdata = test.df))))
}

# Now that we've constructed our cross validation data frame, we should visualize
# the results and make some decisions about our model's effectiveness. 
ggplot(performance, aes(x = Degree, y = RMSE, color = Data)) +
  geom_point() +
  geom_line()

# We can see that the model is underfitting the data when the degree is low,
# and the model is overfitting the data as the degree goes beyond 10 - both 
# ranges are associated with greater RMSE values. The optimal degree is somewhere
# in the middle. Now let's talk about regularization!

# The upshot of regularization is determing the balance between a model that is 
# simple that explains less of our data and one that is more complex and explains
# more of our data - the former of which is our goal. We're essentially restricting
# our model so there's less of a chance that it's describing the noise in the data. 
# To work with regularization, we're going to use the glmet package. Let's 
# run a quick example using our sin data frame. First, we need x to be matrix object
x <- as.matrix(x)
x <- cbind(x, x)

# Now we can use glmet function. 
glmnet(x, y)

# This provides a lot of output, check the write-up for this chapter to see 
# what all of these things mean. For now, we're going to use cross validation to 
# determine how much regularization needs to be done. Let's create training and 
# test sets.

x <- seq(0, 1, by = .01)
y <- sin(2 * pi * x) + rnorm(length(x), 0, .1)

index <- sort(sample(1:n, round(.5 * n)))

training.x <- x[index]
training.y <- y[index]

test.x <- x[-index]
test.y <- y[-index]

wave <- data.frame(X = x, Y = y)
training.df <- data.frame(X = training.x, Y = training.y)
test.df <- data.frame(X = test.x, Y = test.y)

# We'll use the RMSE function again for this test but we'll loop over the values 
# of lambda instead of the degrees. We're going to run glmnet on a degree 10 polynomial
# model. First, we need to create our glmnet object. 
glmnet.fit <- with(training.df, glmnet(poly(X, degree = 10), Y))
lambdas <- glmnet.fit$lambda

performance <- data.frame()

for (lambda in lambdas) {
  performance <- rbind(performance, 
                       data.frame(Lambda = lambda,
                                  RMSE = rmse(test.y, with(test.df, predict(glmnet.fit,
                                                                    poly(X, degree = 10),
                                                                    s = lambda)))))
}

# Now that we've computed the model's performance using different values for lambda, 
# let's visualize our results. 
ggplot(performance, aes(x = Lambda, y = RMSE)) +
  geom_point() +
  geom_line()


# It seems like the best performance with is with Lambda at around .05. So, let's 
# fit a model to all of the data. 
best.lambda <- with(performance, Lambda[which(RMSE == min(RMSE))]) # .01 is best lambda

glmnet.fit <- with(wave, glmnet(poly(X, degree = 10), Y))

# Now we have fit the model to our entire data. Let's look at the coefficients 
# for our model. 
coef(glmnet.fit, s = best.lambda)

# This is pretty cool, because through regularization, we've actually simplified 
# a model of degree 10 to a model of degree 4!



 




