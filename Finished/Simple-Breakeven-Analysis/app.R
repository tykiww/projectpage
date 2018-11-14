library(shiny)
library(plotly)
library(tidyverse)

source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20Server.R")
source(file = "https://raw.githubusercontent.com/tykiww/projectpage/master/Shiny/BreakEven%20UI.R")

shinyApp(ui = ui, server = server)