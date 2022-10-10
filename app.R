#### Librerias ####
pacman::p_load(shiny,sf,leaflet,htmlwidgets,shinydashboard,
               readxl,dplyr,tidyverse,stringr,tidyr,shinyWidgets,plotly,formattable)

#### Bases ####
Ingre <- read_excel("IngresoRealDeflactado.xlsx")

LinPob <- read_excel("LineasdePorezaPorIngreso2005-2002.xlsx")
colnames(LinPob)[2] <- "Trimestre"

BaseFinal <- merge(Ingre,LinPob, by= c("Anio","Trimestre"))
BaseFOut <- BaseFinal
colnames(BaseFOut) <- c("Año","Trimestre","Entidad Federativa","Ingerso Laboral Real Per Cápita Deflactado", "Tipo de Linea", "Valor Linea")
#### Variables Pertinentes ####

Year <- unique(Ingre$Anio)

TipLin <- unique(LinPob$Tipo_Linea)

Ent <- unique(Ingre$Ent_Federativa)

Ingre$Ingreso_Laboral_Per_Capita_Deflactado <- currency(Ingre$Ingreso_Laboral_Per_Capita_Deflactado, digits = 2L)

#### ui ####

ui <- 
  dashboardPage( skin = "green",
                 
  dashboardHeader(title = "Ingreso Real en México", titleWidth = 300),
  
  dashboardSidebar(width = 300,
                   
                   numericRangeInput(
                     inputId = "Anio", label = "Año(s) :",
                     value = c(2005,2022),
                     min = 2005,
                     max = 2022,
                     step = 1,
                     separator = " al ",
                     ),
                   
                   checkboxGroupButtons(
                     inputId = "Trim",
                     label = "Trimestre(s) :",
                     choices = c("I", 
                                 "II", "III", "IV"),
                     selected = c("I","II","III","IV"),
                     justified = TRUE,
                     checkIcon = list(
                       yes = icon("ok", 
                                  lib = "glyphicon"))
                     ),
                   
                     pickerInput(
                     inputId = "Enti",
                     label = "Entidad(es) :", 
                     choices = c(Ent),
                     selected = "Nacional",
                     options = pickerOptions(actionsBox = TRUE,
                                             liveSearch = TRUE,), 
                     multiple = TRUE,
                     choicesOpt = list(
                       style = rep(("color: black; background: white; font-weight: bold;"),33))
                     ),
                   
                   pickerInput(
                     inputId = "LinPo",
                     label = "Linea(s) de Pobreza :", 
                     choices = c(TipLin),
                     selected = c("LPI-Rural","LPI-Urbano" ),
                     options = pickerOptions(actionsBox = TRUE,
                                             liveSearch = TRUE,), 
                     multiple = TRUE,
                     choicesOpt = list(
                       style = rep(("color: black; background: white; font-weight: bold;"),33))
                   ),
                   helpText("LPI : Línea de pobreza por ingresos; LPEI : Línea de pobreza extrema por ingresos"),
                   helpText("Fuente : Elaboración de Fernando Pérez Escobar, con información del CONEVAL"),
                   helpText("Nota b: Para consultar la base de Lineas de Pobreza, ingresar a la página de ",
                            tags$a(href = "http://sistemas.coneval.org.mx/InfoPobreza/Pages/wfrLineaBienestar?pAnioInicio=2016&pTipoIndicador=0",
                              target="_blank", " Líneas de pobreza por ingresos del CONEVAL")),
                   helpText("Nota c: Para consultar los ingresos promedio real por entidad, consultar los ",
                            tags$a(href = "https://www.coneval.org.mx/Medicion/Paginas/ITLP-IS_pobreza_laboral.aspx#:~:text=32.3%25%2C%20respectivamente.-,Ingreso%20laboral%20real%20per%20cápita,un%20aumento%20de%20%2430.66%20pesos.",
                              target="_blank", " Indicadores de Pobreza Laboral del CONEVAL"))
                     
  ),
  dashboardBody(
    tabsetPanel(
      tabPanel("Gráfica",plotlyOutput("Graph"),icon = icon("bar-chart-o")
               ),
      tabPanel("Base de Datos", dataTableOutput("Base"),icon = icon("database")
               ),
      tabPanel("Read Me",  uiOutput("RdM"), icon = icon("comment")
      ),
      )
    )
  )

#### server ####

server <- function(input, output) {
  
  
  FilDa <- reactive({
    req(input$Anio)
    Dy <- c(input$Anio)
    a <- BaseFinal %>% filter(Anio %in% c(seq(min(Dy),max(Dy))))
    b <- a %>% filter(Trimestre %in% c(input$Trim))
    d <- b %>% filter(Ent_Federativa %in% c(input$Enti))
    m <- d %>% filter(Tipo_Linea %in% c(input$LinPo))
    return(unique(m))
  })
    output$Graph <- renderPlotly({ 
      
      plot_ly(FilDa())%>%
        add_trace(x = ~interaction(FilDa()$Anio,FilDa()$Trimestre, lex.order = TRUE),
                  y = ~FilDa()$Ingreso_Laboral_Per_Capita_Deflactado, 
                  color = FilDa()$Ent_Federativa,
                   type = "scatter",mode = 'lines') %>%
       add_trace(x = ~interaction(FilDa()$Anio,FilDa()$Trimestre, lex.order = TRUE),
                y = ~FilDa()$Valor, mode = 'markers',type = "scatter",
               color = FilDa()$Tipo_Linea) %>%
        layout(height = 550, width = 1050,
               xaxis = list(title = 'Año / Trimestre'),
               yaxis = list(title = 'Pesos Mexicanos ($)'),
               title = 'Ingreso Promedio real deflactado en México vs Lineas de Pobreza',
               annotations = 
                        list(x =1.15,  y = -.19, text = "", 
                             showarrow = F, xref='paper', yref='paper', 
                             xanchor='right', yanchor='auto', xshift=0, yshift=0,
                             font=list(size=8.5)
                             ),
               plot_bgcolor = "rgb(220,220,220)"
               )
      })
    output$Base <- renderDataTable(FilDa())
    output$RdM <- renderUI({
      str1 <- paste("1. Respecto a los datos de Ingreso, debido a la contingencia sanitaria por la COVID-19, el INEGI suspendió la recolección de información de la ENOE referente al segundo trimestre 2020, por lo cual no se cuenta con dicha información")
      str2 <- paste("2. Los datos de Ingreso están deflactados con el INPC del primer trimestre de 2020")
      str3 <- paste("3. El coneval menciona que de acuerdo con el INEGI, a partir del primer trimestre de 2016 se consideran las estimaciones poblacionales trimestrales generadas por el Marco de Muestreo de Viviendas 2020 del INEGI. La información del primer trimestre de 2005 al cuarto trimestre de 2015  toma en cuenta la estimación de población con base en las proyecciones demográficas de CONAPO 2013." )
      str4 <- paste("4. Para las lineas de pobreza se consideran los valores de Marzo, Junio, Septiembre y Diciembre, que corresponden al trimestre I al IV respectivamente")
      
      HTML(paste(str1, str2,str3,str4, sep = '<br/>'))
    })
   
    
}

# Run the application 
shinyApp(ui = ui, server = server)
