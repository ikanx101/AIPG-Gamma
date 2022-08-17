rm(list=ls())

library(rvest)
library(dplyr)

load("semua link.rda")

# function scraper paper
ambilin = function(tes){
  df = 
    tes %>% 
    read_html() %>% {tibble(
      judul = html_nodes(.,".content-title") %>% html_text(trim = T),
      penulis = html_nodes(.,".search-result-authors") %>% html_text(trim = T),
      tahun = html_nodes(.,".search-result-authors+ .pub-meta-item") %>% html_text(trim = T)
    )}
  df$link = tes
  return(df)
}

output = vector("list",length(link_publikasi))

for(i in 1:length(link_publikasi)){
  output[[i]] = ambilin(link_publikasi[i])
  print(i)
  time = runif(1,1,5)
  Sys.sleep(time)
}

save(output,file = "paper.rda")