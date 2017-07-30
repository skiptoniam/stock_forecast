# install.packages('forecast')
library(forecast)
library(quantmod)
getSymbols("CBA.AX")
chartSeries(CBA.AX,type = 'bars', theme = "black") 
candleChart(CBA.AX,subset='2017-2::2017', theme='white.mono',bar.type='hlc')

cba.fcast <- meanf(CBA.AX[,2],h=100)
plot(cba.fcast)

cba.fcast2 <-naive(CBA.AX[,2], h=100)
plot(cba.fcast2)
