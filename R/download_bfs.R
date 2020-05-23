## Wöchentliche Resultate
## https://www.bfs.admin.ch/bfs/de/home/statistiken/bevoelkerung/geburten-todesfaelle/todesfaelle.html
## Die Todesfälle werden täglich den Zivilstandsämtern gemeldet 
## und dem BFS im Rahmen der Statistik der natürlichen 
## Bevölkerungsbewegung (BEVNAT) mitgeteilt. Der Melde- 
## und Verarbeitungsprozess dauert in der Regel neun Tage.
##
## Die Referenzbevölkerung ist die ständige Wohnbevölkerung, 
## d.h. die Personen mit ständigem Wohnsitz in der Schweiz. 
## Todesfälle von Personen mit Wohnsitz in der Schweiz, die 
## sich im Ausland ereignet haben, werden gezählt.
##
## Die Dateien sind wöchentlich aktualisiert.

## Todesfälle nach Fünf-Jahres-Altersgruppe, Geschlecht, 
## Woche und Kanton (CSV-Datei)
## Zeitraum 3.1.2000 bis heute minus 10 Tage

## opendata.swiss stellt die Daten zur Verfügung
## https://opendata.swiss/de/dataset/todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei4"
open_url <- "https://opendata.swiss/api/3/action/package_show?id=todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei4"
rest_api <- jsonlite::fromJSON(open_url, flatten = T)

api_meta <- c(
  name=rest_api[[3]]$display_name$de,
  erstellt=rest_api[[3]]$issued,
  von=rest_api[[3]]$temporals$start_date,
  bis=rest_api[[3]]$temporals$end_date
)

aourldest <- tempfile()
curl::curl_download(aourl, aourldest)

## CSV (ASCII) Datei (ca. 18MB)
urlcsv <- rest_api[[3]]$resources$download_url[2]
destcsv <- "../data/new_todesfaelle_woche.csv"
curl::curl_download(urlcsv, destcsv)
