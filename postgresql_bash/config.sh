#!/usr/bin/env bash

# directory variables
QUANTMOD_DIR="/home/woo457/Dropbox/stock_forecast"
LOADING_DIR="${QUANTMOD_DIR}/loading"

# symbol names for desired stocks
TICKERS="${QUANTMOD_DIR}/my_symbols.txt"

# start date to get stock prices from
START_DATE="2017-07-01"

# database variables
DB="stocksdb" #database name
HOST="localhost" #host name
USER="woo457" #user name

# either type password here..
export PGPASSWORD=Demons31

# ..or write password in hidden file, e.g.
# PASS_FILE="${FINANCE_DIR}/.not_secret/passfile" 
# export PGPASSWORD=$PASS_FILE
