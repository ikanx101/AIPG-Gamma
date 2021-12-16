rm(list=ls())
library(openxlsx)
file = list.files()

for(ix in file){
  load(ix)
  is_df = sapply(hasil, is.data.frame)
  temp = bind_rows(hasil[is_df])
  write.xlsx(temp,file = paste0(gsub(".rda","",ix),".xlsx"))
  print(ix)
}