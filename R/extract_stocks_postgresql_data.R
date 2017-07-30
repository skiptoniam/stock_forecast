# Libs 
library('RPostgreSQL') # http://code.google.com/p/rpostgresql/
library('quantmod') 
library('TTR') 

# Connect and get data 
drv <- dbDriver('PostgreSQL') 
db <- dbConnect(drv, host='localhost', user='woo457', dbname='stocksdb', 
                password='Demons31') 

fr <- dbGetQuery(db, "SELECT symbol FROM ss.price;")

table.name <- 'ss.price'
query <- paste0("SELECT ",paste(db.fields,collapse=',')," FROM ",table.name," WHERE symbol LIKE '",if(any(Symbols[[i]] == tolower(db.Symbols))) { 
         tolower(Symbols[[i]]) } else { toupper(Symbols[[i]])
         }, "' ORDER BY dt;")

fr <- dbGetQuery(db, query)

# Clean up. 
dbDisconnect(db) 
dbUnloadDriver(drv) 

library(devtools)
#install_github("DataWookie/flipsideR")
# library(flipsideR)
library(quantmod)
# OZL = flipsideR::getOptionChain('CBA.AX')
getSymbols("SQ")
candleChart(SQ,subset='2016-12::2017', theme = chartTheme("white")) 
chartSeries(CBA.AX, theme = chartTheme("white")) 
candleChart(CBA.AX,subset='2016-12::2017', theme = chartTheme("white")) 
candleChart(NAB.AX,subset='2017-03::2017', theme = chartTheme("white")) 


get_symbols_postgreSQL(Symbols,user='woo457',password='Demons31',
            dbname='stocksdb')
chartSeries(MSCI, theme = chartTheme("white")) 
