library(data.table)
library(ggplot2)
library(tree)
library(randomForest)
library(MASS)
library(gbm)
library(ISLR)

# This script is for answering the exercises in Chapter 8 of ISL, which is on
# decision trees.


# 7. In the lab, we applied random forests to the Boston data using mtry=6
# and using ntree=25 and ntree=500 . Create a plot displaying the test
# error resulting from random forests on this data set for a more com-
# prehensive range of values for mtry and ntree . You can model your
# plot after Figure 8.10. Describe the results obtained.
data("Boston")
Boston <- as.data.table(Boston)
index <- sample(1:nrow(Boston), size = nrow(Boston)/2)
train <- Boston[index]
test <- Boston[-index]

# ntree mtry 
rand.Boston1 <- randomForest(train[, -14], y = train$medv, xtest = test[, -14], ytest = test$medv,
                            mtry = (ncol(train) - 1), ntree = 500)

rand.Boston2 <- randomForest(train[, -14], y = train$medv, xtest = test[, -14], ytest = test$medv,
                             mtry = (ncol(train) - 1)/2, ntree = 500)

rand.Boston3 <- randomForest(train[, -14], y = train$medv, xtest = test[, -14], ytest = test$medv,
                             mtry = sqrt(ncol(train) - 1), ntree = 500)

rand.Boston4 <- randomForest(train[, -14], y = train$medv, xtest = test[, -14], ytest = test$medv,
                             mtry = 1, ntree = 500)

# Create an error data.table for rand.Boston1
err.forest1 <- data.table("NumberofTrees" = 1:500,
                         "TestMSE" = rand.Boston1$test$mse,
                         "SubsetSize" = "p")

# Create an error data.table for rand.Boston2
err.forest2 <- data.table("NumberofTrees" = 1:500,
                         "TestMSE" = rand.Boston2$test$mse,
                         "SubsetSize" = "p/2")

# Create an error data.table for rand.Boston1
err.forest3 <- data.table("NumberofTrees" = 1:500,
                         "TestMSE" = rand.Boston3$test$mse,
                         "SubsetSize" = "sqrt(p)")


# Create an error data.table for rand.Boston4
err.forest4 <- data.table("NumberofTrees" = 1:500,
                          "TestMSE" = rand.Boston4$test$mse,
                          "SubsetSize" = "1")


# Row bind the error tables for visualization
err.all <- rbind(err.forest1, err.forest2, err.forest3, err.forest4)


# ggplot visualization for test mse as a function of ntree for each different 
# selection of mtry
ggplot(err.all, aes(x = NumberofTrees, y = TestMSE)) +
  geom_line(aes(color = SubsetSize), size = 1)



 
# 8. In the lab, a classification tree was applied to the Carseats data set af-
# ter converting Sales into a qualitative response variable. Now we will
# seek to predict Sales using regression trees and related approaches,
# treating the response as a quantitative variable.
data("Carseats")
Carseats <- as.data.table(Carseats)

# (a) Split the data set into a training set and a test set.
index <- sample(1:nrow(Carseats), nrow(Carseats)/2)
train <- Carseats[index]
test <- Carseats[-index]

# (b) Fit a regression tree to the training set. Plot the tree, and inter-
# pret the results. What test error rate do you obtain?
car.tree <- tree(Sales ~ ., train)
plot(car.tree)
text(car.tree)

# Calculate test error rate
preds.tree <- predict(car.tree, newdata = test)
mean((preds.tree - test$Sales)^2)

# (c) Use cross-validation in order to determine the optimal level of
# tree complexity. Does pruning the tree improve the test error
# rate?
cv.car <- cv.tree(car.tree)
plot(cv.car$size, cv.car$dev, type = "b")
tree.min <- which.min(cv.car$dev)
points(tree.min, cv.car$dev[tree.min], col = "red")

car.prune <- prune.tree(car.tree, best = 11)
preds.prune <- predict(car.prune, newdata = test)
mean((preds.prune - test$Sales)^2)

