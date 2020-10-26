# ******************************************
# App Script for SNAP Policy Shiny Dashboard 
# ******************************************

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(plotly) # For interactive graphs; maybe use for mapping
#library(leaflet) # use for mapping?
library(lubridate)
#library(tigris) # Allows us to download US Census data; used to create state borders in the next code block


## app.R ##


##############################
# ==== BEGIN UI CODE HERE ==== 
##############################
ui <- dashboardPage(
  
  # Dashboard header title
  dashboardHeader(title = "SNAP Policy Data Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("About the Data", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    fluidRow()
  )
)




##################################
# ==== BEGIN SERVER CODE HERE ==== 
##################################
server <- function(input, output) { }

shinyApp(ui, server)
