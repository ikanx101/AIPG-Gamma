library(dplyr)
library(tidyr)
library(stringr)

rm(list=ls())
setwd("~/AIPG-Gamma/Pilot/sinta")

load("sinta.rda")

bersih = function(kalimat){
  for(i in 1:15){
    kalimat = gsub("  "," ",kalimat)
  }
  return(kalimat)
}

data_sinta_clean = 
  data_sinta %>% 
  janitor::clean_names() %>% 
  rowwise() %>% 
  mutate(publications = bersih(publications)) %>% 
  ungroup() %>% 
  separate(publications,
           into = c("judul","author","jurnal"),
           sep = "\n \n") %>% 
  mutate(judul = str_squish(judul),
         author = str_squish(author),
         jurnal = str_squish(jurnal))

save(data_sinta_clean,data_sinta,file = "sinta.rda")