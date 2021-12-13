rm(list=ls())

start = Sys.time()

library(dplyr)
library(tidytext)
library(tidyr)

options(warn = -1)

# ==============================
# ambil stopwords dulu
sensor1 = readLines("https://raw.githubusercontent.com/ikanx101/ID-Stopwords/master/id.stopwords.02.01.2016.txt")
sensor2 = stopwords::stopwords("en")
sensor = c(sensor1,sensor2)

# ==============================
# ambil path
path_rda = "~/AIPG-Gamma/2nd Iteration/neliti/rda/"
rda_s = list.files(path_rda)
rda_s = paste0(path_rda,rda_s)
n_rda = length(rda_s)

rekap_all = data.frame()
z = 1

# gabung semua data
for(i in 1:n_rda){
  print(paste0("Ambil data: ",rda_s[i]))
  load(rda_s[i])
  for(k in 1:length(hasil)){
    print(paste0("Processing ke ",z))
    z = z + 1
    temp = hasil[[k]]
    temp$keyword = rda_s[i]
    if(is.data.frame(temp)){rekap_all = rbind(rekap_all,temp)}
  }
}

# kita rapihin dulu
rekap_all = 
  rekap_all %>%
  distinct() %>%
  filter(!is.na(judul)) %>%
  mutate(judul = tolower(judul),
         author = tolower(author)) %>%
  group_by(judul,author) %>%
  summarise(keyword = paste(keyword,collapse = ",")) %>%
  ungroup()

rekap_all$id = 1:nrow(rekap_all)

# bikin wc dari judul
judul_wc = 
  rekap_all %>%
  select(id,judul) %>%
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>%
  count(words,sort = T)

judul_wc %>% head(15) %>% print()

judul_all = judul_wc

# ngesave dulu
save(rekap_all,judul_all,file = "judul_all.rda")

waktu = Sys.time() - start
waktu = waktu %>% round(5)
print(paste0("Waktu processing: ",waktu))
print("==done all==")
