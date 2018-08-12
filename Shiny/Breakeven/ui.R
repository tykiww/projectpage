# UI set up
library(shiny)
library(plotly)
library(tidyverse)

{
  # import fonts
  fontImp <- tags$style(HTML("@import url('https://fonts.googleapis.com/css?family=PT+Sans');"))
  # font 1
  font1 <- "font-family: 'PT Sans', sans-serif; color: #85144b; font-size: 35px;"
  # font 2
  font2 <- "font-family: 'PT Sans', sans-serif; color: #85144b; font-size: 15px;"
  # font 3
  font3 <- "font-family: 'PT Sans', sans-serif; color: #85144b; font-size: 14px;"
  # bold
  bold <- "font-weight: bold;"
  
  # Title Panel
  mainTitle <- titlePanel(h1("Simple Break-even Calculator",style = font1))
  
  # Top Body
  col1 <- column(4, style = font2,
                 wellPanel(numericInput("UnitSale", "Expected units sold per year", value = 6000, min = 0),
                           numericInput("UnitPrice", "Expected price per unit", value = 18, min = 0)))
  col2 <- column(4, style = font2,
                 wellPanel(numericInput("variableCost", "Variable cost per unit",value = 10, min = 0),
                           numericInput("FixedCost", "Total Fixed cost", value = 10000, min = 0)))
  col3 <- column(4, style = font2,
                 wellPanel(numericInput("investment", "Initial investment", value = 1000, min = 0),
                           numericInput("life", "Investment (yrs)",value = 5, min = 0)))
  
  topBody <- fluidRow(col1 , col2, col3)
  
  # Bottom Body
  bottomLeft <- column(3, style = font3,
                       wellPanel(
                         h5("Yearly revenue"), textOutput("TR"),
                         h5("Total cost"), textOutput("TC"),
                         h5("Year's Profit"), textOutput("profit"),
                         h5("Expected Long Run Profit"), textOutput("eprofit"),
                         h5("Break-even Volume"), textOutput("CBE")))
  
  bigPlot <- column(9, wellPanel(style="background-color: maroon;", plotlyOutput("Plot")))
} 

# user interface
ui <- fluidPage( fontImp, mainTitle, topBody,bigPlot, bottomLeft)
