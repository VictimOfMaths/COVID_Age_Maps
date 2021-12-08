library(shiny)
library(ggplot2)

ui <- fluidPage(
  tags$head(tags$style(HTML('* {font-family: "Lato"};'))),
  
  titlePanel("Mapping recent COVID-19 cases by age"),
  
  sidebarPanel(
    
    selectInput('ageband', 'Select age group', c("00-04", "05-09", "10-14", "15-19", "20-24",
                                                 "25-29", "30-34", "35-39", "40-44", "45-49",
                                                 "50-54", "55-59", "60-64", "65-69", "70-74",
                                                 "75-79", "80-84", "85-89", "90+",
                                                 "00-59", "60+", 
                                                 selected="00-59")),
    radioButtons('showplots', "Select plot(s) to display", choices=c("Case rates", "Case rate changes", "Both")),
  
  ),
  
  mainPanel(
    plotOutput('plot')
  )
)