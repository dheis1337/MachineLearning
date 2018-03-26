library(ISLR)
library(ggplot2)
library(data.table)
library(MASS)
library(boot)
library(leaps)
library(glmnet)

# This script is for answering the exercises in Chapter 6 of ISL, which covers 
# topics on regularization and subset selection.

# 8. 
# In this exercise, we will generate simulated data, and will then use
# this data to perform best subset selection.

# (a) Use the rnorm() function to generate a predictor X of length
# n = 100, as well as a noise vector ? of length n = 100.
x <- rnorm(100)
noise <- rnorm(100)

# (b) Generate a response vector Y of length n = 100 according to
# the model
# Y = ?? 0 + ?? 1 X + ?? 2 X 2 + ?? 3 X 3 + ?,
# where ?? 0 , ?? 1 , ?? 2 , and ?? 3 are constants of your choice.
y <- 1 + 2.5*x + 3.2*x^2 + 1.3*x^3 + noise

# (c) Use the regsubsets() function to perform best subset selection
# in order to choose the best model containing the predictors
# X,X 2 ,...,X 10 . What is the best model obtained according to
# C p , BIC, and adjusted R 2 ? Show some plots to provide evidence
# for your answer, and report the coefficients of the best model ob-
# tained. Note you will need to use the data.frame() function to
# create a single data set containing both X and Y .
dat <- poly(x, degree = 10)
dat <- data.table(dat[1:100, ])
dat[, y := y]

regfit <- regsubsets(y ~ ., data = dat)
summary(regfit)
summary(regfit)$cp
summary(regfit)$adjr2
summary(regfit)$bic

# (d) Repeat (c), using forward stepwise selection and also using back-
#   wards stepwise selection. How does your answer compare to the
# results in (c)?
regfit.forward <- regsubsets(y ~ ., data = dat, method = "forward")
summary(regfit.forward)
summary(regfit.forward)$cp
summary(regfit.forward)$adjr2
summary(regfit.forward)$bic

regfit.backward <- regsubsets(y ~ ., data = dat, method = "backward")
summary(regfit.backward)
summary(regfit.backward)$cp
summary(regfit.backward)$adjr2
summary(regfit.backward)$bic
# (e) Now fit a lasso model to the simulated data, again using X,X 2 ,
# ...,X 10 as predictors. Use cross-validation to select the optimal
# value of ??. Create plots of the cross-validation error as a function
# of ??. Report the resulting coefficient estimates, and discuss the
# results obtained.
train <- sample(1:100, 66)
lambs <- 10^seq(10, -2, length = 100)
lasso <- cv.glmnet(as.matrix(dat[train, ]), y = y[train], alpha = 1)


# (f) Now generate a response vector Y according to the model
# Y = ?? 0 + ?? 7 X 7 + ?,
# and perform best subset selection and the lasso. Discuss the
# results obtained.
y2 = coef(las)

# 9. 
# In this exercise, we will predict the number of applications received
# using the other variables in the College data set.


# (a) Split the data set into a training set and a test set.
index <- sample(1:777, round(777/2))
train <- College[index, -1]
test <- College[-index, -1]

# (b) Fit a linear model using least squares on the training set, and
# report the test error obtained.
least.sq <- lm(Apps ~ ., data = train[])
least.preds <- predict(least.sq, newdata = test)

test.mse <- mean((least.preds - test$Apps)^2)

# (c) Fit a ridge regression model on the training set, with ?? chosen
# by cross-validation. Report the test error obtained.
train.mat <- train[, -2]
train.mat <- as.matrix(train.mat)
test.mat <- test[, -2]
test.mat <- as.matrix(test.mat)


ridge.cv <- cv.glmnet(x = train.mat, y = train$Apps, alpha = 0)
ridge.pred <- predict(ridge.cv, newx = test.mat)

ridge.mse <- mean((ridge.pred - test$Apps)^2)

# (d) Fit a lasso model on the training set, with ?? chosen by cross-
# validation. Report the test error obtained, along with the num-
# ber of non-zero coefficient estimates.
lasso <- cv.glmnet(x = train.mat, y = train$Apps, alpha = 1)
lasso.preds <- predict(lasso, newx = test.mat)

lasso.mse <- mean((lasso.preds - test$Apps)^2)

# (e) Fit a PCR model on the training set, with M chosen by cross-
# validation. Report the test error obtained, along with the value
# of M selected by cross-validation.

# (f) Fit a PLS model on the training set, with M chosen by cross-
# validation. Report the test error obtained, along with the value
# of M selected by cross-validation.

# (g) Comment on the results obtained. How accurately can we pre-
# dict the number of college applications received? Is there much
# difference among the test errors resulting from these five ap-
# proaches?


# 11. 
# We will now try to predict per capita crime rate in the Boston data
# set.


# (a) Try out some of the regression methods explored in this chapter,
# such as best subset selection, the lasso, ridge regression, and
# PCR. Present and discuss results for the approaches that you
# consider.
index <- sample(1:nrow(Boston), nrow(Boston)/2)
train <- Boston[index, ]
test <- Boston[-index, ]

# (b) Propose a model (or set of models) that seem to perform well on
# this data set, and justify your answer. Make sure that you are
# evaluating model performance using validation set error, cross-
#   validation, or some other reasonable alternative, as opposed to
# using training error.
least.Bos <- lm(crim ~ ., data = train)
ridge.Bos <- cv.glmnet(x = as.matrix(train[2:length(train)]), y = train$crim, alpha = 0)
lasso.Bos <- cv.glmnet(x = as.matrix(train[2:length(train)]), y = train$crim, alpha = 1)

least.preds <- predict(least.Bos, newdata = test)
ridge.preds <- predict(ridge.Bos, newx = as.matrix(test[2:length(test)]))
lasso.preds <- predict(lasso.Bos, newx = as.matrix(test[2:length(test)]))

mean((least.preds - test$crim)^2)
mean((ridge.preds - test$crim)^2)
mean((lasso.preds - test$crim)^2)


# (c) Does your chosen model involve all of the features in the data
# set? Why or why not?
 
