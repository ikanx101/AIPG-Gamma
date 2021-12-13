rm(list=ls())

library(dplyr)
library(ggplot2)
library(rvest)
library(stringr)
library(tidyr)

path = "~/AIPG-Gamma/2nd Iteration/neliti/txt/"
nama_file = list.files(path)
nama_file = paste0(path,nama_file)

scrape_donk = function(url){
  url %>% read_html() %>% {tibble(
    judul = html_nodes(.,".content-title") %>% html_text() %>% str_squish(),
    author = html_nodes(.,".search-result-authors") %>% html_text() %>% str_squish(),
    link_situs = url
  )}
}

for(k in 1:length(nama_file)){
  link = readLines(nama_file[k])
  
  hasil = vector("list",length(link))
  
  batas = 5
  
  for (i in 1:length(link)) {
    if (!(link[i] %in% names(hasil))) {
      cat(paste("Scraping", link[i], "..."))
      ok = FALSE
      counter = 0
      while (ok == FALSE & counter <= batas) {
        counter = counter + 1
        out = tryCatch({                  
          scrape_donk(link[i])
        },
        error = function(e) {
          Sys.sleep(0.5)
          e
        }
        )
        if ("error" %in% class(out)) {
          cat(".")
        } else {
          ok = TRUE
          cat(" Done.")
        }
      }
      cat("\n")
      hasil[[i]] = out
      names(hasil)[i] = link[i]
    }
  } 
  
  nama_rda = gsub(".txt","",nama_file[k])
  nama_rda = gsub("~/AIPG-Gamma/2nd Iteration/neliti/","",nama_rda)
  save(hasil,file = paste0(nama_rda,".rda"))
  print("DONE")
}




