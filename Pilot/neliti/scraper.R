rm(list=ls())

setwd("~/AIPG-Gamma/Pilot/neliti")

library(dplyr)
library(ggplot2)
library(rvest)
library(stringr)
library(tidyr)

links = readLines("links.txt")

url = links[1]

scrape_neliti = function(url){
  url %>% read_html() %>% {tibble(
    judul = html_nodes(.,".content-title") %>% html_text() %>% str_squish(),
    author = html_nodes(.,".search-result-authors") %>% html_text() %>% str_squish(),
    meta = html_nodes(.,".search-result-authors+ .pub-meta-item") %>% html_text() %>% str_squish(),
    abstrak = html_nodes(.,".abstract") %>% html_text() %>% str_squish(),
    link_situs = url
  )}
}

data_neliti = data.frame()

for(i in 1:length(links)){
  temp = scrape_neliti(links[i])
  data_neliti = rbind(temp,data_neliti)
  rand = sample(1:10,1)
  Sys.sleep(rand)
  print(paste0("Situs ke-",i," selesai diambil..."))
}

save(data_neliti,file = "neliti.rda")
