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
4. **Great for categorical data:** If you have observations that are characterized by categorical data, 
a Naive Bayes model is right for you! This is really where Naive Bayes shines, because it allows the model 
to remain as simple as possible. If you have numerical data, the data is assumed to be normal, which is a strech
most of the time. 

### Disadvantages of Naive Bayes
Here are some notable disadvantages of Naive Bayes classification models:

1. **Using new data:** One potential hiccup that can be presented to a Naive Bayes classifier is the introduction
of a new class in categorical data that wasn't in the original training data. If your classifier is given an observation
that is of class x4, but it hadn't seen class x4 during the training phase, it won't know what to do. 
2. **Naive assumption:** This one is probably pretty obvious, but since we make the "naive" assumption of independence
among features, it can sometimes lead to poor performance. Think about highly correlated features. 

### Takeaways:
Here are a few takeaways I learned from completing this chapter:

1. **Keep it simple, stupid (K.I.S.S.):** Naive Bayes classification is a testament to this idiom, and I found 
a great appreciation for the power of simple models. Simple models allow you to be flexible in their implementation,
while still maintaining great predicitive power. Additionally, simple models help ensure you're not overfitting
your data!
2. **Building models "ground up":** While black box implementations of models are great, they aren't the best
for learning the intuition behind a given model. Completing this chapter really helped me understand the
nuts and bolts of Naive Bayes classification.
3. **Troubleshooting is always necessary:** This chapter probably had the most errors in it, and I even had to 
adjust the algortihm a little for it to work properly. No matter how advance a data scientist becomes, they 
will **always** be required to do a little troubleshooting to implement their model correctly. 
4. **The power of probability:** One reason this model is so simple is because it's founded in probability theory. 
Probability is the essence of all statistics, and it's power shouldn't be overlooked when determining how to model
data. 


