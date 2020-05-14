# Wöchentliche Todesfälle 2020 (BFS Grafik, deutsch)
#png_de <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/12927127/thumbnail?width=540&height=564"

# Wöchentliche Todesfälle 2020 (BFS Daten zur Grafik, deutsch)
url <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/12927127/appendix"

# Wöchentliche Todesfälle 2020 (BFS, deutsch)
#url <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/12927124/master"
#tmp <- tempfile()
destfile <- "../data/todesfaelle_woche.csv"

curl::curl_download(url, destfile)
