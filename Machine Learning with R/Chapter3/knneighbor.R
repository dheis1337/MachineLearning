library(class)
library(gmodels)

setwd("c:/mystuff/datascience/projects/machinelearning/Machine Learning with R/chapter3")

dat <- read.csv("data.csv", stringsAsFactors = FALSE) # load data

# Let's do some exploring 
head(dat)
summary(dat)

# Our data is comprised mostly of numeric data, that represent different measurements
# for tumor masses found in patients. The two non-numeric variables are id and 
# diagnosis. The id variable is a simple patient id, and the diagnosis is our outcome
# variable we are attempting to classify. Since we don't need the id, let's remove 
# it.
dat <- dat[, -c(1, 33)]

# Before we begin running our model, we need to do some additional cleaning. First
# let's make the diagnosis variable a factor and extend the outcomes to "benign" 
# and "malignant".
dat$diagnosis <- factor(dat$diagnosis, levels = c("B", "M"), 
                        labels = c("Benign", "Malignant"))

# Our next cleaning requirement will be to normalize our data. We must normalize our
# data, because we have numeric variables that are of different magnitude. For instance
# the compactness_mean variable is between .01938 and .34540, while our area_mean
# variable is between 143.5 and 2501. Since we're going to be classifying using
# Euclidean distance, the differences in magnitude will affect our analysis negatively. 
# To normalize our data, we'll create a simple function, which will then be applied
# to each column of our data. 
normalize <- function(x) {
  # Takes one argument - a numeric variable - and normalizes it using the appropriate
  # normalizing formula
  (x - min(x)) / (max(x) - min(x)) 
}

# Now, let's ensure this function works correctly
normalize(c(1, 2, 3, 4, 5))

# Our function works properly, so let's apply it to each column in our data set. 
dat[2:31] <- apply(dat[2:31], MARGIN = 2, FUN = normalize)


# Now that we've cleaned our data, we want to split it up into test and training
# sets. 
train <- dat[1:469, 2:31]
test <- dat[470:569, 2:31]

# Let's also store the diagnosis variables in separate vectors for training and 
# testing sets
diag.train <- dat[1:469, 1]
diag.test <- dat[470:569, 1]

# We're ready to run our model over our data. We'll use the knn() function from 
# the class package to do this. 
dat.pred <- knn(train = train, test = test, cl = diag.train, k = 21)

# Now that we have our prediction vector, let's evaluate the performance of our model. 
# To do so, we'll use the CrossTable() function from the gmodels package. 
CrossTable(x = diag.test, y = dat.pred, prop.chisq =  FALSE)

# Examining the output of this function call, we see that our true negative rate 
# of classification was 100%. This means we correctly identified benign tumors as
# such 97.5% of the time. We also correctly classified malignant tumors 91.3% of the 
# time, our true positive rate. Our false negatie rate is .25%, which is where our model
# predicted benign but the tumor was malignant. Finally, our false positive rate 
# is 0, which is where our model predicted malignant but the tumor was actually benign. 
# Overall, we correctly classified tumors 98% of the time, which is great for such 
# a simple model and less than 100 lines of code! 


