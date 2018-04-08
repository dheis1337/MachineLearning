This is a repo for a project I did using linear regression on real estate
data in the city of Denver during the month of March for an independent study during
my undergraduate studies. In this repo you'll find the dataset I used for the project, 
a script for the model diagnostics I conducted, and the final paper I wrote. Below
is a brief synopsis of what I learned while doing the project and what I would
do differently in the future.

### What I Learned
#### Varaible Explanation
In my final paper, I wrote a section briefly detailing the variables in my dataset. 
I think this is important because it gives readers of my project some insight
into the types of variables I collected, what they mean in a practical sense, and
ultimately set the stage for the analysis

#### Using Judgement in Variable Selection
Multiple times throughout the project I learned the importance of using judgement
when selecting what predictors to use in my final model. What predictors would make
interpretation easy? What predictors allowed for the most complete cases, i.e. 
the most usable data? Which predictors are practically important in context of the
ultimate purpose of the model? These are all questions that are judgement calls, 
and can't be determined soley by using traditional model selection techniques.

#### Exploratory Data Analysis
One of the best lessons I learned was how critical EDA is in any data science project. 
This gave me a deeper insight into what my data actually looked like on a predictor-by-
predictor basis. I was also able to learn how the predictors interacted with one another,
and how they interacted with the response. 

#### Model Diagnostics
The process of model diagnostics was probably the most important thing I learned
while conducting this project. When I first began, I fit an OLS model on my data
with ease, and actually got decent results. However, this model violated a lot of 
the basic assumptions of OLS models. Had I not conducted any model diagnostics I would
have moved forward using a model that would introduce some systematic biases into
my predictions. In a production setting, this could be catastrophic to achieving
the end goal of the model. 

### What I Would Do Differently
#### More Exploratory Data Analysis
Given that EDA was one thing I found to be so important, in the future I would 
conduct a lot more in-depth EDA in order to learn more about the predictors with 
respect to my response. Specificaly, I would create more visualizations that 
mapped the response (price) onto a an aesthetic such as color and see how it 
varies across multiple predictors in the same visualization. Additionally, I would
try to create more visualizations related to the geospatial nature of the data. 

#### Geospatial Errors
In addition to doing more EDA with respect to the geospatial nature of the data, 
I would also do more digging into the errors of the model with respect to their
geospatial nature. 

#### Conforming Visualizations
Although this is small, in the future I would try to recreate some of the diagnostic
plots using ggplot2. Some of the diagnostic plots are created using a package that
utilizes base plotting, and it makes them an eyesore in the final paper. In reality,
having them different isn't a huge deal, but in any production setting having the
consistency across all visualizations is necessary. 



