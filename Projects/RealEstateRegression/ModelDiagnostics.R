library(data.table)
library(ggplot2)
library(car)
library(gghalfnorm)
library(tidyr)
library(MASS)
library(perturb)
library(ggmap)
library(zipcode)

props <- fread("C:/MyStuff/DataScience/Projects/RealEstate/properties.csv")

# Subset the data by properties in Denver
props <- props[city == "Denver"]


# Determine variable types
str(props)

# Change necessary variable types
props[, zipcode := factor(zipcode)]
props[, property_type := factor(property_type)]
props[, broker := factor(broker)]
set(props, i = which(props$garage == 0), j = "garage", value = 0)



# Check for collinearity
fit <- lm(log(price) ~ baths + zipcode + garage + log(property_size) + beds, data = props, subset = -1344)
fit1 <- lm(log(price) ~ beds, data = props)
fit2 <- lm(log(price) ~ beds + baths, data = props)


# Calculate Variance Inflation Factors and the Collinearity Matrix 
vif(fit)
cd <- colldiag(model.matrix(fit)[, -1], add.intercept = FALSE)


# Exploratory Analysis
ggplot(props, aes(x = baths)) +
  geom_histogram(binwidth = 1, color = "black", fill = "grey") +
  scale_x_continuous(breaks = c(1:10, seq(10, 40, by = 10))) +
  ggtitle(label = "Histogram for Baths Predictor")

ggplot(props, aes(x = garage)) +
  geom_histogram(binwidth = 1, color = "black", fill = "grey") +
  scale_x_continuous(breaks = c(1:10, seq(10, 110, by = 10))) +
  ggtitle(label = "Histogram for Garage Predictor")

ggplot(props, aes(x = beds)) +
  geom_histogram(binwidth = 1, color = "black", fill = "grey") +
  scale_x_continuous(breaks = c(0:10, seq(10, 40, by = 10))) +
  ggtitle(label = "Histogram for Beds Predictor")

ggplot(props, aes(x = log(property_size), y = log(price))) +
  geom_point()


# Density plots
ggplot(props, aes(x = garage)) +
  geom_density(fill = "grey")

ggplot(props, aes(x = beds)) +
  geom_density(fill = "grey")

ggplot(props, aes(x = property_size)) +
  geom_density(fill = "grey")

# log(price) vs number of beds
ggplot(props, aes(beds, y = log(price))) +
  geom_point(alpha = .5) +
  geom_smooth(method = "lm")

# Bar plot for beds
ggplot(props, aes(x = beds)) +
  geom_bar()

# Model fitting and validation
# Let's fit the model and then run some diagnositics
fit <- lm(log(price) ~ baths + zipcode + garage + log(property_size) + beds, data = props)


# Model summary
summary(fit)

# Get the data used in the model
mat <- model.matrix(fit)
fit.data <- as.data.table(mat)

# We'll begin with the assumptions regarding the errors.
# First, ensuring the errors have constant variance and that its centered around 0. 
# To do this, we will plot the residuals vs the fitted values. 
err.dt <- data.table(Residuals = residuals(fit), Fits = fitted(fit)) 

# Without reducing scale
ggplot(err.dt, aes(x = Fits, y = Residuals)) + 
  geom_point()

# Residuals vs all predictors
err.dt <- cbind(err.dt, fit.data)

# Residuals ~ property_size
ggplot(err.dt, aes(x = err.dt$`log(property_size)`, y = Residuals)) +
  geom_point()

plot(x = err.dt$`log(property_size)`, y = err.dt$Residuals)

# Residuals ~ garage
ggplot(err.dt, aes(x = garage, y = Residuals)) +
  geom_point() 

# Residuals ~ baths
ggplot(err.dt, aes(x = baths, y = Residuals)) +
  geom_point()



# I will also do a plot of the squared absolute values of the residuals vs the 
# fitted values
err.dt[, `Sq Abs Resids` := sqrt(abs(residuals(fit)))]

# Without reducing scale
ggplot(err.dt, aes(x = Fits, y = `Sq Abs Resids`)) + 
  geom_point()

# After reducing scale
ggplot(err.dt, aes(x = Fits, y = Residuals)) + 
  geom_point() +
  xlim(c(12, 16)) +
  ylim(c(-2, 2))


# Now I want to check the normality assumption for the errors. To do this, I will
# create a qqplot of the errors. 
ggplot(err.dt, aes(sample = Residuals)) + 
  stat_qq() +
  geom_abline(intercept = mean(err.dt$Residuals), slope = sd(err.dt$Residuals))


