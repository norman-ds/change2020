# Lesen der Daten und als List zur Verfügung stellen
# Zwei Funktionen für linplots und barlots
# workflow für erstellen aller charts und speichern in directory

# file path mit Daten
datapath <- file.path('..','download','data')
imagepath <- file.path('..','images')

library(ggplot2)
library(dplyr)
library(readr)

fundeath <- function(fpath) {
  
  # (20MB) Todesfälle der Jahre 2000-2020 nach Fünf-Jahres-Altersgruppe, Geschlecht, Woche und Kanton
  fn4 <- 'ts-q-01.04.02.01.30.csv' 
  
  # Kantonsliste mit KZ und Namen
  dfkanton <- readr::read_delim(file.path(fpath,'grossregionCH.csv'),
                               delim = ';',
                               col_types = cols(.default = col_character())) 
  
  ##############
  # dataframe nach Kanton und drei Altersgruppen
  dfdeath <- readr::read_delim(file.path(fpath,fn4),
                               delim = ';',
                               col_types = cols(.default = col_character())) %>%
    filter(AGE != '_T', SEX=='T') %>%
    mutate(year=gsub('^(.{4}).*','\\1',TIME_PERIOD), cw=gsub('.*(.{2})$','\\1',TIME_PERIOD)) %>%
    mutate(cw = as.integer(cw)) %>%
    mutate(AC0=gsub('(.+[ET])([0-9]?)([049])$','\\2\\3',AGE)) %>%
    mutate(AC1=as.integer(AC0)) %>%
    #mutate(age=if_else(AC1<=64,'0-64','65+')) %>%
    mutate(age=as.character(cut(AC1, breaks = c(0,64,80,100), labels = c("0-64", "65-79", "80+")))) %>%
    group_by(geo=GEO, year, cw, age) %>%
    summarise(value=sum(as.double(Obs_value))) %>%
    group_by(geo, year, age) %>%
    mutate(value_cum = cumsum(value)) %>%
    ungroup() %>%
    mutate(ggeo=gsub('^(CH0[1-7]).$','\\1',geo)) %>%
    inner_join( dfkanton, by='geo' )
  
  ##############
  # Konstanten zum aktuellsten Jahr und Kalenderwoche
  year_last <- '2020'
  cw_last <- max(dfdeath[dfdeath$year==year_last,]$cw)
 
  return(list(data=dfdeath, regions=dfkanton, year=year_last, cw=cw_last))
}



plotline <- function(datalist, kanton) {
  
  ##############
  # Funktion für line-plot nach Region

    # Grafiktitel
    my_titel <- sprintf('Region %s',datalist$regions$kanton2[datalist$regions$kanton==kanton])
    
    # Koordinaten für Grafiktext
    xtxt <- datalist$cw + 1
    ytxt <- filter(datalist$data, kanton==!!kanton, year==datalist$year, cw==datalist$cw) 
    ytxt <- unlist(ytxt$value)
    
    
    # return lineplot
    datalist$data %>%
      filter(kanton==!!kanton, cw<53, year>'2009') %>%
      mutate(highlight=year!=datalist$year) %>%
      mutate(yeage = paste(year,age)) %>%
      
      ggplot(aes(x=cw, y=value, group=yeage, color=highlight, size=highlight)) +
      geom_line() +
      scale_color_manual(values = c("#69b3a3", "lightgrey")) +
      scale_size_manual(values=c(1.5,0.2)) +
      scale_x_continuous(limits = c(1, 52)) +
      theme_minimal() +
      ggtitle(my_titel) +
      ylab(NULL) +
      xlab('Kalenderwoche') +
      geom_label(x=xtxt, y=ytxt[3], label='Altersgruppe 80 Jahre und älter', size=2, color='#69b3a3', fill='white', hjust = 0) +
      geom_label(x=xtxt, y=ytxt[2], label='Altersgruppe 65 -79 Jahre', size=2, color='#69b3a3', fill='white', hjust = 0) +
      geom_label(x=xtxt, y=ytxt[1], label='Altersgruppe 0 - 64 Jahre', size=2, color='#69b3a3', fill='white', hjust = 0) +
      theme(
        legend.position="none",
        plot.title = element_text(size=14)
      ) 
  
  
}  

plotbar <- function(datalist, kanton) {
  
  ##############
  # Funktion für bar-plot nach Region

    # Grafiktitel
    my_titel <- sprintf('Region %s',datalist$regions$kanton2[datalist$regions$kanton==kanton])
  
    # return barplot
    dfbar <- datalist$data %>% 
      filter(kanton==!!kanton) %>%
      filter(cw <= datalist$cw) %>%
      group_by(year, age) %>%
      summarise(N=sum(value)) %>%
      ungroup() %>%
      mutate(highlight=(!year %in% c('2015',datalist$year)))  %>%
      mutate(year = as.integer(year))
      
    # Koordinaten für Grafiktext
    ycord <- group_by(dfbar, age) %>% summarise(y=max(N))
    ycord <- unlist(ycord$y)*1.2
    ycord[3] <- ycord[3]/2
    labtxt <- data.frame(year=2010, N=ycord, age=c("0-64", "65-79", "80+"), 
          label=c("Altersgruppe 0 - 64 Jahre",
                  "Altersgruppe 65 -79 Jahre",
                  "Altersgruppe 80 Jahre und älter"))
 
    ggplot(dfbar, aes(x=year, y=N, fill=highlight)) +
      geom_bar(stat = "identity", width = 1) +
      geom_smooth(method = lm, se = T, fill='lightblue') +
      scale_fill_manual(values = c("#69b3a3", "lightgrey")) +
      theme_minimal() +
      ggtitle(my_titel) +
      ylab(NULL) +
      xlab('Jahr') +
      theme(
        legend.position="none",
        plot.title = element_text(size=14),
        axis.text.x = element_text(angle=45),      ) +
      facet_wrap(age ~ .) +
      theme(strip.background = element_blank(), strip.text = element_blank()) +
      geom_label(data = labtxt, label=labtxt$label, size=2, color='#69b3a3', fill='white') 
}
  
  
# load list of data
ld <- fundeath(datapath)

# tabel of hightest case numbers
ld$data %>%
  filter(year=='2020', geo!='CH', cw %in% 11:15) %>%
  group_by(kanton2) %>%
  summarise(N=sum(value)) %>% 
  arrange(desc(N)) %>%
  top_n(12) %>%
  knitr::kable()


# charts
plotline(ld,'CH')
plotbar(ld,'CH')


# save the images
create_imgages <- function(regions) {
  
  imgpath <- file.path(imagepath,format(Sys.time(),'%Y%m%d_%H%M%S'))
  dir.create(imgpath)
  lapply(regions, function(x) {
    message(sprintf('... printing lines %s',x))
    fnam <- sprintf('figline%s_%%03d.png',x)
    file <- file.path(imgpath,fnam)
    ggsave(filename = file, 
           plotline(ld,x),
           #plotline(ld,x) + theme_bw(base_size = 10),
           width = 5, height = 4, dpi = 150, units = "in", device='png')
  })
  lapply(regions, function(x) {
    message(sprintf('... printing bars %s',x))
    fnam <- sprintf('figbar%s_%%03d.png',x)
    file <- file.path(imgpath,fnam)
    ggsave(filename = file, 
           plotbar(ld,x),
           #plotbar(ld,x) + theme_bw(base_size = 10),
           width = 5, height = 4, dpi = 150, units = "in", device='png')
  })
  
  return(NULL)
}

create_imgages(ld$regions$kanton)
