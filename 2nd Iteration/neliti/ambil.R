rm(list=ls())

library(rvest)
library(dplyr)

url = paste0("https://www.neliti.com/id/search?q=pangan%20lokal&page=",1:11)

n_url = length(url)
links = c()

for(i in 1:n_url){
  temp = 
    url[i] %>% 
    read_html() %>%
    html_nodes(".sr-title") %>%
    html_attr("href")
  links = c(temp,links)
  print(i)
}

links %>% writeLines("pangan lokal.txt")
print("DONE")
