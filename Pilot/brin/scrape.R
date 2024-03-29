rm(list=ls())

setwd("~/AIPG-Gamma/Pilot/brin")

library(dplyr)
library(rvest)
library(stringr)

url = paste0("https://www.brin.go.id/page/",1:8,"/?s=bioteknologi")
link = c()
for(i in 1:length(url)){
  temp = 
    url[i] %>% 
    read_html() %>% 
    html_nodes(".hentry a") %>% 
    html_attr("href")
  link = c(link,temp)
  print(i)
}

# ============================
link = link[!grepl("/open-",link)]

scrape_brin = function(url){
  data = 
    url %>% 
    read_html() %>% 
    {tibble(
      judul = html_nodes(.,".single-title") %>% html_text() %>% str_squish(),
      tanggal = html_nodes(.,".date") %>% html_text() %>% str_squish(),
      isi = html_nodes(.,".post-content") %>% html_text() %>% str_squish()
    )}
  return(data)
}

artikel = vector("list",length(link))

for(i in 1:length(link)){
  artikel[[i]] = scrape_brin(link[i])
  print(i)
}

artikel_final = do.call(rbind,artikel)

save(link,artikel_final,file = "brin.rda")