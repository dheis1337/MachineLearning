library(data.table)
library(ggplot2)
library(leaps)
library(glmnet)


# This script is for visualizing the way the tuning parameter in lasso regression
# affects the bias-variance tradeoff. First, I'll load in some data. 
props <- fread("C:/MyStuff/DataScience/Projects/RealEstate/properties.csv")

props <- props[complete.cases(props[, .(price, baths, garage, property_size, beds, lot_size)])]
props <- props[city == "Denver"]

# Let's visualize a density of the price data, which is the response
ggplot(props, aes(x = city, y = price)) +
  geom_density()

# It looks like there's a few observations with really high price values. Let's just
# limit our properties to a price of 1 million or less
props <- props[price < 1000000]

# Now I'm going to subset the props data.table and remove 20 observations. I'll 
# use these observations as "new" predicted data points, which I'll calculate the
# bias and variance of the model. 
index <- sample(792, 20)

# Create test.obs data.table
test.obs <- props[index]

# Remove above observations from props
props <- props[-index]


# Now I'll create some empty vectors that I'll use to store the bias-variance calculations
test.pred <- vector("numeric", length = 100)
test.err <- vector("numeric", length = 5)
test.bias.sq <- vector("numeric", length = 5)
test.variance <- vector("numeric", length = 5)

train.pred <- vector("numeric", length = 1000)
train.err <- vector("numeric", length = 5)
train.bias.sq <- vector("numeric", length = 5)
train.variance <- vector("numeric", length = 5)


# Now I'll create a vector of 15 different tuning parameter values 
lambda <- c(.001, .005, .01, .05, .1, .5, 1, 5, 10, 50, 100, 500, 1000, 5000, 10000)


# Create empty data.table that I'll fill with the values calculated
err.dt <- data.table("test_error" = integer(),
                     "bias_squared" = integer(), 
                     "variance" = integer(),
                     "observation" = character(),
                     "lambda" = integer())

for (j in 1:15) {
  lam <- lambda[j]

    for (i in 1:20) {
      x0.price <- test.obs[i, price]
      x0 <- as.matrix(test.obs[i, .(garage, baths, beds, property_size, lot_size)])
        for (k in 1:50){
          train <- props[sample(772, 650)]
          train.price <- train[, price]  
          train <- as.matrix(train[, .(garage, baths, beds, property_size, lot_size)])
          fit <- glmnet(x = train, y = train.price, alpha = 1,
                        lambda = lam)
          test.pred[k] <- predict(fit, newx = x0)
          
          test.err[i] <- mean((test.pred - x0.price)^2)
          test.bias.sq[i] <- (mean(test.pred) - x0.price)^2
          test.variance[i] <- var(test.pred)
          
          
          dt <- data.table("test_error" = test.err,
                           "bias_squared" = test.bias.sq, 
                           "variance" = test.variance,
                           "observation" = 1:20, 
                           "lambda" = rep(lam, 20))
        }
      



  }

      err.dt <- rbind(err.dt, dt)
     
} 



# Create a visualization of the results
ggplot(err.test, aes(x = lambda)) +
  geom_line(aes(y = bias_squared, group = observation)) +
  #geom_line(aes(y = test_error, group = observation), color = "green") +
  geom_line(aes(y = variance, group = observation), color = "red")


exp.var <- err.dt[, mean(variance), by = lambda][, 2]
exp.bias <- err.dt[, mean(bias_squared), by = lambda][, 2]
exp.err <- err.dt[, mean(test_error), by = lambda][, 2]

exp.err.dt <- data.table("expected_variance" = exp.var,
                         "expected_bias" = exp.bias, 
                         "expected_err" = exp.err,
                         "lambda" = lambda[1:15])

ggplot(exp.err.dt, aes(x = lambda)) +
  geom_line(aes(y = expected_bias.V1)) +
  geom_line(aes(y = expected_variance.V1), color = "red")
  #geom_line(aes(y = expected_err.V1)) 