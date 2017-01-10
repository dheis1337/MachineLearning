# Chapter 4 covers regression. It begins by conduction a few thought experiments
# to convey some of the inner-workings of regression. First, the chapter 
# dives into measuring the predictions made using RMSE. Second, it discusses a 
# simple way to look at how well a linear model performed through measuring residuals. 
# Finally, it conducts a case study on predicting web traffic for the top 1000
# websites on the internet as of 2011. 

library(ggplot2)

setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter5")

# Load in data 
ages <- read.csv("data/longevity.csv")

# Exploratory analysis
head(ages)
summary(ages)

# Create a density plot for each level - smoker and non-smoker
ggplot(ages, aes(x = AgeAtDeath, fill = factor(Smokes))) +
  geom_density() +
  facet_grid(Smokes ~ .)

smokes <- ages[ages$Smokes == 1, ]
no.smokes <- ages[ages$Smokes == 0, ]

mean(smokes$AgeAtDeath)
mean(no.smokes$AgeAtDeath)

# Before the chapter gets into the regression, it sets the framework for regression
# from a general perspective. One important note it makes is that in order to measure 
# the quality of our predictions, we need to use some type of measurement. The book 
# uses the popular Mean-Squared Error. The book conducts a brief thought experiment 
# about making a prediction for some gerneral case, and shows that the best prediction
# one can make (by evaluating through MSE) is the mean. First, let's look at using 
# the mean and determining the MSE for it as a predictor. 
guess <- mean(ages$AgeAtDeath)
guess <- round(guess) # the book rounds this value

# Calculate MSE using 'guess' (73 as our prediction)
mean((ages$AgeAtDeath - guess) ^ 2)

# We see that we get an MSE of 32.991. Now we'll loop through a range of values, 
# compute their MSE's, and then graph them to visually see if using the original 
# mean of the data (73) is indeed the value that minimizes MSE. 
guess.accuracy <- data.frame()

for (i in 63:85) {
  pred.error <- mean((ages$AgeAtDeath - i) ^ 2)
  
  guess.accuracy <- rbind(guess.accuracy, 
                          data.frame(Guess = i, 
                                     Error = pred.error))
}

ggplot(guess.accuracy, aes(x = Guess, y = Error)) +
  geom_point() +
  geom_line()

# Through this plot we can see that 73 is indeed the value that minimizes MSE. 
# From here on out, the book switches to Root Mean-Squared Error (RMSE).
constant.guess <- mean(ages$AgeAtDeath) # save the original mean

smoker.guess <- mean(smokes$AgeAtDeath) # save for guess for smokers
non.smoker.guess <- mean(no.smokes$AgeAtDeath) # save for guess for non-smokers

# Add a column to the ages data frame that associates the appropriate guess (mean)
# for each level. 
ages <- transform(ages, NewPrediction = ifelse(Smokes == 0,
                                               non.smoker.guess, 
                                               smoker.guess))

with(ages, sqrt(mean((AgeAtDeath - NewPrediction) ^ 2)))

# The above line of code represents finding the RMSE using the associated guess, 
# i.e. using smoker's mean for predictions of smokers and non-smoker's mean for non-smokers. 
# We received an error of 5.148622. Let's compare this to the RMSE we calculated using
# the mean for all subjects in our dataset. 
non.strat.err <- sqrt(mean((ages$AgeAtDeath - guess) ^ 2))
strat.err <- with(ages, sqrt(mean((AgeAtDeath - NewPrediction) ^ 2)))

(strat.err - non.strat.err) / non.strat.err

# Looks like we decreased our prediction error by 10% when we stratified our guess
# by level (whether subjects smoked or not).

# The book changes gears now and begins to work on the height and weight dataset. 
h.w <- read.csv("data/01_heights_weights_genders.csv", header = TRUE, sep = ",")

# Let's visualize our data with a quick scatter plot of weights vs heights. 
ggplot(h.w, aes(x = Height, y = Weight)) +
  geom_point()

# Through this basic visualization we can see that there is a linear relationship 
# between one's heigth and their weight. Let's add a line of regression through 
# this plot.
ggplot(h.w, aes(x = Height, y = Weight)) +
  geom_point() +
  geom_smooth(method = "lm") +

# Now let's solve this linear model and find out some more mathematical information. 
h.w.lm <- lm(Weight ~ Height, data = h.w)

# Now let's look at how well our regression model faired. First, by taking it's summary.
summary(h.w.lm)

# Second, let's calculate residuals
residuals(h.w.lm)
plot(h.w.lm, which = 1) # plot the residuals

# Now let's shift gears and look over the case study. This case study uses a dataset
# regarding the top 1000 visted sites in the year 2011, and it uses regression to 
# predict PageViews. First, let's read in the data. 
sites <- read.csv("data/top_1000_sites.tsv", sep = "\t", stringsAsFactors = FALSE)

# Now let's create a quick scatterplot using PageViews and UniqueVisitors
ggplot(sites, aes(x = PageViews, y = UniqueVisitors)) + 
  geom_point()

# This scatterplot looks awful, so we'll need to visualize our data with something else
ggplot(sites, aes(x = PageViews)) + 
  geom_density()

# Even this is pretty bad, but let's take the log of the PageViews to scale this. 
ggplot(sites, aes(x = log(PageViews))) + 
  geom_density()

# Since the log transform of the PageViews looks good, let's do a log transformation 
# for our original scatterplot
ggplot(sites, aes(x = log(PageViews), y = log(UniqueVisitors))) + 
  geom_point()

# We can see a linear relationship between UniqueVisitors vs PageViews, let's 
# create a plot with a regression line through it. 
ggplot(sites, aes(x = log(UniqueVisitors), y = log(PageViews))) + 
  geom_point() +
  geom_smooth(method = "lm")
 
# This looks good, so let's create the linear model object 
sites.lm <- lm(log(PageViews) ~ log(UniqueVisitors), data = sites)
summary(sites.lm)

# This is a good start, but we have more data available to us, so let's include
# some other input variables into our model. Namely, HasAdverstising and InEnglish
sites.lm <- lm(log(PageViews) ~ HasAdvertising + InEnglish + log(UniqueVisitors), data = sites)

# This model includes three variables, but let's use each one separately and see
# which has the highest R-squared value. 
adv.lm <- lm(log(PageViews) ~ HasAdvertising, data = sites)
summary(adv.lm)$r.squared

eng.lm <- lm(log(PageViews) ~ InEnglish, data = sites)
summary(eng.lm)$r.squared

unq.lm <- lm(log(PageViews) ~ log(UniqueVisitors), data = sites)
summary(unq.lm)$r.squared

# We can see that the log(UniqueVisitors) input provides the highest R-squared, 
# thus explaining the most amount of variance in our relationship.


