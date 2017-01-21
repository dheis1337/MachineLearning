## Chapter 10
Chapter 10 focuses on k-nearest neighbor classification. The chapter begins
with an example using an example data set that can be found on the textbook's
GitHub (https://github.com/johnmyleswhite/ML_for_Hackers). 

### Learning Technique: 
k-nearest neighbor
### Learning Type: 
Supervised

###Model Overview: 
k-nearest neighbor is a classification method that is straightforward,
simple, and easy to implement. Given an observation, the algorihtm attempts to 
classify it, utilizing the classificaiton of the k-nearest points to it. In this case
'k' is a variable term that determines how many neighbors you want the algorithm 
to search for. The algorithm utlizes a measure of distance to determine which 
of the other points in a data set are considered "neighbors." That said, one
thing that a modeler can choose for this model is the type of distance used. 
Typically, the most intuitive sense of distance is used, that being Euclidean. 
However, you can use cosine distnace, Manhatttan distance, or any other mathematical
representation of distance. So, let's say we are implementing a 3-nearest neighbor
model on some data. Given an unclassified observation, the model will find the 
3 nearest points (by minimizing distance from our observation) with a known classification. 
Then, using the classifcation of these 3 points, our observation is classified 
as whichever group has the most neighboring points present. In other words, let's 
say I'm trying to classify the color of a dot using our 3-nearest neighbor model. 
We run our model, and find our 3 nearest neighbords to our observation. Let's say
of our 3 nearest neighbors, 2 are blue and 1 is red. Our model will then choose 
to classify our observation as a blue dot. 

This example provides some good thought experiments for implementing a k-nearest
neighbor model on some data. First, if you have an even number of levels that
you are trying to classify (in our example we had 2 - red and blue), you should
use an odd number for k. This is because you effectively eliminate the possibility
of a tie occurring. Second, and this is potentially more important, your k should
always be greater than the number of levels that observations can be classified as. 
This again is to eliminate the possibility of a tie occurring. 