ggplot(err.dt, aes(sample = Residuals)) + 
  stat_qq() +
  ylim(c(-2, 2))

qqPlot(err.dt$Residuals)


# Errors plotted vs a normal distribution with the same parameters
ggplot(err.dt, aes(x = Residuals)) +
  geom_density() +
  geom_density(aes(x = rnorm(1800, mean = 0, sd = sqrt(.06))), color = "green")


# Now let's check for the correlation of the errors. To do this, I will plot
# the ith residual vs the ith + 1 residual
resid.plus.one <- err.dt[, Residuals]
resid.plus.one[2:1803] <- resid.plus.one
resid.plus.one[1] <- NA
resid.plus.one <- resid.plus.one[-1803]
err.dt[, `Resid Plus One` := resid.plus.one]

test <- gather(err.dt, key = Zip, value = Value, c(5:37))
test <- as.data.table(test)
test <- test[Value == 1]

ggplot(test, aes(x = Zip, y = Residuals)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# No scale change
ggplot(err.dt[-c(1, 1802)], aes(x = `Resid Plus One`, y = Residuals)) +
  geom_point()

# Scale change
ggplot(err.dt[-c(1, 1802)], aes(x = `Resid Plus One`, y = Residuals)) +
  geom_point() +
  ylim(c(-2, 2)) +
  xlim(c(-2, 2))

# Now let's check for unusual observations. Based on some of the plots we've 
# already created, I believe there are a few. The first plot I will use is the
# halfnorm plot of the hatvalues. 
gghalfnorm(hatvalues(fit))

# We can see there are definitely some leverage values in our data. 
# The next plot I will do is a qqplot of the standardized residuals
err.dt[, `Standard Residuals` := rstandard(fit)]
qqPlot(err.dt$`Standard Residuals`)


# Now I want to check for outliers. To do this, I will use the OutlierTest function
# from the car package
outlierTest(fit)
  
# We can see there are 8 residuals at the 5% level.

# Now I want to test for influential observations. To do this, I will use by 
# creating a half normal plot of the Cooks statistics (distances)
err.dt[, Cooks := cooks.distance(fit)]
gghalfnorm(x = err.dt$Cooks)
influencePlot(fit)

props1 <- props[complete.cases(props[, .(price, baths, garage, property_size, beds, zipcode)])]
props1 <- props1[-50]
i.fit <- lm(log(price) ~ baths + garage + zipcode + log(property_size) + beds, data = props)
# Now let's check the structural assumption of the model. This is essentially 
# that E(y) = XB. ?To do this, I will create a Component plus Residual plot
crPlot(fit, variable = "baths",  xlim = c(0, 10))
crPlot(fit, variable = "garage", xlim = c(0, 10))
crPlot(fit, variable = "log(property_size)", xlim = c(6, 10))
crPlot(fit, variable = "beds")

# Now let's do some added variable plots
avPlot(fit, variable = "baths")
avPlot(fit, variable = "baths", xlim = c(-5, 5))
avPlot(fit, variable = "garage")
avPlot(fit, variable = "garage", xlim = c(-5, 5))
avPlot(fit, variable = "beds")
avPlot(fit, variable = "log(property_size)")

# Model results data.table
results <- data.table(Coefficients = names(coefficients(fit)), Estimates = coefficients(fit),
                      `P value` = summary(fit)$coef[, 4])

results[, Significance := ifelse(`P value` < .05, "Signifcant", "Not Significant")]

qqPlot(fit, grid = TRUE)

# Permutation test to determine if the zipcode variable should be included in the model
n <- 1000
fstat <- vector("numeric", length = n)
obs <- summary(fit)$fstatistic[1]

for(i in 1:n) {
  mod <- lm(log(price) ~ baths + sample(zipcode) + garage + log(property_size) + beds, data = props)
  fstat[i] <- summary(mod)$fstatistic[1]
}

mean(fstat > obs)

(sum(fstat > obs) + 1 )/(n + 1) 

obs <- summary(fit)$fstatistic[1]
fstat <- vector("numeric", length = n)
for (i in 1:n) {
  mod <- lm(log(price) ~ baths + zipcode + garage + log(property_size) + beds + log(lot_size) + sample(broker) + property_type, data = props)
  fstat[i] <- summary(mod)$fstatistic[1]
}

mean(fstat > obs)

(exp(-.0474) - exp(-.0579)) / exp(-.0579)
exp(.0940)
