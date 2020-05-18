## test script for logfiles
## I will use cat, because the function is part of the base

conlog <- function(logfile="logfile.log") {
  
  lf <- logfile
  
  wfun <- function(mes, status='I') {
    
    ts <- format(Sys.time(), "%a %b %d %X %Y")
    ts <- format(Sys.time(), "%c")
    
    logline <- paste(ts, status, mes, sep = '|')
    
    cat(logline, file = lf, fill = T, append = T)
    
  }
  
  if (!file.exists(lf)) {
    wfun('Create logfile')
  }
  
  return(wfun)
  
}

writelog <- conlog()

for (j in 12:10) {
  writelog(paste('Entry', j))
}
