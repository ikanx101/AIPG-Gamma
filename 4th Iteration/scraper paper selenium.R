# setwd("~/Komite Gamma/4th Iteration")

rm(list=ls())

# ==============================================================================
# panggil libraries
library(RSelenium)  # web scraping
library(rvest)      # web scraping
library(dplyr)      # buat data manipulation

# ==============================================================================
# version chrome
version = "103.0.5060.53"

load("semua link.rda")

# ==============================================================================
# memulai Selenium
# saat baris perintah ini dijalankan, akan muncul window chrome baru di desktop
driver = RSelenium::rsDriver(browser = "chrome",
                             chromever = version )
remote_driver = driver[["client"]]

# buka situs
buka_in = function(url){
  remote_driver$navigate(url)
  Sys.sleep(4)
}


# function scraper paper
ambilin = function(tes){
  # buka situsnya
  buka_in(tes)
  
  # baca situsnya dulu
  baca = 
    remote_driver$getPageSource()[[1]] %>% 
    read_html() 
  # ambil element
  judul = baca %>% html_nodes(".content-title") %>% html_text(trim = T)
  penulis = baca %>% html_nodes(".search-result-authors") %>% html_text(trim = T)
  tahun = baca %>% html_nodes(".search-result-authors+ .pub-meta-item") %>% html_text(trim = T)
  # jika element tiada, maka dibuat NA
  judul = ifelse(identical(judul, character(0)),
                 NA,
                 judul)
  penulis = ifelse(identical(penulis, character(0)),
                   NA,
                   penulis)
  tahun = ifelse(identical(tahun, character(0)),
                 NA,
                 tahun)
  
  df = data.frame(judul,tahun,penulis)
  # save linknya
  df$link = tes
  return(df)
}

# siapin dulu rumahnya
output = vector("list",length(link_publikasi))

for(i in 2499:length(link_publikasi)){
  output[[i]] = ambilin(link_publikasi[i])
  print(i)
}

save(output,file = "raw 3.rda")
