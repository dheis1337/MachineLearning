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

### Applications
Naive Bayes can be used for a lot of different classification tasks on data. The case study from Chapter 3
attempts to classify email as either spam or ham (a good email). Building on this, another example could be
classifying a property type given charateristics, such as number of bedrooms, bathrooms, square footage, lot
size, etc. 


### Advantages of Naive Bayes
Here are some notable advantages of Naive Bayes classification models:

1. **Simplicity:** It is one of the simplest machine learning models around. That said,
it is known to outperform much more complex models, in both prediction accuracy and speed. The simplicity
is a huge plus with respect to how fast the model can be implemented, which bodes well for working 
with big data. 
2. **Good on little data:** It will be incredibly effective, even if you have a small amount of
data to work with!
3. **Intuitive:** As I mentioned, even if you have a modest background in probability, a Naive Bayes
classifier is easy to learn. 

