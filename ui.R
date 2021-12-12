library(shiny)
library(shinyWidgets)
source("globals.R")

navbarPage("DS501 Case Study 3 by Jean-Philippe Pierre",
  tabPanel("Shiny App",
   fluidPage(
     
     # App title ----
     titlePanel(h1("Logistic Regression Model to Predict Whether a Person is a Liver Patient", align="center")),
     
     # Sidebar layout with input and output definitions ----
     sidebarLayout(
       
       # Sidebar panel for inputs ----
       sidebarPanel(
         
         # Input: Slider for the number of bins ----
         
         sliderInput("splitSlider", label = h3("Portion of the data to be used for testing:"), min = 0.1, 
                     max = 0.9, value = 0.2),
         
         checkboxGroupInput("selectedFeatures", label = h3("Features to use in this model:"), 
                            choices = list("age" = "age", "gender_Female" = "gender_Female", "gender_Male" = "gender_Male", "bilirubin_total" = "bilirubin_total", "bilirubin_direct" = "bilirubin_direct", "alkphos" = "alkphos", "sgpt" = "sgpt", "sgot" = "sgot", "total_proteins" = "total_proteins", "albumin" = "albumin", "agratio" = "agratio"),
                            selected = "age"),
         
         pickerInput(inputId = "featureToPlot", label = h3("Show the decision boundary for the feature:"),
                     choices = featuresVec,
                     selected = "age",
                     multiple = FALSE,
         )
       ),
       
       # Main panel for displaying outputs ----
       mainPanel(
         
         plotOutput(outputId = "decisionBoundaryPlot"),
         
         plotOutput(outputId = "featureDisplay"),
         
         plotOutput(outputId = "confusionMatrix")
         
       )
     )
   )),
  tabPanel("Report",
   fluidPage(
     titlePanel("Case Study 3 Description"),
     
     mainPanel(
       
       h4("Data Collected"),
       p("The dataset used for this project is the Indian Liver Patient Dataset (ILPD) provided by the UCI Machine Learning Repository. The dataset consists of 583 patient records. 416 of the records were for patients that had liver disease, while 167 of the records were for patients without liver disease. The dataset contained 441 records for male patients and 142 records for female patients. The purpose of the dataset is to predict whether a patient has liver disease. Every patient record contains the following information:"),
       tags$ul(
         tags$li("The patient’s age."),
         tags$li("The patient’s gender."),
         tags$li("The patient’s total bilirubin levels."),
         tags$li("The patient’s direct bilirubin levels."),
         tags$li("The patient’s alkaline phosphatase (alkphos) levels."),
         tags$li("The patient’s alamine aminotransferase (SGPT) levels."),
         tags$li("The patient’s aspartate aminotransferase (SGOT) levels."),
         tags$li("The patient’s total protein levels."),
         tags$li("The patient’s albumin levels."),
         tags$li("The ratio between the patient’s albumin and globumin levels (A/G ratio)."),
         tags$li("Whether the patient was a liver patient. That is, whether the patient had liver disease."),
       ),
       
       h4("Motivation"),
       p("This topic is interesting to me because I find it intriguing that machine learning has the potential to make predictions about patients’ health. I personally think that machine learning models that can reliably predict disease would provide a significant benefit to humanity and could potentially be used to diagnose patients in the future. As a result, I felt that I would enjoy creating a machine learning model that predicts whether a patient has liver disease."),
       
       h4("How The Data was Analyzed"),
       p("I began an exploratory analysis of the data by inspecting a few rows of the dataset."),
       
       tableOutput("dataHead"),
       
       p("I noticed that the A/G ratio attribute had missing values, so I began cleaning the dataset by removing any rows that contained missing values. I also noticed that the attribute determining whether a patient was a liver patient had values of 1 and 2. As a result, I converted its values to values of 0 and 1 to make the data more suitable for the machine learning algorithm that I was going to use. A value of 1 signified the presence of liver disease, and a value of 0 signified the absence of liver disease. Then, I standardized all other attributes. I carried this out for each row by subtracting each attribute by the mean value of the attribute and then dividing it by the standard deviation of the attribute. Also, the gender attribute had values of “Male” and “Female”, so I one-hot encoded the gender attribute to make it more appropriate for a machine learning algorithm. Thus, the gender attribute was converted into two attributes: gender_Male and gender_Female. gender_Male had a value of 1 is a patient was male, and 0 otherwise. gender_Female had a value of 1 if a patient was female, and 0 otherwise. To prepare the dataset for training, I split the dataset into a training set and a testing set. The ratio between the training set and testing set was 80/20."),
       
       p("I also transformed the training data to balance the proportion of classes. In the dataset, the ratio of patients with liver disease to patients without liver disease was approximately 70/30. As a result, the classes in the training dataset were imbalanced. I balanced the classes by using the R ROSE library. I used to ROSE library to balance the classes through a combination of oversampling and undersampling. Oversampling is a class balancing method that randomly duplicates data points from the class that is in the minority. Undersampling is a class balancing method that randomly deletes data points from the class that is in the majority. The training dataset originally contained 466 data points. I used ROSE to create a training dataset containing 400 data points that approximately had a 50/50 ratio between the classes. ROSE created the training dataset using a combination of oversampling and undersampling."),
       p("For this dataset, I decided to use logistic regression. I decided to do this because predicting whether a patient has liver disease is a classification problem. Patients either have liver disease or do not have liver disease, so predicting whether a patient has liver disease is a binary classification problem. Logistic regression is an appropriate model type for classification problems because its predictions have values of either 0 or 1, making it well suited for distinguishing between two classes."),
       p("Logistic regression is a machine learning algorithm that predicts the likelihood of a categorical outcome based on a series of input values. The input values, which are attributes derived from a dataset, are called predictors. The outcome predicted by the model is called the response. The response outputted by a logistic regression model has a value of 1 or 0. To make a prediction, logistic regression models use a series of predictors, assigning a weight to each predictor. To calculate its output, the model firstly uses the predictors and the weights to calculate a weighted sum of predictors. The formula for the weighted sum is shown below:"),
       
       tags$img(src = "pic1.png", width= "500px"),
       
       p("Then, the model calculates the sigmoid of the weighted sum. The sigmoid of the weighted sum represents the probability of the outcome the model is predicting. The formula and graph of the sigmoid function are shown below:"),
       
       tags$img(src="pic2.png", width="500px"),
       
       p("For inputs with high values, the sigmoid function outputs values close to 1. For inputs with low values, the sigmoid function outputs values close to 0. If the input is 0, the sigmoid function outputs 0.5. After the model calculates the sigmoid of the weighted sum, it produces its output by outputting 1 if the result of the sigmoid was greater than or equal to 0.5 or producing 0 if the result of the sigmoid was less than 0.5."),
       
       p("Before we use a logistic regression model for predictions, we must train it. Training a model is the process of calculating the values of weights that result in a minimum amount of error in the model’s predictions. This error is represented by an error function. This calculation is based on the predictor values and outcome values in data that is being used for training. There are numerous ways to train a model. To create models, I used the glm function from R’s stats library. By default, the glm function trains models by using the iteratively reweighted least squares method. Iteratively reweighted least squares works by iterating through each data point in the model’s training data. For each iteration, iteratively reweighted least squares firstly solves for the weight values that result in the minimum least squares error for the data point in this iteration. Then, it uses these weight values to update the weight values the model is currently using. Iteratively reweighted least squares continues to iterate and update the model’s weight values until the model’s weight values converge."),
       
       p("As part of my exploratory data analysis, I decided to create conditional density plots for each attribute in the dataset to determine whether any potential predictors had a strong relationship with the probability of being a liver patient. Here are the conditional density plots created for each data attribute:"),
       
       tags$img(src="pic4.png", width="500px"),
       tags$img(src="pic5.png", width="500px"),
       tags$img(src="pic6.png", width="500px"),
       tags$img(src="pic7.png", width="550px"),
       tags$img(src="pic8.png", width="500px"),
       tags$img(src="pic9.png", width="550px"),
       tags$img(src="pic10.png", width="500px"),
       tags$img(src="pic11.png", width="500px"),
       tags$img(src="pic12.png", width="500px"),
       tags$img(src="pic13.png", width="500px"),
       tags$img(src="pic14.png", width="500px"),
       
       p("From the figures above, we can see that there is a quadratic relationship between age and the probability of being a liver patient. We can also see that more men than women are not liver patients. Albumin and A/G ratio have a linear relationship with the probability of being a liver patient. In addition, SGOT, SPGT, and total protein levels correlate with higher probabilities of liver disease as they approach 0."),
       
       p("My model creation process began with creating a model that made random predictions. This model was created so that I could compare future models to it. The model’s ROC curve, precision, recall, F-score, and confusion table for the testing set are shown below:"),
       
       tags$img(src="pic15.png", width="500px"),
       tags$img(src="pic16.png", width="500px"),
       tags$img(src="pic17.png", width="500px"),
       
       p("The next model that I created used only one predictor: whether the patient was male. I decided to use this predictor because from the conditional density plots, it appears that less men are liver patients than women. The ROC curve, precision, recall, F-score, and confusion table of the model are shown below:"),
       
       tags$img(src="pic18.png", width="500px"),
       tags$img(src="pic19.png", width="500px"),
       tags$img(src="pic20.png", width="500px"),
       
       p("We can see that this model improves on the random one. Its AUC score has increased to 0.574. It also has a higher precision, recall, and F-score than the random model. To improve on this model, I created another model that used the following predictors: whether the patient was male, the A/G ratio, and the patient’s age. I decided to use A/G ratio and the patient’s age because I knew that they had relationships with the probability of liver disease. The model’s ROC curve, precision, recall, F-score, and confusion table for the testing set are shown below:"),
       
       tags$img(src="pic21.png", width="500px"),
       tags$img(src="pic22.png", width="500px"),
       tags$img(src="pic23.png", width="500px"),
       
       p("The model’s AUC score has increased to 0.6305. However, its precision, recall, and F-score have decreased. Because adding predictors to the model increased the AUC score, I decided to see if the AUC score would continue to increase after using all of the predictors in the dataset. The model’s ROC curve, precision, recall, F-score, and confusion table for the testing set are shown below:"),
       
       tags$img(src="pic24.png", width="500px"),
       tags$img(src="pic25.png", width="500px"),
       tags$img(src="pic26.png", width="500px"),
       
       p("The AUC score increased to 0.8332. The precision, recall, and F-score metrics have all increased compared to the previous model. In addition, this model has a higher F-score than the first model I created. The first model had an F-score of 0.8241758, while this one has an F-score of 0.8301887. The model also shows improvement in the confusion table, as this model is making less false negatives and more true positives than the previous model. After creating this model, I attempted to see whether I could further optimize the model."),
       
       p("I attempted to optimize the model by removing predictors that were not as significant in calculating the model’s output. I carried this out by computing the feature importance of each predictor, and then removing the least important predictors from the model. Feature importance is a measure of the importance of each predictor when the model is making a prediction. There are a variety of ways to measure feature importance, including using the predictors’ weights themselves as feature importance values. To calculate the feature importance of all predictors, I used the varImp function from R’s caret package, which calculates feature importance by computing the absolute value of the one sample t-statistic for each predictor."),
       
       p("The following chart shows the feature importance of each predictor:"),
       
       tags$img(src="pic27.png", width="500px"),
       
       p("According to the chart, gender_Female, gender_Male, and total_proteins are the least important predictors. I tried to optimize the model by removing these predictors and then training the model on the training set. The model’s ROC curve, precision, recall, F-score, and confusion table for the testing set are shown below:"),
       
       tags$img(src="pic28.png", width="500px"),
       tags$img(src="pic29.png", width="500px"),
       tags$img(src="pic30.png", width="500px"),
       
       p("The AUC score of this model is the same as the previous one. This model has a greater recall than the previous model, but also has a lower precision. However, its F-score has increased to 0.8311688. According to the confusion table, the overall effect of removing the least significant features was that the model makes less true negatives and false negatives. Instead, it makes more true positives and false positives. I decided to check the accuracy of each model to determine whether this model improves on the previous one in terms of accuracy. Below is a table displaying the accuracy of each model in order. As we can see, the final model has the highest accuracy. Therefore, this model slightly improves on the previous model."),
       
       tags$img(src="accuracyPic.png", width="500px"),
       
       p("The code used for this case study can be found here: <link to github>"),
       
     )
   ))
)