library(data.table)
library(ggplot2)
library(ISLR)
library(leaps)
library(e1071)

# This script is for chapter 9 of ISL which is on support vector machiens

# 4. Generate a simulated two-class data set with 100 observations and
# two features in which there is a visible but non-linear separation be-
# tween the two classes. Show that in this setting, a support vector
# machine with a polynomial kernel (with degree greater than 1) or a
# radial kernel will outperform a support vector classifier on the train-
# ing data. Which technique performs best on the test data? Make
# plots and report training and test error rates in order to back up
# your assertions.
x <- rnorm(100)
y <- 4 * x^2 + 1 + rnorm(100)
class <- sample(100, 50)
y[class] <- y[class] + 3
y[-class] <- y[-class] - 3
z <- rep(-1, 100)
z[class] <- 1


# Create a data.table
dat <- data.table(x = x, y = y, class = factor(z)) 

index <- sample(100, 50)

train <- dat[index]
test <- dat[-index]

# Plot data
ggplot(dat, aes(x = x, y = y, color = class)) +
  geom_point()

poly.svm <- svm(class ~ ., data = train, kernel = "polynomial", cost = 10)
radial.svm <- svm(class ~ ., data = train, kernel = "radial", cost = 10)
lin.svm <- svm(class ~ ., data = train, kernel = "linear", cost = 10)

# Prediction accuracy for each model on the training data
mean(poly.svm$fitted == train$class)
mean(radial.svm$fitted == train$class)
mean(lin.svm$fitted == train$class)


# Predictions on the test set for each model
poly.preds <- predict(poly.svm, newdata = test)
radial.preds <- predict(radial.svm, newdata = test)
lin.preds <- predict(lin.svm, newdata = test)

# Prediction accuracy for each model on the test data
mean(poly.preds == test$class)
mean(radial.preds == test$class)
mean(lin.preds == test$class)


# 5. We have seen that we can fit an SVM with a non-linear kernel in order
# to perform classification using a non-linear decision boundary. We will
# now see that we can also obtain a non-linear decision boundary by
# performing logistic regression using non-linear transformations of the
# features.

# (a) Generate a data set with n = 500 and p = 2, such that the obser-
# vations belong to two classes with a quadratic decision boundary
# between them. For instance, you can do this as follows:
x1 <- runif(500) -0.5
x2 <- runif(500) -0.5
y <- 1*(x1^2-x2^2 > 0)

dat <- data.table(x1 = x1, x2 = x2, y = factor(y))
# (b) Plot the observations, colored according to their class labels.
# Your plot should display X 1 on the x-axis, and X 2 on the y-
# axis.
ggplot(dat, aes(x = x1, y = x2, color = y)) +
  geom_point()

# (c) Fit a logistic regression model to the data, using X 1 and X 2 as
# predictors.
log.fit <- glm(y ~ x1 + x2, data = dat, family = binomial)

# (d) Apply this model to the training data in order to obtain a pre-
# dicted class label for each training observation. Plot the ob-
# servations, colored according to the predicted class labels. The
# decision boundary should be linear.
dat[, lin.log.preds := ifelse(log.fit$fitted.values > .5, 1, 0)]

ggplot(dat, aes(x = x1, y = x2, color = lin.log.preds)) +
  geom_point()

# (e) Now fit a logistic regression model to the data using non-linear
# functions of X 1 and X 2 as predictors (e.g. X 2
#                                         1 , X 1 ×X 2 , log(X 2 ),
#                                         and so forth).
log.poly.fit <- glm(y ~ poly(x1, 2) + poly(x2, 2) + I(x1 * x2), data = dat, family = binomial,
                    maxit = 50)

dat[, poly.log.preds := ifelse(log.poly.fit$fitted.values > .5, 1, 0)]

ggplot(dat, aes(x = x1, y = x2, color = poly.log.preds)) +
  geom_point()


