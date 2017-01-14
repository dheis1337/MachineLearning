# Chapter 9 introduces the concept of clustering, more specifically, multidimensional
# scaling. Multidimensional scaling (MDS) is a clustering technique that compares
# observations based on a measure of distance among said observations. The chapter
# begins by working with a simple example, and concludes with a case study
# on US Senate roll call voting. 

library(foreign)
library(ggplot2)

setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter9/")

# For the simple example, we will generate a matrix that represents market ratings
# of different products by a number of consumers. The rating scale is a thumbs up
# (1), thumbs down (-1), or a skip (0). The rows represent consumers, and the 
# columns represent the different products. We are going to randomly generate 
# this matrix. 
set.seed(851982)
ratings <- c(1, 0, -1)
ex.mat <- matrix(sample(ratings, 24, replace = TRUE), nrow = 4, ncol = 6)
row.names(ex.mat) <- c("A", "B", "C", "D")
colnames(ex.mat) <- c("P1", "P2", "P3", "P4", "P5", "P6")

ex.mat

# In order to begin our multidimensional scaling, we need to compare reviews among
# consumers. To do this, we're going to multiply our matrix by it's transpose.
ex.mult <- ex.mat %*% t(ex.mat)

# Now what we have is an aggregrate rating of all the same products reviewed 
# by each consumers. In other words, each nondiagonal entry represents how 
# consumers rated like products, and all diagonal entries represent how many
# products that consumer reviewed. For instance, B and A (entry [2, 1]) had a 
# negative sentiment across all of the similar products they reviewed. 
# Further developing this, we want to measure these ratings using Euclidean distance 
# in a multidimensional space. To do this, we'll use the dist() function in R,
# which computes a distance matrix.
ex.dist <- dist(ex.mult)
ex.dist

# What this lower triangular matrix represents is the distance of each consumer
# from the other consumers. Thus, consumers A and D are the closest, since they're
# corresponding entry is the smallest. Now we can use MDS to create a spatial layout
# of our distance matrix. To compute an MDS for this distance matrix, we'll use
# the cmdscale() function.
ex.mds <- cmdscale(ex.dist)

# Now let's plot it!
plot(ex.mds, type = "n")
text(ex.mds, c("A", "B", "C", "D"))

# Just as we saw in our distance matrix, consumers A and D are the closest, and
# they create a nice cluster. 

# Now we'll begin the case study. This case study is concerned with roll call voting
# for the US Senate. We'll be using a dataset on votes from the 101st-100th Congress. 

# Create objects to find data files in folder
data.dir <- c("data/roll_call/")
data.files <- list.files(data.dir)

# Create a list of data frames, one for each Congress. 
rollcall.data <- lapply(data.files, 
                        function(f) read.dta(paste(data.dir, f, sep = ""), convert.factors = FALSE))
head(rollcall.data[[1]])

# Now we have a list, with each element corresponding to a data frame that has 
# each of the votes for each US Senate from the 101st to the 111th. Before we 
# can perform our multidimensional scaling, we need to do some cleaning. 
# First, we need to do something about the actual votes. Inspecting our 
# first data frame (for the 101st Congress), we can see that rows represent 
# members of the Senate, and columns represent the items they voted on. The corresponding
# entries are the types of vote. The codebook for the 101st Congress can be found
# at http://www.voteview.com/senate101.htm. In order to make this easier, we need 
# to condense the different types of votes into 3 categories, similar to our 
# consumer example. There are different types of procedural votes, but the 
# overall sentiment of the vote comes in three types - Yea, Nay, Abstain (not voting). 
# All values 1-3 will be mapped to Yea (1), values 4-6 will be mapped to Nays (-1), and
# everything else will be mapped to Abstain (0). To do this, we'll create a function. 
# This function will also remove votes for the state code equal to 99, which 
# is the Vice President, who votes in case of a tie. 
rollcall.simp <- function(df) {
  no.vice <- subset(df, state < 99)
    for (i in 10:ncol(no.vice)) {
      no.vice[, i] <- ifelse(no.vice[, i] > 6, 0, no.vice[, i])
      no.vice[, i] <- ifelse(no.vice[, i] > 0 & no.vice[, i] < 4, 1, no.vice[, i])
      no.vice[, i] <- ifelse(no.vice[, i] > 1, -1, no.vice[, i])
    }
  return(as.matrix(no.vice[, 10:ncol(no.vice)]))
}

# Lapply the function to each data frame
rollcall.simple <- lapply(rollcall.data, rollcall.simp)

# Ensure results look correct
head(rollcall.simple[[1]])

# Now that we have our new encodings, we can begin to calculate our distance matrices
# First, we need to convert our senator-by-vote matrix to a senator-by-senator matrix. 
rollcall.dist <- lapply(rollcall.simple, function(m) dist(m %*% t(m)))

# Now, we'll do something similar to the last line of code, but we'll calculate our
# distance matrix. This we're explicitally going to set the k argument of cmdscale()
# to 2. This is the default setting for the cmdscale() function, however setting
# the argument is good practice to increase code readability and understanding. 
# Additionally, we'll multiply our result by -1, which will flip our axis, and 
# allow for Democrats to be visualized on the left side of a plot, and Republicans
# to be on the right side - something that follows a more colloquial belief about
# politicians. 
rollcall.mds <- lapply(rollcall.dist, 
                       function (d) as.data.frame((cmdscale(d, k = 2)) * -1))

# Now we want to add some additional information to our data, namely, their party 
# information and which Congress the data is associated with. 
congresses <- c(101:111)
for (i in 1:length(rollcall.mds)) {
  names(rollcall.mds[[i]]) <- c("x", "y")
  congress <- subset(rollcall.data[[i]], state < 99)
  congress.names <- sapply(as.character(congress$name),
                           function (n) strsplit(n, "[, ]")[[1]][1])
  rollcall.mds[[i]] <- transform(rollcall.mds[[i]], name = congress.names,
                                 party = as.factor(congress$party), 
                                 congress = congresses[i])
}

# Inspect results
head(rollcall.mds[[1]])

# Create a visualization
cong.110 <- rollcall.mds[[9]]
ggplot(cong.110, aes(x = x, y = y)) + 
  geom_point(aes(color = party, alpha = .5, size = 2)) +
  scale_color_manual(values = c("#0011ff", "#ff0000", "#00ffb6"))

# Breaking down our visualization, circles correspond to Democrats, traingles correspond
# Republicans, and the one square represents an Independent. This is just for one
# Senate, so let's create a visualization for each Senate. 
all.mds <- do.call(rbind, rollcall.mds)
all.plot <- ggplot(all.mds, aes(x = x, y = y)) +
  geom_point(aes(color = party, alpha = .5, size = 1)) +
  scale_color_manual(values = c("#0011ff", "#ff0000", "#00ffb6")) +
  facet_wrap(~ congress)

# A faceted plot, with each separate grid representing each Senate from the 101st 
# to the 111th. 
all.plot

# Be sure to check out the WRITEUP.txt for this chapter for a brief summary
# of this case study and some observations!

