library(ISLR)
library(ggplot2)
library(data.table)
library(MASS)

# 10. This question should be answered using the Weekly data set, which
# is part of the ISLR package. This data is similar in nature to the
# Smarket data from this chapter's lab, except that it contains 1,089
# weekly returns for 21 years, from the beginning of 1990 to the end of
# 2010.

# (a) Produce some numerical and graphical summaries of the Weekly
# data. Do there appear to be any patterns?
ggplot(data = Weekly, aes(x = Year)) +
         geom_point(aes(y = Lag1), alpha = .5) +
         geom_point(aes(y = Lag2), color = "red", alpha = .1) +
         geom_point(aes(y = Lag3), col = "blue", alpha =. 1)
       
# Look at correlation between all variables
cor(Weekly[, 2:7])



# (b) Use the full data set to perform a logistic regression with
# Direction as the response and the five lag variables plus Volume
# as predictors. Use the summary function to print the results. Do
# any of the predictors appear to be statistically significant? If so,
# which ones?
weekly.glm <- glm(Direction ~ Lag1 + Lag2 + Lag3 + Lag4 + Lag5 + Volume,
                  data = Weekly, family = binomial)

summary(weekly.glm)

# Based on the summary() output, it appears that the Lag2 estimator is statistically
# significant at the 5% level. 

# (c) Compute the confusion matrix and overall fraction of correct
# predictions. Explain what the confusion matrix is telling you
# about the types of mistakes made by logistic regression.
glm.probs <- predict(weekly.glm, type = "response")

preds.dt <- data.table("Predictions" = glm.probs,
                       "Direction" = rep("Down", 1089))

set(preds.dt, i = which(preds.dt$Predictions > .5), j = "Direction", "Up")

table(preds.dt$Direction, Weekly$Direction)

# The confusion matrix shows that we correctly predicted 54 + 557 days out of 
# the total. A quick success ratio can be computed as
mean(preds.dt$Direction == Weekly$Direction)

# Thus, we were correct only 56% of the time. However, this is the training error
# rate, so we expect this number to decrease on new data. 

# (d) Now fit the logistic regression model using a training data period
# from 1990 to 2008, with Lag2 as the only predictor. Compute the
# confusion matrix and the overall fraction of correct predictions
# for the held out data (that is, the data from 2009 and 2010).
week2 <- Weekly[Weekly$Year >= 1990 & Weekly$Year <= 2008, ]
test <- Weekly[Weekly$Year > 2008, ]

glm.fit <- glm(Direction ~ Lag2, data = week2, family = binomial)

glm.probs <- predict(glm.fit, test, type = "response")
glm.pred <- rep("Down", 104)
glm.pred[glm.probs > .5] = "Up"

table(glm.pred, test$Direction)

# Here, it appears that 

# (e) Repeat (d) using LDA.
lda.fit <- lda(Direction ~ Lag1 + Lag2 + Lag3 + Lag4 + Lag5 + Volume,
               data = Weekly)

lda.fit 

# Here we can see that the prior probability of the market going up is .55556 
# and the prior probability of the market going down is .444444. The outpu above
# also shows us what will be used for the estimated Group Means in the discriminant
# function. Finally, it shows the coefficients used to determine our linear boundaries
lda.pred <- predict(lda.fit, test)

lda.class <- lda.pred$class
table(lda.class, test$Direction)

mean(lda.class == week2$Direction)

# (f) Repeat (d) using QDA.

# (g) Repeat (d) using KNN with K = 1.

# (h) Which of these methods appears to provide the best results on
# this data?

# (i) Experiment with different combinations of predictors, includ-
#   ing possible transformations and interactions, for each of the
# methods. Report the variables, method, and associated confu-
#   sion matrix that appears to provide the best results on the held
# out data. Note that you should also experiment with values for
# K in the KNN classifier.

# 11:
# In this problem, you will develop a model to predict whether a given
# car gets high or low gas mileage based on the Auto data set.
str(Auto)
summary(Auto)
cor(Auto[1:7])

# (a) Create a binary variable, mpg01 , that contains a 1 if mpg contains
# a value above its median, and a 0 if mpg contains a value below
# its median. You can compute the median using the median()
# function. Note you may find it helpful to use the data.frame()
# function to create a single data set containing both mpg01 and
# the other Auto variables.
Auto$mpg01 <- rep(0, nrow(Auto))
set(Auto, i = which(Auto$mpg > median(Auto$mpg)), j = "mpg01", value = 1)

# (b) Explore the data graphically in order to investigate the associ-
#   ation between mpg01 and the other features. Which of the other
# features seem most likely to be useful in predicting mpg01 ? Scat-
#   terplots and boxplots may be useful tools to answer this ques-
#   tion. Describe your findings.
ggplot(Auto, aes(x = factor(cylinders), y = mpg01)) +
  geom_boxplot()

ggplot(Auto, aes(x = factor(mpg01), y = horsepower)) +
  geom_boxplot()

