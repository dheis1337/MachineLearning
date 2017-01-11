# Chapter 8 is a very light introduction to principal component analysis (PCA) in R. 
# This is one of the shorter chapters in the book, and is certainly far 
# from an exhaustive explanation of what PCA is, how it works, and what it can be 
# used for. The upshot of PCA is that it takes a tabular data set, and reduces it 
# down to one of smaller dimensions. Essentially, PCA determines how your original 
# data set can be represented through smaller means. The case study for this chapter
# is on stock prices, and using PCA on a list of stocks, to come up with a simple 
# way of tracking the Dow Jones Industrial Average (DJI).

library(lubridate)
library(reshape)

setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter8")


# Load in price data for stocks
prices <- read.csv("data/stock_prices.csv")

head(prices)

# Let's conver the Date column to a format that will be more coducive for visualizations
# later on. 
prices <- transform(prices, Date = ymd(Date))

# There are some missing entries, so let's remove those. 
prices <- subset(prices, Date != ymd('2002-02-01'))
prices <- subset(prices, Stock != 'DDR')

# In order to use PCA, we need to make each stock it's own column, while the 
# Date column remains as rows. The Close column will be the values that are associated
# with the intersect of each stock and a corresponding day. To reformat this data, 
# we'll use the reshape package's cast() function.
prices <- cast(prices, Date ~ Stock, value = "Close")


# Now we're ready to begin! Before we jump into PCA, let's take a look at the 
# correlation among columns. 
cor.matrix <- cor(prices[, 2:ncol(prices)]) # create correlation matrix
corrs <- as.numeric(cor.matrix) # Make a vector of correlations

# Create visualizaiton for correlations
ggplot(data.frame(Correlation = corrs),
       aes(x = Correlation, fill = 1)) +
  geom_density()

# Observing the correlations we can see that most are positive. That said, PCA
# will probably work well on these data. PCA is straightforward in R, and is implemented
# using the princomp() function on our data frame. 
pca <- princomp(prices[, 2:ncol(prices)])
pca

# Printing the results show that the first column (the principal component) describes
# 29% of the variance in the data. We'll still with this component, so we need to 
# extract it from the pca object. 
principal.comp <- pca$loadings[, 1]

# Now we can get a feel for how this princial component is formed. Essentially, 
# we want to see what weights are given to each column to make up the principal component. 
loadings <- as.numeric(principal.comp)

ggplot(data.frame(Loading = loadings),
       aes(x = Loading, fill = 1)) +
  geom_density()

# Now we want to come up with a summary of our data set using the principal 
# component. To do this, we'' use the predict() function
market.index <- predict(pca)[, 1]

# To determine how well this summary is, we need to measure it against something. 
# This is where the DJI comes in. 
dji <- read.csv("data/DJI.csv")

# Let's convert the date so we can do some quick cleaning
dji <- transform(dji, Date = ymd(Date))

# We need to subset this, so the dates match between our summary and the dji object
dji <- subset(dji, Date > ymd('2001-12-31'))
dji <- subset(dji, Date != ymd('2002-02-01'))

# Now we need to reverse the order of the dates so they're in the same order as 
# the summary data. 
dji <- with(dji, rev(Close))
dates <- with(dji, rev(Date))

# Now we can build a data.frame to use for visualizations
comparison <- data.frame(Date = dates, MarketIndex = market.index, DJI = dji)

# Now let's visualize
ggplot(comparison, aes(x = MarketIndex, y = DJI)) + 
  geom_point() +
  geom_smooth(se = FALSE, method = "lm")

# There is a negative relationship between our index and the DJI, but this can 
# be trivally changed by multiplying by 1
comparison <- transform(comparison, MarketIndex = -1 * MarketIndex)

# New visualization
ggplot(comparison, aes(x = MarketIndex, y = DJI)) + 
  geom_point() +
  geom_smooth(se = FALSE, method = "lm")

# Now we can see visually how are index looks compared to the DJI as a time series
# object. To do this, we need to create a data frame
alt.comp <- melt(comparison, id.vars = 'Date')
names(alt.comp) <- c("Date", "Index", "Price")

ggplot(alt.comp, aes(x = Date, y = Price, group = Index, color = Index)) +
  geom_point() +
  geom_line()


# We need to adjust the scales for the data, because the DJI takes on higher values 
# than our index. 
comparison <- transform(comparison, MarketIndex = -scale(MarketIndex))
comparison <- transform(comparison, DJI = scale(DJI))

alt.comp <- melt(comparison, id.vars = 'Date')
names(alt.comp) <- c("Date", "Index", "Price")

ggplot(alt.comp, aes(x = Date, y = Price, group = Index, color = Index)) +
  geom_point() +
  geom_line()

# As we can see, this created a really good approximation of our data! To do 
# this, we used the principal component of our data, which only explained 
# 30% of our data. However, we still have a fairly close approximation! This is 
# incredible, because we took 24 variables, converted them into one column, and 
# explained the DJI (which is a composite of all stocks on the index) using it! 
# This is such a simple example, but it definitely hits home the value of using 
# PCA. 





