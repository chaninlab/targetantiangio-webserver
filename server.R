library(protr)
library(seqinr)
library(randomForest)

shinyServer(function(input, output, session) {
  
  # Loads the Model to memory
  filepath <- file.path("data","Model.rds")
  mod <- readRDS(filepath)
  
  
  observe({
    
    shinyjs::hide("downloadData") # Hide download button before input submission
    if(input$submitbutton>0)
      shinyjs::show("downloadData") # Show download button after input submission
    
    FASTADATA <- ''
    fastaexample <- '>AA1
AAPFLECQGRQGTCHFFAN
>AA2
ANIKLSVQMKLFKRHLKWKIIVKLNDGRELSLDA
>AA3
ARPAKAAATQKKVERKAPDA
>AA4
ASWSACSVSCGGGARQRTR
>AA5
ATPFIECSGARGTCHYFAN
>neg1
ADNWQSFDRWKDH
>neg2
AEALAALRALADKNQVF
>neg3
AERWREAAKLI
>neg4
AFAQFGSDLDAATQKLLNRGARLTELMKQPQ
>neg5
AGAGYALLALIGTEAAS
'
    
    if(input$addlink>0) {
      isolate({
        FASTADATA <- fastaexample
        updateTextInput(session, inputId = "Sequence", value = FASTADATA)
      })
    }
  })
  
  datasetInput <- reactive({
    
    inFile <- input$file1 
    inTextbox <- input$Sequence

    if (is.null(inTextbox)) {
      return("Please insert/upload sequence in FASTA format")
    } else {
      if (is.null(inFile)) {
        # Read data from text box
        x <- inTextbox
        write.fasta(sequence = x, names = names(x),
                    nbchar = 80, file.out = "text.fasta")
        xtest <- readFASTA("text.fasta")
        
        A <- xtest[(sapply(xtest, protcheck))]###check special symbol
        m = length(A)
        
        # Set parameters
        pse = 1
        weightpse = 0.9
        ampse = 1
        weightampse = 0.9
        
        # Calculate AAC
        AAC <- t(sapply(A, extractAAC))
        
        # Calculate PAAC
        PAAC <- matrix(nrow = m, ncol = 20 + pse)
        for(i in 1:m){ 
          PAAC[i, ] = extractPAAC(A[[i]][1],lambda = pse, w = weightpse, props = c("Hydrophobicity", "Hydrophilicity", "SideChainMass"))
        }
        
        # Calculate APAAC
        col = 20+ 2*ampse
        APAAC  <- matrix(nrow = length(A), ncol = col)
        for (i in 1:length(A)){
          APAAC[i,] = extractAPAAC(A[[i]][1],lambda = ampse, w = weightampse, customprops = NULL)
        }
        
        # Merge descriptor into single data frame
        Dtest <- data.frame(AAC,PAAC,APAAC)
        
        # Predicting unknown sequences
        results <- data.frame(Prediction= predict(mod,Dtest), round(predict(mod,Dtest,type="prob"),3))
        
        print(results)
      } 
      else {  
        # Read data from uploaded file
        xtest <- readFASTA(inFile$datapath)
        
        A <- xtest[(sapply(xtest, protcheck))]###check special symbol
        m = length(A)
        
        # Set parameters
        pse = 1
        weightpse = 0.9
        ampse = 1
        weightampse = 0.9
        
        # Calculate AAC
        AAC <- t(sapply(A, extractAAC))
        
        # Calculate PAAC
        PAAC <- matrix(nrow = m, ncol = 20 + pse)
        for(i in 1:m){ 
          PAAC[i, ] = extractPAAC(A[[i]][1],lambda = pse, w = weightpse, props = c("Hydrophobicity", "Hydrophilicity", "SideChainMass"))
        }
        
        # Calculate APAAC
        col = 20+ 2*ampse
        APAAC  <- matrix(nrow = length(A), ncol = col)
        for (i in 1:length(A)){
          APAAC[i,] = extractAPAAC(A[[i]][1],lambda = ampse, w = weightampse, customprops = NULL)
        }
        
        # Merge descriptor into single data frame
        Dtest <- data.frame(AAC,PAAC,APAAC)
        
        # Predicting unknown sequences
        results <- data.frame(Prediction= predict(mod,Dtest), round(predict(mod,Dtest,type="prob"),3))
        
        print(results)
      }
    }
  })
  
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
      isolate(datasetInput()) 
    } else {
      return("Server is ready for prediction.")
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { paste('predicted_results', '.csv', sep='') },
    content = function(file) {
      write.csv(datasetInput(), file, row.names=TRUE)
    })
  
  
  output$downloadExample <- downloadHandler(
    filename <- function() {
      paste("example", "fasta", sep=".")
    },
    content <- function(file) {
      file.copy("examples.fasta", file)
    },
    contentType = "text/csv"
  )
  
  
})
