## create a file of numbers to validate the down load

# file path mit Daten
datapath <- file.path('..','data')
#metafile <- file.path(datapath, 'todesfaelle_meta.xlsx')
datafile <- file.path(datapath, 'todesfaelle_woche.csv')
#regiofile <- file.path(datapath, 'grossregionCH.csv')

library(dplyr)
library(readr)

validator(datafile, 'check')

# Todesfälle 2000-2020
val_df <- readr::read_delim(datafile,
  delim = ';',
  col_types = cols(.default = col_character())) %>%
  mutate(YEAR=gsub('^(.{4}).*','\\1',TIME_PERIOD), 
         CW=gsub('.*(.{2})$','\\1',TIME_PERIOD),
         VALUE=parse_integer(Obs_value))
  
val_df %>% glimpse()

problems(val_df$VALUE)

val_df %>%
  filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
  group_by(YEAR, GEO, AGE, SEX) %>%
  summarise(STATUS = max(Obs_status), VALUE = sum(VALUE)) %>%
  readr::write_delim(val_file1, delim = '|')

val_df %>%
  filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
  filter(Obs_status == 'P') %>%
  group_by(TIME_PERIOD, GEO, AGE, SEX, Obs_status) %>%
  summarise(VALUE = sum(VALUE)) %>%
  readr::write_delim(val_file2, delim = '|')

