# This will run my server and UI for breakeven Analysis

library(shiny)
library(FinCal)
library(plotly)
library(tidyverse)

source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20Server.R")
source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20UI.R")

shinyApp(ui = ui, server = server)
