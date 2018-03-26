library(ISLR)
library(ggplot2)
library(data.table)
library(MASS)
library(boot)

# This script is for answering the exercises in Chapter 5 of ISL, which is on
# resampling methods

# 
# 5. In Chapter 4, we used logistic regression to predict the probability of
# default using income and balance on the Default data set. We will
# now estimate the test error of this logistic regression model using the
# validation set approach. Do not forget to set a random seed before
# beginning your analysis.

# (a) Fit a logistic regression model that uses income and balance to
# predict default.
default.log <- glm(default ~ income + balance, data = Default, family = binomial)

# (b) Using the validation set approach, estimate the test error of this
# model. In order to do this, you must perform the following steps:
  # i. Split the sample set into a training set and a validation set.
  set.seed(1)
  valid <- sample(1:10000, 5000)
  train <- Default[-valid, ]
  test <- Default[valid, ]
  # ii. Fit a multiple logistic regression model using only the train-
    # ing observations.
  default.log.train <- glm(default ~ income + balance, data = train, family = binomial)
  
  # iii. Obtain a prediction of default status for each individual in
    # the validation set by computing the posterior probability of
    # default for that individual, and classifying the individual to
    # the default category if the posterior probability is greater
    # than 0.5.
  default.preds <- predict(default.log.train, newdata = test, type = "response")
  default.preds[default.preds > .5] <- "Yes"
  default.preds[default.preds <= .5] <- "No"
  
  # iv. Compute the validation set error, which is the fraction of
    # the observations in the validation set that are misclassified.
    mean(test$default == default.preds)
  
# (c) Repeat the process in (b) three times, using three different splits
# of the observations into a training set and a validation set. Com-
#   ment on the results obtained.
    set.seed(2)
    valid <- sample(1:10000, 5000)
    train <- Default[-valid, ]
    test <- Default[valid, ]
    
    default.log.train <- glm(default ~ income + balance, data = train, family = binomial)
    
    default.preds <- predict(default.log.train, newdata = test, type = "response")
    default.preds[default.preds > .5] <- "Yes"
    default.preds[default.preds <= .5] <- "No"

    mean(test$default == default.preds)
    
    set.seed(3)
    valid <- sample(1:10000, 5000)
    train <- Default[-valid, ]
    test <- Default[valid, ]
    
    default.log.train <- glm(default ~ income + balance, data = train, family = binomial)
    
    default.preds <- predict(default.log.train, newdata = test, type = "response")
    default.preds[default.preds > .5] <- "Yes"
    default.preds[default.preds <= .5] <- "No"
    
    mean(test$default == default.preds)
# (d) Now consider a logistic regression model that predicts the prob-
#   ability of default using income , balance , and a dummy variable
# for student . Estimate the test error for this model using the val-
# idation set approach. Comment on whether or not including a
# dummy variable for student leads to a reduction in the test error
# rate.
    set.seed(1)
    valid <- sample(1:10000, 5000)
    train <- Default[-valid, ]
    test <- Default[valid, ]
    
    default.log.train <- glm(default ~ income + balance + student, data = train, family = binomial)
    
    default.preds <- predict(default.log.train, newdata = test, type = "response")
    default.preds[default.preds > .5] <- "Yes"
    default.preds[default.preds <= .5] <- "No"
    
    mean(test$default == default.preds)
 
# 6. 
# We continue to consider the use of a logistic regression model to
# predict the probability of default using income and balance on the
# Default data set. In particular, we will now compute estimates for
# the standard errors of the income and balance logistic regression co-
# efficients in two different ways: (1) using the bootstrap, and (2) using
# the standard formula for computing the standard errors in the glm()
# function. Do not forget to set a random seed before beginning your
# analysis.

# (a) Using the summary() and glm() functions, determine the esti-
# mated standard errors for the coefficients associated with income
# and balance in a multiple logistic regression model that uses
# both predictors.
summary(default.log)
default.log
# (b) Write a function, boot.fn() , that takes as input the Default data
# set as well as an index of the observations, and that outputs
# the coefficient estimates for income and balance in the multiple
# logistic regression model.
boot.fn <- function(data, index) {
  return(coef(glm(default ~ income + balance, data = data, subset = index, family = binomial)))
}

# (c) Use the boot() function together with your boot.fn() function to
# estimate the standard errors of the logistic regression coefficients
# for income and balance .
boot(Default, boot.fn, 1000)

# (d) Comment on the estimated standard errors obtained using the
# glm() function and using your bootstrap function.      


# 7.
# In Sections 5.3.2 and 5.3.3, we saw that the cv.glm() function can be
# used in order to compute the LOOCV test error estimate. Alterna-
# tively, one could compute those quantities using just the glm() and
# predict.glm() functions, and a for loop. You will now take this ap-
# proach in order to compute the LOOCV error for a simple logistic
# regression model on the Weekly data set. Recall that in the context
# of classification problems, the LOOCV error is given in (5.4).

