library(class)
library(gmodels)

setwd("c:/mystuff/datascience/projects/machinelearning/Machine Learning with R/chapter3")

dat <- read.csv("data.csv", stringsAsFactors = FALSE) # load data

# Let's do some exploring 
head(data)
summary(dat)

# Our data is comprised mostly of numeric data, that represent different measurements
# for tumor masses found in patients. The two non-numeric variables are id and 
# diagnosis. The id variable is a simple patient id, and the diagnosis is our outcome
# variable we are attempting to classify. Since we don't need the id, let's remove 
# it. 
dat <- dat[, -1]

# Before we begin running our model, we need to do some additional cleaning. First
# let's make the diagnosis variable a factor and extend the outcomes to "benign" 
# and "malignant".
dat$diagnosis <- factor(dat$diagnosis, levels = c("B", "M"), 
                        labels = c("Benign'", "Malignant"))

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
dat[2:32] <- apply(dat[2:32], MARGIN = 2, FUN = normalize)





