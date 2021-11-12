rm(list=ls())

setwd("~/AIPG-Gamma/Pilot")
library(dplyr)

load("~/AIPG-Gamma/Pilot/neliti/neliti.rda")
load("~/AIPG-Gamma/Pilot/sinta/sinta.rda")
load("~/AIPG-Gamma/Pilot/brin/brin.rda")

artikel_final$tanggal = gsub("ON ","",artikel_final$tanggal)

artikel_final = 
  artikel_final %>% 
  mutate(tanggal = gsub("ON ","",tanggal),
         pelatihan = ifelse(grepl("pelatihan",isi,ignore.case = T),
                            "x",NA),
         training = ifelse(grepl("training",isi,ignore.case = T),
                            "x",NA),
         pendidikan = ifelse(grepl("pendidikan",isi,ignore.case = T),
                            "x",NA)
  )

library(openxlsx)
library(expss)

wb = createWorkbook()
sh = addWorksheet(wb, "neliti")
xl_write(data_neliti, wb, sh)
sh = addWorksheet(wb, "SINTA")
xl_write(data_sinta_clean, wb, sh)
sh = addWorksheet(wb, "BRIN")
xl_write(artikel_final, wb, sh)
saveWorkbook(wb, "hasil web scrape.xlsx", overwrite = TRUE)