# (a) Fit a logistic regression model that predicts Direction using Lag1
# and Lag2 .

# (b) Fit a logistic regression model that predicts Direction using Lag1
# and Lag2 using all but the first observation.
weekly.log <- glm(Direction ~ Lag1 + Lag2, data = Weekly, subset = -1, family = binomial)

# (c) Use the model from (b) to predict the direction of the first obser-
# vation. You can do this by predicting that the first observation
# will go up if P( Direction="Up" | Lag1 , Lag2 ) > 0.5. Was this ob-
# servation correctly classified?
predict.glm(weekly.log, newdata = Weekly[1, ], type = "response")

# (d) Write a for loop from i = 1 to i = n, where n is the number of
# observations in the data set, that performs each of the following
# steps:
  # i. Fit a logistic regression model using all but the ith obser-
    # vation to predict Direction using Lag1 and Lag2 .
  # ii. Compute the posterior probability of the market moving up
    # for the ith observation.
  # iii. Use the posterior probability for the ith observation in order
    # to predict whether or not the market moves up.
  # iv. Determine whether or not an error was made in predicting
    # the direction for the ith observation. If an error was made,
    # then indicate this as a 1, and otherwise indicate it as a 0.

results <- vector("numeric", length = nrow(Weekly))
for (i in 1:nrow(Weekly)) {
  fit <- glm(Direction ~ Lag1 + Lag2, data = Weekly, subset = -i, family = binomial)
  pred <- predict.glm(fit, newdata = Weekly[i, ], type = "response")
  pred <- ifelse(pred > .5, "Up", "Down")
  if (pred == Weekly[i, "Direction"]) {
    results[i] <- 1
  } else {
    results[i] <- 0
  }
}

# (e) Take the average of the n numbers obtained in (d).iv in order to
# obtain the LOOCV estimate for the test error. Comment on the
# results.
mean(results)


# 8. 
# We will now perform cross-validation on a simulated data set.

# (a) Generate a simulated data set as follows:
set.seed(1)
y=rnorm(100)
x=rnorm(100)
y=x-2*x^2+rnorm(100)
dat <- data.frame(x = x, y = y)
# In this data set, what is n and what is p? Write out the model
# used to generate the data in equation form.

# (b) Create a scatterplot of X against Y . Comment on what you find.
ggplot(dat, aes(x = x, y = y)) +
  geom_point()

# (c) Set a random seed, and then compute the LOOCV errors that
# result from fitting the following four models using least squares:

# i. Y = B 0 + B 1 X + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ x, data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# ii. Y = B 0 + B 1 X + B 2 X 2 + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 2), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# iii. Y = B 0 + B 1 X + B 2 X 2 + B 3 X 3 + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 3), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# iv. Y = B 0 + B 1 X + B 2 X 2 + B 3 X 3 + B 4 X 4 + ?.
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 4), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)




# Note you may find it helpful to use the data.frame() function
# to create a single data set containing both X and Y .

# (d) Repeat (c) using another random seed, and report your results.
# Are your results the same as what you got in (c)? Why?
set.seed(2)
y=rnorm(100)
x=rnorm(100)
y=x-2*x^2+rnorm(100)
dat <- data.frame(x = x, y = y)

# i. Y = B0 + B1 X + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ x, data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# ii. Y = B 0 + B 1 X + B 2 X 2 + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 2), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# iii. Y = B 0 + B 1 X + B 2 X 2 + B 3 X 3 + ?
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 3), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# iv. Y = B 0 + B 1 X + B 2 X 2 + B 3 X 3 + B 4 X 4 + ?.
results <- vector("numeric", length = nrow(dat))
for (i in 1:nrow(dat)) {
  fit <- lm(y ~ poly(x, degree = 4), data = dat, subset = -i)
  pred <- predict(fit, newdata = dat[i, ])
  results[i] <- (pred - dat[i, "y"])^2
}

mean(results)

# (e) Which of the models in (c) had the smallest LOOCV error? Is
# this what you expected? Explain your answer.
# The model with the smallest LOOCV error was the x^2 model. This is expected, 
# because the scatter plot of the data showed it to have an inverse quadratic relationship
# between x an y

# (f) Comment on the statistical significance of the coefficient esti-
# mates that results from fitting each of the models in (c) using
# least squares. Do these results agree with the conclusions drawn
# based on the cross-validation results?
fit1 <- lm(y ~ x, data = dat)
fit2 <- lm(y ~ poly(x, degree = 2), data = dat)
fit3 <- lm(y ~ poly(x, degree = 3), data = dat)
fit4 <- lm(y ~ poly(x, degree = 4), data = dat)

summary(fit1)
summary(fit2)
summary(fit3)
summary(fit4)

# Yes, these results are in-line with the results from the cross-validation results, 
# because the most significant predictor among all models is the x^2 predictor

