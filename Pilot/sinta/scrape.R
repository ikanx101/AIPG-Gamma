rm(list=ls())

library(dplyr)
library(rvest)

url_1 = paste0("https://sinta.ristekbrin.go.id/journals/detail?page=",1:14,"&id=1013")
url_2 = paste0("https://sinta.ristekbrin.go.id/journals/detail?page=",1:31,"&id=2764")
url = c(url_1,url_2)

hasil = vector("list",length(url))

for(i in 1:length(url)){
  temp = 
    url[i] %>% 
    read_html() %>% 
    html_nodes(".paper-link") %>% 
    html_attr("href")
  data = 
    url[i] %>% 
    read_html() %>% 
    html_table(fill=T)
  data = data[[2]]
  data$links = temp
  hasil[[i]] = data
  print(i)
}

data_final = do.call(rbind,hasil)

data_sinta = data_final

save(data_sinta,file = "sinta.rda")