# (f) Apply this model to the training data in order to obtain a pre-
# dicted class label for each training observation. Plot the ob-
# servations, colored according to the predicted class labels. The
# decision boundary should be obviously non-linear. If it is not,
# then repeat (a)-(e) until you come up with an example in which
# the predicted class labels are obviously non-linear.

# (g) Fit a support vector classifier to the data with X 1 and X 2 as
# predictors. Obtain a class prediction for each training observa-
#   tion. Plot the observations, colored according to the predicted
# class labels.

# (h) Fit a SVM using a non-linear kernel to the data. Obtain a class
# prediction for each training observation. Plot the observations,
# colored according to the predicted class labels.

# (i) Comment on your results.


# 6. At the end of Section 9.6.1, it is claimed that in the case of data that
# is just barely linearly separable, a support vector classifier with a
# small value of cost that misclassifies a couple of training observations
# may perform better on test data than one with a huge value of cost
# that does not misclassify any training observations. You will now
# investigate this claim.
# (a) Generate two-class data with p = 2 in such a way that the classes
# are just barely linearly separable.
x.one <- runif(500, 0, 90)
y.one <- runif(500, x.one + 10, 100)
x.one.noise <- runif(50, 20, 80)
y.one.noise <- 5/4 * (x.one.noise - 10) + 0.1

x.zero <- runif(500, 10, 100)
y.zero <- runif(500, 0, x.zero - 10)
x.zero.noise <- runif(50, 20, 80)
y.zero.noise <- 5/4 * (x.zero.noise - 10) - 0.1

class.one <- rep(1, 550)
class.zero <- rep(-1, 550)
x <- c(x.one, x.one.noise, x.zero, x.zero.noise)
y <- c(y.one, y.one.noise, y.zero, y.zero.noise)

class <- c(class.one, class.zero)

dat <- data.table(x = x, y = y, class = factor(class))

ggplot(dat, aes(x = x, y = y, color = class)) +
  geom_point()


# (b) Compute the cross-validation error rates for support vector
# classifiers with a range of cost values. How many training er-
# rors are misclassified for each value of cost considered, and how
# does this relate to the cross-validation errors obtained?
costs <- c(.00001, .0001, .001, .01, .1, 1, 10)
errs <- vector("numeric", length(costs))

for (i in 1:length(costs)) {
  fit <- svm(class ~ ., data = dat, kernel = "linear", cost = costs[i], scale = FALSE)
  errs[i] <- 1 - mean(fit$fitted == dat$class)

  
}


# (c) Generate an appropriate test data set, and compute the test
# errors corresponding to each of the values of cost considered.
# Which value of cost leads to the fewest test errors, and how
# does this compare to the values of cost that yield the fewest
# training errors and the fewest cross-validation errors?
index <- sample(1100, 550)

train <- dat[index]
test <- dat[-index]

for (i in 1:length(costs)) {
  fit <- svm(class ~ ., data = train, kernel = "linear", cost = costs[i])
  preds <- predict(fit, newdata = test)
  errs[i] <- 1 - mean(preds == test$class)
  
}


# (d) Discuss your results.





# 7. In this problem, you will use support vector approaches in order to
# predict whether a given car gets high or low gas mileage based on the
# Auto data set.
auto <-as.data.table(Auto)

# (a) Create a binary variable that takes on a 1 for cars with gas
# mileage above the median, and a 0 for cars with gas mileage
# below the median.
auto[, mileage := ifelse(auto[, mpg] > median(auto[, mpg]), 1, 0)]
auto[, mileage := factor(mileage)]

# (b) Fit a support vector classifier to the data with various values
# of cost , in order to predict whether a car gets high or low gas
# mileage. Report the cross-validation errors associated with dif-
# ferent values of this parameter. Comment on your results.
costs <- c(.0001, .001, .01, .1, 1, 10, 100)
tuned <- tune(svm, mileage ~ ., data = auto, kernel = "linear", ranges = list(cost = c(.001, .01, .1, 1, 10, 100, 1000)))
summary(tuned)

