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
which is the distance most people know and understand. The model takes a set of test data, and compares the distance from each observation in the set all observations in the training set. Once a test observation has been measured against each training observation, the k-nearest observations are selected, and the class of each of these neighbors is counted. The class
with the most neighbors wins, and our test observation is classifed using this class. 