## Chapter 3
Chapter 3 of *Machine Learning with R* covers k-nearest neighbors classification. 
The case study uses data from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+(Diagnostic) 
and attempts to classify the status of patients' breast cancer tumor - benign or 
malignant. 

### Learning Technique
k-nearest neighbors

### Learning Type
Supervised

### Model Overview
The k-nearest neighbors model is founded in comparing observations' features
using a measure of distance and then using this information to classify a new observation. 
There are multiple measures of distance, but the primary choice is Euclidean distance, 
which is the distance most people know and understand. The model takes a set of test data, and compares the distance from each observation in the set all observations in the training set. Once a test observation has been measured against each training observation, the k-nearest observations are selected, and the class of each of these neighbors is counted. The class with the most neighbors wins, and our test observation is classifed using this class. 

Some important things to note about the k-nearest neighbor model is that it technically
isn't a model, but more of an algorithm. The reason I make this distinction is because
after the training phase, there is no output that can be evaluated to learn about the
parameters of our data. This differs from other machine learning models, like a linear
regression model, because we can evaluate what our model has learned from our data. 
Thus, the k-nearest neighbor algorithm is considered to be non-parametric, since it
makes no assumptions about the data, and doesn't develop estimations for data parameters. 
This is also what leads k-nearest neighbor to be considered a lazy learning algorithm. 

### Applications
The k-nearest neighbor algorithm works great for classification, clustering, and 
even dimensionality reduction. It is commonly used as a component in ensemble models, 
but can be used as a standalone algorithm for data problems. 

### Advantages of k-Nearest Neighbors
1. **Simplicity:** The algorithm itself is fairly straightforward to understand
and implement. Therefore, it's popular in machine learning settings. 
2. **No assumptions made:** Since k-nearest neighbor is a non-parametric form of 
learning, no assumptions about your data need to be made. This makes the algoritm
flexible. 
3. **Fast Training:** Because the algorithm works to compare new observations with
training data, the actual training phase is extremely fast. However, this does lead 
to some problems during testing. 

### Disadvantages of k-Nearest Neighbors
1. **Slow Testing:** As mentioned, each new observation is refereced to every observation
in the training set. Therefore, if you have a lot of data, the testing phase can be
computationally expensive. 
2. **Selecting k:** In order to develop an effective k-nearest neighbor algorithm, 
you must choose an appropriate k. There are few things that drive the choice for k, 
but it is ultimately up to the discretion of the data scientist. 
3. **Not a model, technically:** Because there is no underlying model, there isn't
much that can be learned from the data.
4. **Non-numeric data troubles:** If you have nominal variables or missing values 
you must preprocess them further. 

### Takeaways 
Here are a few things that I learned from completing this chapter:

1. **Normalizing numeric data:** Since k-nearest neighbors uses distances to 
compare observations, it's imperative that data is normalized. If some variables
have a range in the thousands, and others have a range that is less than one, the 
model will be biased towards the larger variables. Normalizing is a process that 
can eliminate this problem. 
2. **Simple models are effective:** Even though k-nearest neighbors is extremely simple,
it is also extremely effective. In fact, our model was 98% accurate when applied to the
problem in this chapter. 







