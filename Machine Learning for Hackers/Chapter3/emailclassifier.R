# Chapter 3 focuses on classification in machine learning, and uses the classic
# example of spam/ham emails from the SpamAssasin public corpus. Let's begin
# by loading the emails from the corpus into R and loading the required libraries.

library(tm)
library(ggplot2)


# The emails are in Machine Learning For Hackers/Chapter3/data folder in my repo. 
# Let's set the working directory as Machiner Learning For Hackers/Chapter3 and
# we'll read in the data. 

setwd("C:/MyStuff/DataScience/Projects/MachineLearning/Machine Learning For Hackers/Chapter3")

# Now we need to create path objects for each kind of emaily type - easy ham, hard ham,
# or spam. There are two objects per email type, because the second version of the 
# emails will be our test set, while we train our model on the other emails. 

spam.path <- "data/spam/"
spam.path2 <- "data/spam_2/"
easyham.path <- "data/easy_ham/"
easyham2.path <- "data/easy_ham_2/"
hardham.path <- "data/hard_ham/"
hardham2.path <- "data/hard_ham_2/"


# Next, we need to make a function to read in the emails.

get.msg <- function(path) {
  # This function will be used in conjunction with an anonymous function and sapply
  # shortly. First, the funciton opens a connection to each file under the "read as text"
  # connection. Then it uses ReadLines and stores it into a vector. The 'msg' vector
  # is a subset of 'text' vector which is the actual email portion. The 'msg' vector 
  # is built by finding the first blank line in 'text', and getting each line after 
  # it. This is because each file is formatted as a blank line separating address informatino
  # and the actual email sent. Finally, the connection is closed and the function returns
  # a single element vector with the entire email content in it. 
  con <- file(path, encoding = "latin1")
  text <- readLines(con)
  # The message always begins after the first full line break. 
  first.blank <- which(text == "")[1]
  msg <- text[seq((first.blank + 1), length(text), by = 1)]
  close(con)
  return(paste(msg, collapse = " "))
}

# FInd all of the files in the /data/spam folder using spam.path object
spam.docs <- dir(spam.path)
spam.docs <- spam.docs[spam.docs != "cmds"] # remove cmds file
spam.docs <- paste(spam.path, spam.docs, sep = "") # paste general path and  files
all.spam <- sapply(spam.docs, get.msg) # run get.msg on each file


# Function to create the TermDocumentMatrix
make.tdm <- function(doc.vec) {
  doc.corpus <- Corpus(VectorSource(doc.vec))
  control <- list(stopwords = TRUE, removePunctuation = TRUE, removeNumbers = TRUE,
                  bounds = list(global = c(2, Inf)))
  doc.tdm <- TermDocumentMatrix(doc.corpus, control)
  return(doc.tdm)
}


spam.tdm <- make.tdm(all.spam)
spam.mat <- as.matrix(spam.tdm)
spam.counts <- rowSums(spam.mat)
spam.terms <- names(spam.counts)
spam.freq <- as.numeric(spam.counts)
spam.df <- data.frame(cbind(names(spam.counts), as.numeric(spam.counts)),
                      stringsAsFactors = FALSE)
names(spam.df) <- c("term", "frequency")
spam.df$frequency <- as.numeric(spam.df$frequency)
spam.occurrence <- sapply(1:nrow(spam.mat),
                          function(i) {length(which(spam.mat[i, ] > 0)) / ncol(spam.mat)})
spam.density <- spam.df$frequency / sum(spam.df$frequency)
spam.df <- transform(spam.df, density = spam.density, occurrence = spam.occurrence)
spam.df <- as.data.table(spam.df)
head(spam.df[with(spam.df, order(-occurrence)), ], n = 10)


# Ham emails 
easyham.docs <- dir(easyham.path)
easyham.docs <- easyham.docs[easyham.docs != "cmds"]
easyham.docs <- easyham.docs[1:500]
all.easy <- sapply(easyham.docs, function(p) get.msg(paste(easyham.path, p, sep = "")))


easy.tdm <- make.tdm(all.easy)
easy.mat <- as.matrix(easy.tdm)
easy.counts <- rowSums(easy.mat)
easy.df <- data.frame(cbind(names(easy.counts), as.numeric(easy.counts)),
                      stringsAsFactors = FALSE)
names(easy.df) <- c("term", "frequency")
easy.df$frequency <- as.numeric(easy.df$frequency)
easy.occurrence <- sapply(1:nrow(easy.mat),
                          function(i) {length(which(easy.mat[i, ] > 0)) / ncol(easy.mat)})
easy.density <- easy.df$frequency / sum(easy.df$frequency)
easy.df <- transform(easy.df, density = easy.density, occurrence = easy.occurrence)
easy.df <- as.data.table(easy.df)
head(easy.df[with(easy.df, order(-occurrence)), ])


classify.email <- function(path, training.df, prior = 0.5, d = 1e-6) {
  msg <- get.msg(path)
  msg <- removePunctuation(msg)
  msg <- tolower(msg)
  msg <- removeWords(msg, stopwords("en"))
  msg <- strsplit(msg, "\\W+", perl = TRUE)
  msg <- unlist(msg)
  counts <- table(msg)
  msg.match <- intersect(msg, training.df$term)
    if (length(msg.match) < 1) {
      return(prior * d ^ (sum(counts)))
  } else {
      match.probs <- training.df$occurrence[match(msg.match, training.df$term)]
      return(prior * prod(match.probs) * d ^ (sum(counts) - length(msg.match)))
  } 
}
 

test <- hardham.docs

msg <- get.msg(hardham.docs[1])
msg.tdm <- make.tdm(msg)
# Breaking out above function
msg <- removePunctuation(msg)
msg <- tolower(msg)
msg <- removeWords(msg, stopwords("en"))
msg <- strsplit(msg, "\\W+", perl = TRUE)

counts <- table(msg)
msg.mat <- as.matrix(counts)


msg.freq <- rowSums(as.matrix(msg.tdm))
msg.match <- intersect(names(msg.freq), spam.df$term)

spam.df$occurrence[match(msg.match, spam.df$term)]

msg <- vector("list", length = length(hardham.docs))
for (i in 1:length(hardham.docs)) {
  msg[[i]] <- get.msg(hardham.docs[i])  
}

# Ham emails 
hardham.docs <- dir(hardham.path)
hardham.docs <- hardham.docs[hardham.docs != "cmds"]
hardham.docs <- paste(hardham.path, hardham.docs, sep = "")
hardham.docs

hardham.spamtest <- sapply(hardham.docs, classify.email, training.df = spam.df)

hardham.hamtest <- sapply(hardham.docs, classify.email, training.df = easy.df)

hardham.res <- ifelse(hardham.spamtest > hardham.hamtest, TRUE, FALSE)
summary(hardham.res)



