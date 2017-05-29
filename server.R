#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(coGSEA)


data("il13.data")
v = il13.data$voom
contr.matrix = il13.data$contra



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {


  ElistObject <-  eventReactive( input$button, {
    file1 <- input$Elist
    if(is.null(file1)){return()}
    Elist = readRDS(file1$datapath)
    return(Elist)
  })

  contrast <-  eventReactive( input$button, {
    file2 <- input$contrast
    if(is.null(file2)){return()}
    contrastMat = readRDS(file2$datapath)
    return(contrastMat)
  })

  runner <- observeEvent(input$button,{
    resOutput()
  })

  resOutput = eventReactive( input$button, {
    progress <- Progress$new(session, min=0, max=5)
    on.exit(progress$close())

    progress$set(message = 'Calculation in progress',
                 detail = 'This may take a while...')
    result = coGSEA(ElistObject = ElistObject(),
                   contrastMatrix = contrast(),
                   geneSetCollection = input$geneset,
                   specie = input$specie,
                   ENTREZGenesIds = ElistObject()[["genes"]][[input$ENTREZGenesIds]],
                   GSEA.Methods = input$GSEAMethods,
                   pvalAdjMethod = input$adjMethod,
                   pvalCombMethod = input$combMethod,
                   directoryPath = "./",
                   alpha = input$alpha,
                   num.workers = 4,
                   shinyMode = TRUE)
    return(result)
    progress$set(value = 5)
  })


  output$conditionToDisplay <- renderUI({
    radioButtons("conditionToDisplay", label="Choose one condition:", choices=colnames(resOutput()$contrast), selected = colnames(resOutput()$contrast)[1])
  })

  output$contrastTable <- renderTable({
    resOutput()$contrast
  })

  output$clustering <- renderPlot({
    plot(resOutput()[["clustering"]][[input$conditionToDisplay]],hang = -0.1)
  })

  output$PCA <- renderPlot({
    res.pca = PCA(resOutput()$PCA[[input$conditionToDisplay]], scale.unit = T, axes = c(1,2), graph = FALSE)
    plot(res.pca)
  })

  output$eigen <- renderPlot({
    res.eigen = PCA(resOutput()$PCA[[input$conditionToDisplay]], scale.unit = T, axes = c(1,2), graph = FALSE)
    eigen = res.eigen$eig$`percentage of variance`
    names(eigen) = rownames(res.eigen$eig)
    barplot(eigen, las = 2, ylab = "%")
  })

  output$corPlot <- renderPlot({
    corrplot(resOutput()$correlation[[input$conditionToDisplay]], method = "circle", type = "full", order = "hclust",mar=c(2, 4, 4, 2) + 0.1)
  })

  output$upsetr <- renderPlot({
    upset(fromList(resOutput()$snailPlot[[input$conditionToDisplay]]),order.by = "freq")
  })

  output$snailplot <- renderPlot({
    snail = supertest(resOutput()$snailPlot[[input$conditionToDisplay]], n = length(levels(resOutput()$snailPlot[[input$conditionToDisplay]][[1]])))
    plot.msets(snail, sort.by="size", keep.empty.intersections=FALSE, min.intersection.size = input$min.intersection.size)
  })

  output$heatmap <- renderPlot({
    pheatmap::pheatmap(resOutput()$heatmap[[input$conditionToDisplay]], fontsize = 8)
    # heatmapPlot(preparedData = resOutput(), contrCondi = input$conditionToDisplay, savePlot = FALSE, directoryPath = "./")
  })

  output$resumplot <- renderPlot({
    generateSummaryPlots(resOutput()$resumPlot2[[input$conditionToDisplay]], savePlot = FALSE, legend = FALSE, file.name = "tmp", format = "pdf")
  })

  output$brush_info <- renderPrint({
    brushedPoints(resOutput()$resumPlot2[[input$conditionToDisplay]], input$plot_brush)
  })

  # output$abbreviation <- renderTable({
  #   resOutput()$abbreviation[[1]]
  # })

  output$summaryPlot <- renderPlot({
    generateSummaryPlots(resOutput()$comparison, savePlot = FALSE, legend = FALSE, file.name = "tmp", format = "pdf")
  })

  output$brush_info2 <- renderPrint({
    brushedPoints(resOutput()$comparison, input$comparison_brush)
  })

  output$downloadData <- downloadHandler(
    # filename = function() { paste(as.character(input$conditionToDisplay),".csv", sep = '') },
    filename = function() {
      paste(as.character(input$conditionToDisplay), ".csv", sep="")
    },

    # filename = function(){"renameToContrast.csv"},
    content = function(file){
      write.csv(resOutput()$result[[input$conditionToDisplay]], file)
    }
  )

  output$downloadElist <- downloadHandler(
    filename = function(){"elist.rds"},
    content = function(file){
      saveRDS(v, file)
    }
  )

  output$downloadContrast <- downloadHandler(
    filename = function(){"contrast.rds"},
    content = function(file){
      saveRDS(contr.matrix, file)

    }
  )

  output$report = downloadHandler(
    filename = 'coGSEAreport.html',

    content = function(file) {
      out = knit2html('report.Rmd', force_v1 = TRUE)
      # out = knit2pdf('report.Rmd')
      file.rename(out, file) # move pdf to file for downloading
    },

    contentType = 'application/html'
  )
})
