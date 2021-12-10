rm(list=ls())

start = Sys.time()

library(dplyr)
library(tidytext)
library(tidyr)

options(warn = -1)

# ==============================
# ambil stopwords dulu
stop_id = readLines("https://raw.githubusercontent.com/ikanx101/ID-Stopwords/master/id.stopwords.02.01.2016.txt")

# ==============================
# ambil path
path_rda = "~/AIPG-Gamma/2nd Iteration/neliti/rda"
rda_s = list.files(path_rda)
rda_s = paste0(path_rda,"/",rda_s)
n_rda = length(rda_s)

rekap_all = data.frame()

for(i in 1:n_rda){
  print(paste0("Ambil data: ",rda_s[i]))
  load(rda_s[i])
  for(k in 1:length(hasil)){
    print(paste0("Processing ke ",k))
    temp = hasil[[k]]
    if(is.data.frame(temp)){rekap_all = rbind(rekap_all,temp)}
  }
}


waktu = Sys.time() - start
waktu = waktu %>% round(5)
print(paste0("Waktu processing: ",waktu))
print("==done==")
