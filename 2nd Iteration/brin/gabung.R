rm(list=ls())

library(dplyr)

file_rda = list.files(pattern = "rda")

data_gabung = data.frame()

for(i in 1:length(file_rda)){
  load(file_rda[i])
  temp = artikel_final
  temp$source = file_rda[i]
  data_gabung = rbind(temp,data_gabung)
}

data_gabung = data_gabung %>% distinct()

save(data_gabung,file = "gabungan.rda")
