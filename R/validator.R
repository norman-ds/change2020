## a validator function

library(dplyr)
library(readr)

validator <- function(datafile, type) {
  
  # reference file version
  refvers <- "27. April 2020"
  
  # reference file path
  refpath <- file.path('..','data')
  reffile <- file.path(datapath, 'ts-q-01.04.02.01.30.csv')
#  datafile <- file.path(datapath, 'todesfaelle_woche.csv')

  # reference tables file name
  reffile1 <- 'valfile1test.txt'
  reffile2 <- 'valfile2test.txt'
  
  # reference column names
  refnames <- c('TIME_PERIOD',
                'GEO',
                'AGE',
                'SEX',
                'Obs_status',
                'Obs_value',
                'YEAR',
                'CW',
                'VALUE')
  
  # return massage
  mymessage <- function() {
    tx <- NULL
    id <- 0
    add <- function(text, status=0) {
      stopifnot(status>=0 & status<=3)
      id <<- max(id,status)
      if (is.null(tx)) tx <<- text
      else tx <<- c(tx,text)
    }
    get <- function() {
      return(list(messages=tx, status=id))
    }
    return(list(add=add, get=get))
  }
  log <- mymessage()
  
  # error flag
  mystop <- FALSE
  
  # create dataframe from file
  df <- NULL
  tryCatch({
    df <- readr::read_delim(datafile,
                              delim = ';',
                              col_types = cols(.default = col_character())) %>%
      mutate(YEAR=gsub('^(.{4}).*','\\1',TIME_PERIOD), 
             CW=gsub('.*(.{2})$','\\1',TIME_PERIOD))
    
    df$VALUE=parse_integer(df$Obs_value)
    stop_for_problems(df$VALUE)
    
    # check column names
    stopifnot(names(df) == refnames)
    
    message(paste(c('Colnames:',names(df)), collapse = ','))
    log$add(sprintf('Read table %i rows and %i columns', nrow(df), ncol(df)))
  }, warning = function(c) {
    log$add(paste('Warning',c$message ),2)
  }, error = function(c) {
    log$add(paste('Error',c$message ),3)
    mystop <<- TRUE
  })
  if (mystop) return(log$get())
  
  
  # create reference tables
  df1 <- df %>%
    filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
    group_by(YEAR, GEO, AGE, SEX) %>%
    summarise(STATUS = max(Obs_status), VALUE = sum(VALUE)) %>%
    ungroup()
  df2 <- df %>%
    filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
    filter(Obs_status == 'P') %>%
    group_by(TIME_PERIOD, GEO, AGE, SEX, Obs_status) %>%
    summarise(VALUE = sum(VALUE)) %>%
    ungroup()
    
    
  # write reference tables to disc
  create <- function() {
    tryCatch({
      readr::write_delim(df1, reffile1, delim = '|')
      readr::write_delim(df2, reffile2, delim = '|')
      log$add(sprintf('Write file %s and %s', reffile1, reffile2))
    }, warning = function(c) {
      log$add(paste('Warning',c$message ),2)
    },error = function(c) {
      log$add(paste('Error',c$message ),3)
      mystop <<- TRUE
    })
  }
  
  ## check against reference data
  check <- function(variables) {
    print('..checking')
  }
  
  switch (type,
          create = create(),
          check = check()
  )

  return(log$get())
}

validator(datafile, 'create')

validator(,'check')


mymessage <- function() {
  tx <- NULL
  add <- function(text) {
    if (is.null(tx)) tx <<- text
    else tx <<- c(tx,text)
  }
  get <- function() {
    return(tx)
  }
  return(list(add=add, get=get))
}
log <- mymessage()

log$add('first')
log$get()
str(log)