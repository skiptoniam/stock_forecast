library(xts)
library(quantmod)
get_symbols_postgreSQL <- function(Symbols,
                                   env=globalenv(),
                                   return.class='xts',
                                   db.fields=c('dt','open','high','low','close','volume','adjusted'),
                                   field.names = NULL,
                                   user=NULL,
                                   password=NULL,
                                   dbname=NULL,
                                   host='localhost',
                                  # port=5432,
                                  verbose=TRUE,
                                  auto.assign=TRUE,
                                  options="",
                                  search_path=NULL,...){
       # importDefaults("getSymbols.PostgreSQL")
       this.env <- environment()
         for(var in names(list(...))) {
            # import all named elements that are NON formals
              assign(var, list(...)[[var]], this.env)
         }
       # if(!hasArg(verbose)) verbose <- FALSE
       # if(!hasArg(auto.assign)) auto.assign <- TRUE
       if(!requireNamespace("DBI", quietly=TRUE))
           stop("package:",dQuote("DBI"),"cannot be loaded.")
       if(!requireNamespace("RPostgreSQL", quietly=TRUE))
           stop("package:",dQuote("RPostgreSQL"),"cannot be loaded.")
       if(is.null(user) || is.null(password) || is.null(dbname)) {
           stop(paste('At least one connection argument (',
                      sQuote('user'),
                      sQuote('password'),
                      sQuote('dbname'),") is not set"))
        }
        con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                              user=user,
                              password=password,
                              dbname=dbname,
                              host=host,
                              # port=port,
                              options=options)
       if(!is.null(search_path)) { 
             dbGetQuery(con, paste0("set search_path to ", search_path) )
           }
       db.Symbols <- DBI::dbGetQuery(db, "SELECT symbol FROM ss.price;")
       if(length(Symbols) != sum(Symbols %in% db.Symbols$symbol)) {
          missing.db.symbol <- Symbols[!tolower(Symbols) %in% tolower(db.Symbols$symbol)]
          warning(paste('could not load symbol(s): ',paste(missing.db.symbol,collapse=', ')))
                    Symbols <- Symbols[tolower(Symbols) %in% tolower(db.Symbols$symbol)]
          }
      for(i in seq_along(Symbols)) {
                  if(verbose) {
                      cat(paste('Loading ',Symbols[[i]],paste(rep('.',10-nchar(Symbols[[i]])),collapse=''),sep=''))
                  }
        query <- paste0("SELECT ",paste(db.fields,collapse=','),
                        " FROM ",table.name," WHERE symbol LIKE '",
                        if(any(Symbols[[i]] == tolower(db.Symbols))) { 
                          tolower(Symbols[[i]]) 
                          } else { 
                            toupper(Symbols[[i]])
                          },
                        "' ORDER BY dt;")
        
			rs <- DBI::dbSendQuery(con, query)
      fr <- DBI::fetch(rs, n=-1)
      fr <- xts(as.matrix(fr[,-1]),order.by=as.Date(fr[,1],origin='1970-01-01'),src=dbname,updated=Sys.time())
      colnames(fr) <- paste(Symbols[[i]],c('Open','High','Low','Close','Volume','Adjusted'),sep='.')
                if(auto.assign)
                    assign(Symbols[[i]],fr,env)
                if(verbose) cat('done\n')
      }
      DBI::dbDisconnect(con)
      if(auto.assign) return(Symbols)
      return(fr)
}

