library(mltools)
library(data.table)
library(caret)
library(visreg)
library(tidyverse)
library(ROSE)

readData = read.csv("liverdata.csv", col.names = c("age", "gender", "bilirubin_total", "bilirubin_direct", "alkphos", "sgpt", "sgot", "total_proteins", "albumin", "agratio", "is_liver_patient"))

cleanData = data.frame(readData)
#liver_patient column was originally 1 and 2
cleanData$is_liver_patient = cleanData$is_liver_patient - 1

#standardize numerical data
cleanData$bilirubin_total = scale(cleanData$bilirubin_total)
cleanData$bilirubin_direct = scale(cleanData$bilirubin_direct)
cleanData$age = scale(cleanData$age)
cleanData$alkphos = scale(cleanData$alkphos)
cleanData$sgpt = scale(cleanData$sgpt)
cleanData$sgot = scale(cleanData$sgot)
cleanData$total_proteins = scale(cleanData$total_proteins)
cleanData$albumin = scale(cleanData$albumin)
cleanData$agratio = scale(cleanData$agratio)


#one hot encode gender
cleanData$gender = as.factor(cleanData$gender)
cleanData = one_hot(as.data.table(cleanData))
cleanData$is_liver_patient = as.factor(cleanData$is_liver_patient)


featuresVec = c("age", "gender_Female", "gender_Male", "bilirubin_total", "bilirubin_direct", "alkphos", "sgpt", "sgot", "total_proteins", "albumin", "agratio")

#set.seed(10)

#splitData = caret::createDataPartition(cleanData$is_liver_patient, p = 0.8, list=F, times=1)

#trainData = cleanData[splitData,]
#testData = cleanData[!row.names(cleanData) %in% row.names(trainData),]

produceROC = function(model,testData) {
  
  pred = predict(model, testData[,1:11], type="response")
  pObject = ROCR::prediction(pred, testData$is_liver_patient)
  
  rocObj = ROCR::performance(pObject, measure="tpr", x.measure="fpr")
  aucObj = ROCR::performance(pObject, measure="auc")  
  plot(rocObj, main = paste("Area under the curve:", round(aucObj@y.values[[1]] ,4)))
  
}

produceDecisionBoundary = function(model, feature) {
  visreg::visreg(model, feature, scale="response", partial=TRUE, xlab=feature, ylab="Probability of being a liver patient", rug=2, gg=TRUE) + ggtitle("Decision Boundary of Model") + 
    theme(
    plot.title=element_text(family='', face='bold', size=20, hjust=0.5)
  )
}

produceConfusionMatrix = function(model, testData) {
  pred = predict(model, testData, type="response")
  thresh = 0.5
  facHat = cut(pred, breaks=c(-Inf, thresh, Inf), labels=c(0, 1))
  cTab   = xtabs(~ is_liver_patient + facHat, data=testData)
  addmargins(cTab)
  
  cmDF = as.data.frame(cTab)
  
  ggplot(cmDF, aes(x = is_liver_patient, y = facHat, fill = Freq)) +
    geom_tile() +
    geom_text(aes(label = Freq), colour = "white") +
    labs(x = "Ground Truth", y = "Predicted Value", title="Confusion Matrix") +
    theme(
      plot.title=element_text(family='', face='bold', size=20, hjust=0.5)
    )
}
