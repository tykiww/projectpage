# server
server <- function(input, output) {
  # Objects
  TC <- reactive(round((input$variableCost * input$UnitSale) + (input$FixedCost + (input$investment / input$life)), 0)) 
  TR <- reactive(round(input$UnitSale * input$UnitPrice, 0)) 
  profit <- reactive(round(input$UnitSale * input$UnitPrice - (input$variableCost*input$UnitSale + (input$FixedCost + (input$investment / input$life))), 0))
  CBE <- reactive(round(input$FixedCost / (input$UnitPrice - input$variableCost), 2) %>% 
                    paste(c("units"), sep = " ")) 
  # convert to output
  output$TC <- renderText(TC())
  output$TR <- renderText(TR())
  output$profit <- renderText(profit())
  output$CBE <- renderText(CBE())
  
  # Render Plot
  output$Plot <- renderPlotly(
    {
    unitsX <- round(seq(0, input$UnitSale * 3, by=(input$UnitSale * input$life) / 30), 0)
    FCost <- input$FixedCost + (input$investment / input$life)
    Legend <- list(font = list(size=9), x=.1, y=1)
    
    TRevenue <- NULL
      for (i in 1:length(unitsX)) {
        TRevenue[i] <- unitsX[i]*input$UnitPrice
        TRevenue
      }
    
    TCost <- NULL
      for (i in 1:length(unitsX)) {
        TCost[i] <- (unitsX[i] * input$variableCost) + (input$FixedCost + (input$investment / input$life))
        TCost
      }
    

    
    # output Plotly
    plot_ly(x = unitsX, y = ((TRevenue+TCost)/1000)) %>%
      layout(yaxis = list(title = 'Revnue (in 1000s)'), xaxis = list(title = 'Units Sold'), legend = Legend) %>%
      add_trace(y=TRevenue, line = list(color = 'black'), name = 'Revenue', mode = 'lines') %>%
      add_trace(y=FCost, line = list(color = 'red'), name = 'Fixed costs', mode = 'lines') %>%
      add_trace(y=TCost, line = list(color = 'blue'), name = 'Total costs', mode = 'lines')
  })
}