ggplot(Auto, aes(x = factor(mpg01), y = weight)) +
  geom_boxplot()

ggplot(Auto, aes(x = factor(mpg01), y = acceleration)) +
  geom_boxplot()

ggplot(Auto, aes(x = factor(mpg01), y = displacement)) +
  geom_boxplot()

ggplot(Auto, aes(x = year, y = weight, col = mpg01)) +
  geom_point() +
  geom_jitter()

# (c) Split the data into a training set and a test set.
idx <- sample(1:nrow(Auto), size = 200)
train <- Auto[idx, ]
test <- Auto[-idx, ]

# (d) Perform LDA on the training data in order to predict mpg01
# using the variables that seemed most associated with mpg01 in
# (b). What is the test error of the model obtained?
lda.mpg <- lda(mpg01 ~ year + weight, data = train)
lda.preds <- predict(lda.mpg, test)

mean(lda.preds$class == test$mpg01)

# (e) Perform QDA on the training data in order to predict mpg01
# using the variables that seemed most associated with mpg01 in
# (b). What is the test error of the model obtained?
qda.mpg <- qda(mpg01 ~ year + weight, data = train)

qda.preds <- predict(qda.mpg, test)

table(qda.preds$class, test$mpg01)

mean(qda.preds$class == test$mpg01)

# (f) Perform logistic regression on the training data in order to pre-
#   dict mpg01 using the variables that seemed most associated with
# mpg01 in (b). What is the test error of the model obtained?
logis.mpg <- glm(mpg01 ~ year + weight, data = Auto, family = binomial)

logis.preds <- predict(logis.mpg, test, type = "response")

logis.preds <- round(logis.preds)

mean(logis.preds == test$mpg01)

table(logis.preds, test$mpg01)
# (g) Perform KNN on the training data, with several values of K, in
# order to predict mpg01 . Use only the variables that seemed most
# associated with mpg01 in (b). What test errors do you obtain?
# Which value of K seems to perform the best on this data set?

# 13:
# Using the Boston data set, fit classification models in order to predict
# whether a given suburb has a crime rate above or below the median.
# Explore logistic regression, LDA, and KNN models using various sub-
# sets of the predictors. Describe your findings.
str(Boston)
summary(Boston)

Boston$crim01 <- rep(0, nrow(Boston))
set(Boston, i = which(Boston$crim > median(Boston$crim)), j = "crim01", value = 1)

idx <- sample(1:nrow(Boston), size = 300)
train <- Boston[idx, ]
test <- Boston[-idx, ]

# EDA
# Histograms
ggplot(Boston, aes(x = rm, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(medv, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(lstat, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(x = tax, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(x = black, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(x = ptratio, fill = factor(crim01))) +
  geom_histogram()

ggplot(Boston, aes(x = dis, fill = factor(crim01))) +
  geom_histogram()


# Two-variable scatter plots with color of points mapped to the crim01 response
ggplot(Boston, aes(x = lstat, y = medv, col = crim01)) +
  geom_point()

ggplot(Boston, aes(x = tax, y = medv, col = crim01)) +
  geom_point()

ggplot(Boston, aes(x = age, y = rm, col = crim01)) +
  geom_point()


# Logistic Regression. I will first build a model with age, lstat, medv, dis, and
# tax
logis.crim <- glm(crim01 ~ lstat + medv + age + dis + tax, data = train, family = binomial)

summary(logis.crim)

logis.preds <- predict(logis.crim, test, type = "response")
logis.preds <- round(logis.preds)
 
mean(logis.preds == test$crim01)

# It looks like we're correctly predicting 83% of observations in the test data set. 
# I'm going to remove the non-significant predictor lstat, and add in the ptratio,
# rad, and black
logis.crim <- glm(crim01 ~ medv + age + dis + tax + black + rad + ptratio, data = train, 
                  family = binomial)


summary(logis.crim)

logis.preds <- predict(logis.crim, test, type = "response")
logis.preds <- round(logis.preds)

mean(logis.preds == test$crim01)

# Now it seems that the tax predictor went from extremely significant, to not significant. 
# I chalk this up to collinearity to other predictors. Since it was so significant 
# in the original model, I'm going to drop the ptratio and black predictors and 
# see what happens
logis.crim <- glm(crim01 ~ medv + age + dis + tax + rad, data = train, 
                  family = binomial)


summary(logis.crim)

logis.preds <- predict(logis.crim, test, type = "response")
logis.preds <- round(logis.preds)

mean(logis.preds == test$crim01)

# LDA
lda.crim <- lda(crim01 ~ medv + age + dis + tax + rad, data = train)

lda.preds <- predict(lda.crim, test)

mean(lda.preds$class == test$crim01)

# QDA
qda.crim <- qda(crim01 ~ medv + age + dis + tax + rad, data = train)

qda.preds <- predict(qda.crim, test)

mean(qda.preds$class == test$crim01)

