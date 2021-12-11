rm(list=ls())

library(dplyr)
library(ggplot2)
library(rvest)
library(stringr)
library(tidyr)

nama_file = "functional food.txt"
link = readLines(nama_file)

scrape_donk = function(url){
  url %>% read_html() %>% {tibble(
    judul = html_nodes(.,".content-title") %>% html_text() %>% str_squish(),
    author = html_nodes(.,".search-result-authors") %>% html_text() %>% str_squish(),
    link_situs = url
  )}
}

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

nama_file = gsub(".txt","",nama_file)
save(hasil,file = paste0(nama_file,".rda"))
print("DONE")
