library(data.table)
library(ggplot2)
library(leaps)
library(car)

props <- fread("C:/MyStuff/DataScience/Projects/RealEstate/properties.csv")

props <- props[complete.cases(props[, .(price, baths, garage, property_size, beds)])]
props <- props[city == "Denver"]



x0 <- props[1800]
props <- props[-1800]

fit <- lm(price ~  baths + garage + property_size + beds, data = props)

# Create data.table for visualization
errs <- data.table("Fitted_Values" = fit$fitted.values, 
                   "Residuals" = summary(fit)$residuals)

# Visualization residuals vs fitted values
ggplot(errs, aes(x = Fitted_Values, y = Residuals)) +
  geom_point()

test.pred <- vector("numeric", length = 10)

for (i in 1:1000) {
  index <- sample(1799, 1000)
  train <- props[index]
  fit <- lm(price ~  baths + garage + property_size + beds, data = train)
  test.pred[i] <- predict(fit, newdata = x0)

}




# Create a dt for visualizing the distribution of predictions
pred.dt <- data.table("predictions" = test.pred)

# Density plot of predictions
ggplot(pred.dt, aes(x = predictions)) +
  geom_density() +
  geom_vline(xintercept = x0$price) +
  geom_vline(xintercept = mean(test.pred))


props[-sample(1799, 1000)]



props <- props[complete.cases(props[, .(price, baths, garage, property_size, beds, lot_size, zipcode)])]

# Use best subset selection to find the best model of each size
best.subset <- regsubsets(price ~  baths + garage + property_size + beds + lot_size, data = props)

summary(best.subset)

props <- setcolorder(props, c("property_size", "baths", "garage", "beds", "lot_size", "address",
                              "unit_number", "city", "zipcode", "state", "property_type",
                              "broker", "date_scraped", "price"))


x0 <- props[958]
props <- props[-958]


test.pred <- vector("numeric", length = 1000)
test.err <- vector("numeric", length = 5)
bias_sq <- vector("numeric", length = 5)
variance <- vector("numeric", length = 5)


for (j in 1:5) {
  preds <- (paste(names(props)[1:j], collapse = "+"))
  form <- as.formula(paste("price ~ ", preds))
    for (i in 1:1000) {
      index <- sample(957, 650)
      train <- props[index]
      fit <- lm(form, data = train)
      test.pred[i] <- predict(fit, newdata = x0)
      
    }
  test.err[j] <- mean((test.pred - x0$price)^2)
  bias_sq[j] <- (mean(test.pred) - x0$price)^2
  variance[j] <- var(test.pred)
  num_of_preds[j] <- j
  
}

# Make a dt to visualize results
err.dt <- data.table("number_of_preds" = num_of_preds, 
                     "bias_squared" = bias_sq, 
                     "Variance" = variance)

# Create a visualization of below
ggplot(err.dt, aes(x = number_of_preds, y = bias_squared)) +
  geom_point(color = "#a32c2c") + 
  geom_line(aes(color = "Bias Squared")) +
  geom_point(data = err.dt, aes(x = number_of_preds, y = Variance * 30), color = "#4367c1") + 
  geom_line(data = err.dt, aes(x = number_of_preds, y = Variance * 30, color = "Variance")) +
  #scale_y_continuous(name = "Variance", limits = c(100000000, 400000000)) +
  scale_y_continuous(sec.axis = sec_axis(~. / 30, name = "Variance")) +
  labs(title = "Variance and Bias as a Function of Number of Predictors",
       x = "Number of Predictors",
       y = "Bias Squared") +
  theme(plot.title = element_text(hjust = .5)) +
  scale_color_manual(name = '',
                     values = c("Bias Squared" = "#f77171",
                                "Variance" = "#aac2ff"))

# Let's look at another example 
soils <- as.data.table(Soils)

# In this example I'm going to use all the predictors to predict the pH of the soil samples
x1 <- soils[48]
soils <- soils[-48]

# I'm going to remove Group and Gp
soils <- soils[, .(Contour, Depth, pH, N, Dens, P, Ca, Mg, K, Conduc)]

# I again want to find the order of the best subset for each number of predictors
best.subs <- regsubsets(pH ~ ., data = soils)

summary(best.subs)

# Set the order of the predictors
setcolorder(soils, c("Ca", "Contour", "Conduc", "N", "Mg", "K", "Depth", "Dens", "P", "pH"))

# Fit a model with all the predictors and check the Residuals vs Fitted values
# I want to do this to ensure there actually is a bias in this model. If the 
# errors are centered around 0, have equal variance, and are uncorrelated, then 
# the Gauss-Markov theorem applies
soil.fit <- lm(pH ~ ., data = soils)

preds.soil <- data.table("Fits" = soil.fit$fitted.values,
                         "Residuals" = soil.fit$residuals)

# It's tough to say if there 
ggplot(preds.soil, aes(x = Fits, y = Residuals)) +
  geom_point()


# Use the for loop above to calculate variance and bias of predictions at x1
for (j in 1:9) {
  preds <- (paste(names(soils)[1:j], collapse = "+"))
  form <- as.formula(paste("pH ~ ", preds))
  for (i in 1:1000) {
    index <- sample(47, 35)
    train <- soils[index]
    fit <- lm(form, data = train)
    test.pred[i] <- predict(fit, newdata = x1)
    
  }
  test.err[j] <- mean((test.pred - x1$pH)^2)
  bias_sq[j] <- (mean(test.pred) - x1$pH)^2
  variance[j] <- var(test.pred)
  num_of_preds[j] <- j
  
}


# Make a dt to visualize results
err.soils <- data.table("number_of_preds" = num_of_preds, 
                     "bias_squared" = bias_sq, 
                     "Variance" = variance)

