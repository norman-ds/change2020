FROM rocker/verse:3.6.2
LABEL maintainer="Norman Bieri <normanbieri@puntaminar.ch>"


# Install R packages
## Blogdown
## RUN apt-get update && apt-get -y install pandoc pandoc-citeproc
RUN R -e "install.packages('blogdown', repos='https://cran.rstudio.com/')"
## RUN R -e "blogdown::install_hugo(version = '0.44')"
