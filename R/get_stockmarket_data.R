library(quantmod)
getSymbols("GOOG", src = "google") 
chartSeries(GOOG)
