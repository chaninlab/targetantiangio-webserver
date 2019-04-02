library(shiny)
library(shinyjs)
library(shinythemes)
library(protr)
library(markdown)

shinyUI(fluidPage(title="TargetAntiAngio", theme=shinytheme("united"),
                  useShinyjs(),
                  navbarPage(strong("TargetAntiAngio"), collapsible = TRUE,
                             titleContent <- HTML("<b>TargetAntiAngio</b>: A sequence-based tool for the prediction and analysis of anti-angiogenic peptides"),
                             tabPanel("Submit Job", titlePanel(titleContent),
                                      sidebarLayout(
                                        
                                        sidebarPanel(
                                          tags$label(h3('Paste input sequence'),style="float: none; width: 100%;"),
                                          actionLink("addlink", "Insert example data"),
                                          tags$textarea(id="Sequence", rows=5, cols=100, style="float: none; width:100%;", ""),
                                          #actionLink("addlink", "Insert example data"),
                                          #tags$label("or",style="float: none; width: 100%;"),
                                          
                                          
                                          hr(),
                                          h3('Upload CSV file'),
                                          downloadLink("downloadExample", label = "Download example input file"),
                                          fileInput('file1', label = '', accept=c('text/FASTA','FASTA','.fasta','.txt')),
                                          hr(),
                                          
                                          #####
                                          #fileInput('file1', label = h3('Upload CSV file'),accept=c('text/FASTA','FASTA','.fasta','.txt')),
                                          
                                          #downloadLink("downloadExample", label = "Download example input file"),
                                          #HTML("<br><br>"),
                                          #####
                                          
                                          actionButton("submitbutton", "Submit", class = "btn btn-primary"),
                                          HTML("<a class='btn btn-default' href='/paap'>Clear</a>")
                                        ), #wellPanel
                                        
                                        mainPanel(
                                          tags$label("Status/Output",style="float: none; width: 100%;"),
                                          verbatimTextOutput('contents'),
                                          downloadButton('downloadData', 'Download CSV')
                                        )  
                                      ) #sidebarLayout
                             ), #tabPanel Submit Job
                             
                             #tabPanel("About", titlePanel("About"), div(includeMarkdown("about.md"), align="justify")),
                             #tabPanel("Citing Us", titlePanel("Citing Us"), includeMarkdown("cite.md")),
                             #tabPanel("Contact", titlePanel("Contact"), includeMarkdown("contact.md")),	
                             
                             copyright <- div(HTML("<br><table border=0 cellpadding=10 cellspacing=10 width='100%' height='50'><tr><td bgcolor='#f2f2f2' align='center'>Copyright © 2019 <a href='http://codes.bio'>codes.bio</a>. All rights reserved.</td></tr></table>")),
                             cat(as.character(copyright))
                  ) #navbarPage
) #fluidPage	
) #shinyUI