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

## Metadatei (XLSX) Datei (200kB)
urlmeta <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/12927169/appendix"
destmeta <- "../data/todesfaelle_meta.xlsx"
curl::curl_download(urlmeta, destmeta)

## CSV (ASCII) Datei (ca. 18MB)
urlcsv <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/12927169/master"
destcsv <- "../data/todesfaelle_woche.csv"
curl::curl_download(urlcsv, destcsv)


