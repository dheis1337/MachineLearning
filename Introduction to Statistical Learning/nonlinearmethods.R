library(ISLR)
library(ggplot2)
library(data.table)
library(MASS)
library(boot)
library(DAAG)
library(splines)
library(leaps)
library(gam)

# This script is for answering the exercises in Chapter 7 of ISL, which is on
# non-linear machine learning methods



# 6. In this exercise, you will further analyze the Wage data set considered
# throughout this chapter.
data("Wage")
Wage <-as.data.table(Wage)

# (a) Perform polynomial regression to predict wage using age . Use
# cross-validation to select the optimal degree d for the polyno-
# mial. What degree was chosen, and how does this compare to
# the results of hypothesis testing using ANOVA? Make a plot of
# the resulting polynomial fit to the data.
delta <- vector("numeric", 6)

# Running cross-validation
for (i in 1:6) {
  fit <- glm(wage ~ poly(age, i), data = Wage)
  delta[i] <- cv.glm(Wage, fit, K = 10)$delta[1]
}

# Create a data.table for visualization
cv.results <- data.table("Degree" = seq(1, 6), "Delta" = delta)

# visualize results
ggplot(cv.results, aes(x = Degree, y = delta)) +
  geom_line()

# Now to compare these results to the results received from performing an ANOVA
# test
fit1 <- lm(wage ~ age, data = Wage)
fit2 <- lm(wage ~ poly(age, 2), data = Wage)
fit3 <- lm(wage ~ poly(age, 3), data = Wage)
fit4 <- lm(wage ~ poly(age, 4), data = Wage)
fit5 <- lm(wage ~ poly(age, 5), data = Wage)
fit6 <- lm(wage ~ poly(age, 6), data = Wage)

# Conduct ANOVA test
anova(fit1, fit2, fit3, fit4, fit5, fit6)

# Fit using d = 4
poly.fit <- lm(wage ~ poly(age, 4), data = Wage)

# Add the predicted values to the Wage datat able
Wage[, Predictions := predict(poly.fit, newdata = list(age = Wage$age))]

# plot the resulting fit on the data
ggplot(Wage, aes(x = age, y = wage)) +
  geom_point(alpha = .25) +
  geom_line(aes(x = age, y = Predictions), color = "red", size = 2)

# (b) Fit a step function to predict wage using age , and perform cross-
# validation to choose the optimal number of cuts. Make a plot of
# the fit obtained.
delta <- vector("numeric", length = 10)

# Cross-validation to determine the optimal number of cuts
for (i in 2:10) {
  Wage[, age.cut := cut(age, i)]
  fit <- glm(wage ~ age.cut, data = Wage)
  delta[i] <- cv.glm(Wage, fit, K = 10)$delta[1]
}

# Create a data.table for visualization
cut.cv <- data.table("Cuts" = seq(2, 10), "Deltas" = delta[-1])


# Create a plot of the results
ggplot(cut.cv, aes(x = Cuts, y = Deltas)) +
  geom_line() +
  geom_point()
  

# It looks like 8 cut points is optimal after using cross-validation. 
# Now I'll fit create a model using 8 cuts and create a visualization for that
Wage[, Cuts := cut(age, 8)]

step.fit <- lm(wage ~ Cuts, data = Wage)

# Add the predictions from this model to the data.table
Wage[, StepPreds := predict(step.fit, newdata = list(Cuts = Wage$Cuts))]

# Create visualization
ggplot(Wage, aes(x = age, y = wage)) + 
  geom_point() +
  geom_step(aes(x = Cuts, y = StepPreds))


# 7. The Wage data set contains a number of other features not explored
# in this chapter, such as marital status ( maritl ), job class ( jobclass ),
# and others. Explore the relationships between some of these other
# predictors and wage, and use non-linear fitting techniques in order to
# fit flexible models to the data. Create plots of the results obtained,
# and write a summary of your findings.
str(Wage)

# Maritl variable
ggplot(Wage, aes(x = maritl, y = wage)) +
  geom_bar(stat = "identity", color = "blue")

# education variable
ggplot(Wage, aes(x = education, y = wage)) +
  geom_bar(stat = "identity")

# The maritl variable looked interesting. Let's use logistic regression with it as a 
# predictor and wage as the response. I'll also use the age variable
delta <- vector("numeric", length = 6)

for (i in 1:6) {
  fit <- glm(wage ~ maritl + poly(age, i), data = Wage)
  delta[i] <- cv.glm(Wage, fit, K = 10)$delta[1]
}

multi.cv <- data.table("Degree" = seq(1, 6), "Delta" = delta)

ggplot(multi.cv, aes(x = Degree, y = Delta)) +
  geom_point() +
  geom_line()

# Degree 3 is optimal
multi.fit <- lm(wage ~ maritl + poly(age, 3), data = Wage)


# 9. This question uses the variables dis (the weighted mean of distances
# to five Boston employment centers) and nox (nitrogen oxides concen-
# tration in parts per 10 million) from the Boston data. We will treat
# dis as the predictor and nox as the response.
data("Boston")
Boston <- as.data.table(Boston)
 
