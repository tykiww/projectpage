# This will run my server and UI for breakeven Analysis
# on the interpreter. For the Shiny server, visit shiny
# website on my github page --> inform-analytics.com
library(shiny)
library(FinCal)
library(plotly)
library(tidyverse)

source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20Server.R")
source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20UI.R")

shinyApp(ui = ui, server = server)
