#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  theme = shinytheme("cosmo"),
  titlePanel(title="coGSEA"),
  sidebarLayout(
    sidebarPanel(
      img(src="logo2.png"),
      p(" "),
      fileInput(inputId = "Elist",label = "Elist .rds file"),
      helpText("Default max. file size is no a definitive value yet"),
      textInput(inputId = "ENTREZGenesIds", label = "Column name of the ENTREZ ids in EList$genes", value = "FeatureID"),
      fileInput(inputId = "contrast", label = "Contrast .rds file"),
      helpText("Default max. file size is no a definitive value yet"),
      radioButtons(inputId = 'geneset', label = 'MSigDB geneset', choices = c('H'='H','C2_KEGG'='C2_KEGG', 'C2_REACTOME' = 'C2_REACTOME'), selected = 'H'),
      radioButtons(inputId = 'specie', label = 'Specie', choices = c("Homo sapiens"='Homo sapiens',"Mus musculus"='Mus musculus'), selected = 'Homo sapiens'),
      checkboxGroupInput(inputId = 'GSEAMethods',
                         label = "GSEA Methods",
                         choices = c("camera",
                                     "gage",
                                     "globaltest",
                                     "gsva",
                                     "ssgsea",
                                     "zscore",
                                     "plage",
                                     "ora",
                                     "padog",
                                     "roast",
                                     "safe"),
                         selected = c("camera",
                                      "gage",
                                      "globaltest",
                                      "gsva",
                                      "ssgsea",
                                      "zscore",
                                      "plage",
                                      "ora",
                                      "padog",
                                      "roast",
                                      "safe"),
                         inline = FALSE, width = NULL, choiceNames = NULL, choiceValues = NULL),
    sliderInput(inputId = "alpha", label = "Alpha error treshold", min = 0, max =  1, step = 0.01, value = 0.05),
    radioButtons(inputId = "adjMethod", label = "p.value adjustment method", choices = c("holm","hochberg","hommel","bonferroni","BH","BY","fdr","none"), selected = "BH"),
    radioButtons(inputId = "combMethod", label = "p.value combination method", choices = c("sumz","votep","minimump","sumlog","sump","logitp","meanp","maximump"), selected = "sumlog"),
    numericInput(inputId = "min.intersection.size", label = "Minimum intersection size for SnailPlot", value = 1),
    actionButton("button","Submit")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Introduction",
                 h3(" Example dataset to try coGSEA with default parameters :"),
                 p("Elist .rds object"),
                 downloadButton('downloadElist', 'Download'),
                 p("contrast matrix .rds object"),
                 downloadButton('downloadContrast', 'Download'),
                 includeMarkdown("intro.md")
                 ),
        tabPanel("Choose condition", uiOutput("conditionToDisplay")),
        tabPanel("Condition Plots",
                 # uiOutput("conditionToDisplay"),
                 plotOutput("clustering"),
                 p("Fig 1 : Clustering of the GSEA methods on the gene-sets ranks (bases on raw p.values)."),
                 plotOutput("PCA"),
                 p("Fig 2 : PCA of the GSEA methods on the gene-sets ranks (bases on raw p.values)."),
                 # plotOutput("eigen"),
                 # p("Fig 3 : Fall of the eigen values for the PCA above."),
                 plotOutput("corPlot"),
                 p("Fig 4 : Correlation Plot of the GSEA methods on the gene-sets ranks (bases on raw p.values)."),
                 plotOutput("upsetr"),
                 p("Fig 5 : UpsetR Ensemblist plot showing the intersection of the different gene-sets found  significantly enriched (p.value < alpha) by each GSEA method. Methods retrieving 0 significantly enriched gene-sets are not included. Only exclusive intersections are taken into account."),
                 plotOutput("snailplot"),
                 p("Fig 6 : Mset Ensemblist plot showing the intersection of the different gene-sets found  significantly enriched (p.value < alpha) by each GSEA method. Methods retrieving 0 significantly enriched gene-sets are not included."),
                 plotOutput("heatmap"),
                 p("Fig 7 : Binary heatmap showing whether a gene-set is found differentially (red) expressed (p.value < alpha) by a GSEA method or not (blue). Only the gene-sets belonging the biggest intersections size (n), and the second biggest intersections size (n-1) are included."),
                 plotOutput("resumplot", brush = brushOpts(id = "plot_brush")),
                 p("Fig 8 : Summary plot combining both the logFC on the y-axis and the -log10(p.value) on the x-axis. The size of the bubbles indicates the significance (combination of p.value and logFC) while the color indicates the direction of logFC."),
                 verbatimTextOutput("brush_info"),
                 p("Table 1 : Gene-sets abbreviation mapping for condition summary plot. (Select bubbles in the graph above to visualize the information)")
                 ),
        tabPanel("Summary Plot",
                 plotOutput("summaryPlot", brush = brushOpts(id = "comparison_brush")),
                 verbatimTextOutput("brush_info2"),
                 p("Table 2 : Gene-sets abbreviation mapping for comparison summary plot. (Select bubbles in the graph above to visualize the information)")
                 ),
        tabPanel("Download",
                 # uiOutput("conditionToDisplay"),
                 downloadButton('downloadData', 'Download result table'),
                 p("   \n"),
                 downloadButton("report", "Generate report"),
                 p("Please wait while the report is generated, this might take a while... \n"))
        # tabPanel("resumPlot1")
      )
    )
  )
))
