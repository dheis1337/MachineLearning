## Chapter 3
Chapter 3 goes over Naive Bayes classification, using a case study on spam vs ham 
emails. The data comes from the SpamAssasin public courpus, which can be found [here](http://spamassassin.apache.org/downloads.cgi?update=201504291720)

### Learning Technique:
Naive Bayes Classification

### Learning Type:
Supervised

### Model Overview:
The Naive Bayes classification model is a simple, yet powerful model used in machine learning 
classification. If you have even a modest background in probability theory, specifically
Bayes' Theorem and event independence, understanding the intuition that Naive Bayes is built upon
is easy. What I really love about Naive Bayes classification is it's foundation in probability
theory, as well as how powerful it can be. Although the model makes an assumption that is rarely
satisified entirely (more on this in a minute), it is still an effective, accurate classifier! 

Essentially, Naive Bayes classification uses [Bayes' Theorem](https://en.wikipedia.org/wiki/Bayes'_theorem) to come up 
with the probability that an observation is in some class, given some characteristics. It does this
by using exisiting data, and determine a "prior", which is Bayes-speak for the probability that a given
class occurs in our test data set. For instance, if we have a collection of fruit, the "prior" for 
bananas (one of our classes) would be the number of bananas divided by the total number of fruit - 
effectively the probability of any fruit being a banana (again, one of our classes). The reason
our classifier is "naive," is because of an assumption about the data we accept in order to apply the 
model. This assumption is that the characteristics of a given observation are independent of one another. 
Thus, given our observation is of class y, the probability of having characteristics x1, x2, and x3 are all 
independent of one another. The reason we accept the assumption of independence is because we can then 
use some probability theory to multiply the individual probabilities together, in order to determine 
the probability of our observation having characteristics x1, x2, and x3, given that it is of class y. If that
is a little confusing, no worries! There is an awesome explanation of how Naive Bayes is used [here](http://stackoverflow.com/questions/10059594/a-simple-explanation-of-naive-bayes-classification).
Just scroll about halfway down the page to the example using fruit. 