# (d) Use the bagging approach in order to analyze this data. What
# test error rate do you obtain? Use the importance() function to
# determine which variables are most important.
car.bag <- randomForest(Sales ~., data = Carseats, mtry = 10,
                        importance = TRUE, ntree = 500)

bag.preds <- predict(car.bag, newdata = test)
mean((bag.preds - test$Sales)^2)

importance(car.bag)

# (e) Use random forests to analyze this data. What test error rate do
# you obtain? Use the importance() function to determine which
# variables are most important. Describe the effect of m, the num-
# ber of variables considered at each split, on the error rate
# obtained.
car.forest <- randomForest(Sales ~., data = train, mtry = 3, ntree = 500, importance = TRUE)
forest.preds <- predict(car.forest, newdata = test)
mean((forest.preds - test$Sales)^2)


# 9. This problem involves the OJ data set which is part of the ISLR
# package.
data(OJ)
OJ <- as.data.table(OJ)
# (a) Create a training set containing a random sample of 800 obser-
# vations, and a test set containing the remaining observations.
index <- sample(1:nrow(OJ), 800)
train <- OJ[index]
test <- OJ[-index]

# (b) Fit a tree to the training data, with Purchase as the response
# and the other variables except for Buy as predictors. Use the
# summary() function to produce summary statistics about the
# tree, and describe the results obtained. What is the training
# error rate? How many terminal nodes does the tree have?
oj.tree <- tree(Purchase ~ ., data = train)

# Summary of tree model
summary(oj.tree)


# (c) Type in the name of the tree object in order to get a detailed
# text output. Pick one of the terminal nodes, and interpret the
# information displayed.
oj.tree


# (d) Create a plot of the tree, and interpret the results.
plot(oj.tree)
text(oj.tree)

# (e) Predict the response on the test data, and produce a confusion
# matrix comparing the test labels to the predicted test labels.
# What is the test error rate?
tree.pred <- predict(oj.tree, newdata = test, type = "class")
table(tree.pred, test$Purchase)

# (f) Apply the cv.tree() function to the training set in order to
# determine the optimal tree size.
oj.cv <- cv.tree(oj.tree, FUN = prune.misclass)


# (g) Produce a plot with tree size on the x-axis and cross-validated
# classification error rate on the y-axis.
plot(oj.cv$size, oj.cv$dev, type = "b")
which.min(oj.cv$dev)

# (h) Which tree size corresponds to the lowest cross-validated classi-
# fication error rate?
# The tree size that corresponds to the lowest c.v. classification error rate
# is two (different sampling could affect this)
# I'm going to cross-validate the tree 1000 times and find the most common 
# tree depth
depth <- vector("numeric", length = 100)
for (i in 1:100) {
  cv <- cv.tree(oj.tree, FUN = prune.misclass)
  depth[i] <- which.min(cv$dev)
}

# 4 is the optimal depth

# (i) Produce a pruned tree corresponding to the optimal tree size
# obtained using cross-validation. If cross-validation does not lead
# to selection of a pruned tree, then create a pruned tree with five
# terminal nodes.
oj.prune = prune.misclass(oj.tree, best = 4)


# (j) Compare the training error rates between the pruned and un-
# pruned trees. Which is higher?
# Unpruned error
summary(oj.tree)

# Pruned Error
summary(oj.prune)

# (k) Compare the test error rates between the pruned and unpruned
# trees. Which is higher?
prune.preds <- predict(oj.prune, newdata = test, type = "class")

table(prune.preds, test$Purchase)

# Pruned Error
1 - ((131 + 91) / 270)

# Unpruned Error
1 - ((142 + 79) / 270)


# 10. We now use boosting to predict Salary in the Hitters data set.
data("Hitters")
Hitters <- as.data.table(Hitters)

# (a) Remove the observations for whom the salary information is
# unknown, and then log-transform the salaries.
Hitters <- Hitters[-which(is.na(Salary))]
Hitters[, Salary := log(Salary)]

