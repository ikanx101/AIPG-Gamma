# setwd("~/Documents/AIPG-Gamma/4th Iteration")
setwd("E:/DATA SCIENCE/Komite Gamma/4th Iteration")

# bebersih
rm(list=ls())

# libraries
library(dplyr)
library(rvest)
library(tidyr)
library(tidytext)

# keywords
keywords = c("kearifan lokal", 
             "pangan tradisional", 
             "lingkungan", 
             "bioteknologi", 
             "nutrigenomik", 
             "pangan fungsional")
keywords = gsub(" ","%20",keywords)

# kita buat semua url yang mungkin
urls = c()
for(i in 1:length(keywords)){
  # kita buat dulu link pencarian dari situs neliti
  url_temp = paste0("https://www.neliti.com/id/search?q=",
                    keywords[i],
                    "&per_page=100&page=")
  url_temp = paste0(url_temp,1:20)
  urls = c(url_temp,urls)
}

# sekarang kita proses scraping semua links yang mungkin
all_links = c()
for(i in 1:length(urls)){
  # set url looping
  temp = urls[i]
  # scraping
  url_dapet = 
    temp %>% 
    read_html() %>% 
    html_nodes("a") %>% 
    html_attr("href")
  # gabung ke data awal
  all_links = c(url_dapet,all_links)
  # istirahat dulu
  Sys.sleep(1)
  print(i)
}

# dari sini akan kita pecah dua
link_publikasi = all_links[grepl("id/publication",all_links,ignore.case = T)]
link_pdf = all_links[grepl(".pdf",all_links,ignore.case = T)]


save(all_links,
     link_publikasi,
     link_pdf,
     file = "semua link.rda")