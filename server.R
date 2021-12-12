library(shiny)
library(shinyWidgets)
source("globals.R")

function(input, output, session) {
  
  getTrainData = reactive({
    set.seed(10)
    splitData = caret::createDataPartition(cleanData$is_liver_patient, p = 1 - input$splitSlider, list=F, times=1)
    assign("trainData", cleanData[splitData,], envir=.GlobalEnv)
    balancedTrainData = ovun.sample(is_liver_patient ~ ., data=trainData, method="both", N=400)$data
    return(balancedTrainData)
  })
  
  getTestData = reactive({
    set.seed(10)
    splitData = caret::createDataPartition(cleanData$is_liver_patient, p = 1 - input$splitSlider, list=F, times=1)
    assign("trainData", cleanData[splitData,], envir=.GlobalEnv)
    testData = cleanData[!row.names(cleanData) %in% row.names(trainData),]
    return(testData)
  })
  
  getModel = reactive({
    features = paste(input$selectedFeatures, collapse="+")
    modelFormula = as.formula(paste("is_liver_patient ~ ", features))
    model = glm(modelFormula, data=getTrainData(), family=binomial(link="logit"))
    return(model)
  })
  
  observeEvent(input$selectedFeatures, {
    disabledChoices = !(featuresVec %in% input$selectedFeatures)
    updatePickerInput(session = session, inputId = "featureToPlot",
                      choices = featuresVec,
                      choicesOpt = list(disabled = disabledChoices,
                                        style = ifelse(disabledChoices,
                                                       yes = "color: rgba(119, 119, 119, 0.5);",
                                                       no = "")))
  }, ignoreInit = FALSE)
  
  output$featureDisplay = renderPlot({
    produceROC(getModel(), getTestData())
  })
  
  output$decisionBoundaryPlot = renderPlot({
    produceDecisionBoundary(getModel(), input$featureToPlot)
  })
  
  output$confusionMatrix = renderPlot({
    produceConfusionMatrix(getModel(), getTestData())
  })
  
  output$dataHead = renderTable({
    head(readData)
  })
  
}