# (b) Create a training set consisting of the first 200 observations, and
# a test set consisting of the remaining observations.
index <- sample(1:nrow(Hitters), 200)
train <- Hitters[index]
test <- Hitters[-index]

# (c) Perform boosting on the training set with 1,000 trees for a range
# of values of the shrinkage parameter ??. Produce a plot with
# different shrinkage values on the x-axis and the corresponding
# training set MSE on the y-axis.
mse <- vector("numeric", length = 100)
k <- 1

# Loop for testing different values of lambda
for (i in seq(.001, .1, by = .001)) {
  hit.boost <- gbm(Salary ~., data = train, distribution = "gaussian", n.trees = 1000,
                   shrinkage = i)
  pred.boost <- predict(hit.boost, n.trees = 1000)
  mse[k] <- mean((pred.boost - train$Salary)^2)
  k <- k + 1
}

# Create data.table for visualization
boost.dt <- data.table("Lambda" = seq(.001, .1, by = .001),
                       "TrainMSE" = mse)

# Visualize results
ggplot(boost.dt, aes(x = Lambda, y = TrainMSE)) +
  geom_point() +
  geom_line()

# (d) Produce a plot with different shrinkage values on the x-axis and
# the corresponding test set MSE on the y-axis.
test.mse <- vector("numeric", length = 100)
k <- 1

# Loop for testing different values of lambda
for (i in seq(.0001, .01, by = .0001)) {
  hit.boost <- gbm(Salary ~., data = test, distribution = "gaussian", n.trees = 1000,
                   shrinkage = i)
  pred.boost <- predict(hit.boost, n.trees = 1000)
  test.mse[k] <- mean((pred.boost - test$Salary)^2)
  k <- k + 1
}

# Create data.table for visualization
boost.dt <- data.table("Lambda" = seq(.0001, .01, by = .0001),
                       "TestMSE" = test.mse)

# Visualize results
ggplot(boost.dt, aes(x = Lambda, y = TestMSE)) +
  geom_point() +
  geom_line()


# (e) Compare the test MSE of boosting to the test MSE that results
# from applying two of the regression approaches seen in
# Chapters 3 and 6.

# (f) Which variables appear to be the most important predictors in
# the boosted model?
summary(hit.boost)

# (g) Now apply bagging to the training set. What is the test set MSE
# for this approach?
hit.bag <- randomForest(Salary ~ ., data = train, mtry = 4, ntree = 500, importance = TRUE)

# Calculate predicts on test set
hit.preds <- predict(hit.bag, newdata = test)

# Calculate test MSE
mean((hit.preds - test$Salary)^2)

# 11. This question uses the Caravan data set.
data("Caravan")
Caravan <- as.data.table(Caravan)
Caravan[, Purchase := ifelse(Purchase == "Yes", 1, 0)]

# (a) Create a training set consisting of the first 1,000 observations,
# and a test set consisting of the remaining observations.
index <- sample(1:nrow(Caravan), size = 1000)
train <- Caravan[index]
test <- Caravan[-index]

# (b) Fit a boosting model to the training set with Purchase as the
# response and the other variables as predictors. Use 1,000 trees,
# and a shrinkage value of 0.01. Which predictors appear to be
# the most important?
carv.boost <- gbm(Purchase ~ ., data = train, n.trees = 1000, shrinkage = .01,
                  distribution = "bernoulli")

# Find most important variables
summary(carv.boost)


# (c) Use the boosting model to predict the response on the test data.
# Predict that a person will make a purchase if the estimated prob-
# ability of purchase is greater than 20%. Form a confusion ma-
# trix. What fraction of the people predicted to make a purchase
# do in fact make one? How does this compare with the results
# obtained from applying KNN or logistic regression to this data
# set?
carv.preds <- predict(carv.boost, newdata = test, n.trees = 1000, type = "response")

carv.preds <- ifelse(carv.preds > .2, 1, 0)

table(carv.preds, test$Purchase)