# (c) Now repeat (b), this time using SVMs with radial and polyno-
#   mial basis kernels, with different values of gamma and degree and
# cost . Comment on your results.
tuned.polynomial <- tune(svm, mileage ~ ., data = auto, kernel = "polynomial", ranges = list(cost = c(.001, .01, .1, 1, 10, 100, 1000)))
summary(tuned.polynomial)

tuned.radial <- tune(svm, mileage ~ ., data = auto, kernel = "radial", ranges = list(cost = c(.001, .01, .1, 1, 10, 100, 1000)))
summary(tuned.radial)

# (d) Make some plots to back up your assertions in (b) and (c).
# Hint: In the lab, we used the plot() function for svm objects
# only in cases with p = 2. When p > 2, you can use the plot()
# function to create plots displaying pairs of variables at a time.
# Essentially, instead of typing
# > plot(svmfit , dat)
# where svmfit contains your fitted model and dat is a data frame
# containing your data, you can type
# > plot(svmfit , dat, x1???x4)
# in order to plot just the first and fourth variables. However, you
# must replace x1 and x4 with the correct variable names. To find
# out more, type ?plot.svm .




# 8. This problem involves the OJ data set which is part of the ISLR
# package.
oj <- as.data.table(OJ)

# (a) Create a training set containing a random sample of 800
# observations, and a test set containing the remaining
# observations.
index <- sample(nrow(oj), 800)
train <- oj[index]
test <- oj[-index]

# (b) Fit a support vector classifier to the training data using
# cost=0.01 , with Purchase as the response and the other variables
# as predictors. Use the summary() function to produce summary
# statistics, and describe the results obtained.
oj.linear <- svm(Purchase ~ ., data = train, cost = .01)
summary(oj.linear)

# (c) What are the training and test error rates?
1 - mean(oj.linear$fitted == train$Purchase)

preds.linear <- predict(oj.linear, newdata = test)
1 - mean(preds.linear == test$Purchase)

# (d) Use the tune() function to select an optimal cost . Consider val-
# ues in the range 0.01 to 10.
tuned.lienar <- tune(svm, Purchase ~ ., data = train, kernel = "linear", ranges = list(cost = c(.01, .1, 1, 5, 10)))
summary(tuned.lienar)

# (e) Compute the training and test error rates using this new value
# for cost .
oj.linear <- svm(Purchase ~ ., data = train, cost = 10)

1 - mean(oj.linear$fitted == train$Purchase)

preds.linear <- predict(oj.linear, newdata = test)
1 - mean(preds.linear == test$Purchase)

# (f) Repeat parts (b) through (e) using a support vector machine
# with a radial kernel. Use the default value for gamma .
tuned.radial <- tune(svm, Purchase ~ ., data = train, kernel = "radial", ranges = list(cost = c(.01, .1, 1, 5, 10)))
summary(tuned.radial)

oj.radial <- svm(Purchase ~ ., data = train, kernel = "radial", cost = 1)

# Train error
1 - mean(oj.radial$fitted == train$Purchase)

# Test error
preds.radial <- predict(oj.radial, newdata = test)
1 - mean(preds.radial == test$Purchase)


# (g) Repeat parts (b) through (e) using a support vector machine
# with a polynomial kernel. Set degree=2 .
tuned.poly <- tune(svm, Purchase ~ ., data = train, kernel = "poly", degree = 2, ranges = list(cost = c(.01, .1, 1, 5, 10)))
summary(tuned.poly)

oj.poly <- svm(Purchase ~ ., data = train, cost = 10)

# Train error
1 - mean(oj.poly$fitted == train$Purchase)

# Test error
preds.poly <- predict(oj.poly, newdata = test)
1 - mean(preds.poly == test$Purchase)



# (h) Overall, which approach seems to give the best results on this
# data?