# (a) Use the poly() function to fit a cubic polynomial regression to
# predict nox using dis . Report the regression output, and plot
# the resulting data and polynomial fits.
poly.fit <- lm(nox ~ poly(dis, 3), data = Boston)
summary(poly.fit)

Boston[, PolyPreds := predict(poly.fit, newdata = list(dis = Boston$dis))]

# Plotting the predicted function
ggplot(Boston, aes(x = dis, nox)) +
  geom_point() +
  geom_line(aes(x = dis, y = PolyPreds), color = "red", size = 2)

# (b) Plot the polynomial fits for a range of different polynomial
# degrees (say, from 1 to 10), and report the associated residual
# sum of squares.
res <- vector("numeric", length = 10) 

for (i in 1:10) {
  fit <- lm(nox ~ poly(dis, i), data = Boston)
  res[i] <- sum(fit$residuals^2)
}

# Create a data.table for the rss results
res.cv <- data.table("Degree" = seq(1, 10), "Residuals" = res)

# Visualize rss results
ggplot(res.cv, aes(x = Degree, y = res)) +
  geom_point() +
  geom_line()

# (c) Perform cross-validation or another approach to select the optimal degree 
# for the polynomial, and explain your results.
delta <- vector("numeric", length = 10) 

for (i in 1:10) {
  fit <- glm(nox ~ poly(dis, i), data = Boston)
  delta[i] <- cv.glm(data = Boston, glmfit = fit, K = 10)$delta[1]
}

# Create a data.table for cross-validation results
cv.boston <- data.table("Degree" = seq(1, 10), "Delta" = delta)

# Vizualization for cross-validation
ggplot(cv.boston, aes(x = Degree, y = Delta)) +
  geom_point() +
  geom_line() 



# (d) Use the bs() function to fit a regression spline to predict nox
# using dis. Report the output for the fit using four degrees of
# freedom. How did you choose the knots? Plot the resulting fit.
fit.spline <- lm(nox ~ bs(dis, df = 4), data = Boston)

# Add the spline predictions to the Boston data.table
Boston[, spline.preds := predict(fit.spline, newdata = list(dis = Boston$dis))]

# Create plot of points and spline function
ggplot(Boston, aes(x = dis, y = nox)) +
  geom_point() +
  geom_line(aes(y = spline.preds), color = "red", size = 1.5)

# (e) Now fit a regression spline for a range of degrees of freedom, and
# plot the resulting fits and report the resulting RSS. Describe the
# results obtained.
rss <- vector("numeric", length = 10)
for (i in 3:10) {
  fit <- lm(nox ~ bs(dis, df = i), data = Boston)
  rss[i] <- sum(fit$residuals^2)
}

# Remove first two zero entries
rss <- rss[-c(1:2)]

# Create data.table for visualization
spl.rss <- data.table("Dfs" = seq(3:10), "RSS" = rss)

# Visualize rss
ggplot(spl.rss, aes(x = Dfs, y = RSS)) +
  geom_point() +
  geom_line()
# (f) Perform cross-validation or another approach in order to select
# the best degrees of freedom for a regression spline on this data.
# Describe your results.
deltas <- vector("numeric", length = 10)
for (i in 3:10) {
  fit <- glm(nox ~ bs(dis, df = i), data = Boston)
  delta[i] <- cv.glm(Boston, fit, K = 10)$delta[1]
}

# Create a data.table for cv results
cv.spline <- data.table("Dfs" = )

# 10. This question relates to the College data set.
data("College")
College <- as.data.table(College)

# (a) Split the data into a training set and a test set. Using out-of-state
# tuition as the response and the other variables as the predictors,
# perform forward stepwise selection on the training set in order
# to identify a satisfactory model that uses just a subset of the
# predictors.

# Create an index for subsetting the data.table
index <- sample(1:nrow(College), size = nrow(College)/2)

# Create training data.table
train <- College[index]

# Create test data.table
test <- College[-index]

# Conduct forward-stepwise selection
fit.forward <- regsubsets(Outstate ~ ., nvmax = 17, method = "forward", data = College)

# Create a data.table of the cp statistics for the fit 
cp.dt <- data.table("Variables" = 1:17, "Cp" = summary(fit.forward)$cp)
min.cp <- min(cp.dt[, Cp])
std.cp <- sd(cp.dt[, Cp])

# Create visualization for the cp statistics
ggplot(cp.dt, aes(x = Variables, y = Cp)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = min.cp + .2 * std.cp, color = "red")

# From this, it looks like 6 variables is the number of variables we want in our 
# model. This correspoinds to PrivateYes, Room.Board, PhD, perc.alumni, Expend, Grad.Rate


# (b) Fit a GAM on the training data, using out-of-state tuition as
# the response and the features selected in the previous step as
# the predictors. Plot the results, and explain your findings.
fit.gam <- gam(Outstate ~ s(Room.Board, 4) + s(PhD, 4) + s(perc.alumni, 4) +
                s(Expend, 4) + s(Grad.Rate, 4) + Private, data = train)

# (c) Evaluate the model obtained on the test set, and explain thet
# results obtained.
preds <- predict(fit.gam, test)

err <- mean((test$Outstate - preds)^2)


# (d) For which variables, if any, is there evidence of a non-linear
# relationship with the response?
