rm(list=ls())

library(rvest)
library(dplyr)

url = paste0("https://www.neliti.com/id/search?q=tepung&page=",1:59)
# url = "https://www.neliti.com/id/search?q=makanan+etnik"

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

links %>% writeLines("tepung.txt")
print("DONE")
