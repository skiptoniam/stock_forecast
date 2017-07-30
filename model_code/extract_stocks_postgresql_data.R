# Libs 
library(RPostgreSQL) # http://code.google.com/p/rpostgresql/
library(TTR) 
library(quantmod)
getSymbols("CBA.AX")
chartSeries(CBA.AX,type = 'bars', theme = "black") 
candleChart(CBA.AX,subset='2016-12::2017', theme = chartTheme("white")) 

get_symbols_postgreSQL('MSCI',user='woo457',password='pass', dbname='stocksdb')
chartSeries(MSCI,subset='last 3 months')
addBBands(n = 19, sd = 2, ma = "SMA", draw = 'bands', on = -1)
