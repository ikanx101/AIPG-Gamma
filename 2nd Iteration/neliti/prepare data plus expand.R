rm(list=ls())

start = Sys.time()

library(dplyr)
library(tidytext)
library(tidyr)
library(NLP)
library(tm)
library(topicmodels)

options(warn = -1)

# ==============================
# ambil stopwords dulu
sensor1 = readLines("https://raw.githubusercontent.com/ikanx101/ID-Stopwords/master/id.stopwords.02.01.2016.txt")
sensor2 = stopwords::stopwords("en")
sensor = c(sensor1,sensor2,"0,075mm","0","0,180mm","0,1n","0,3","l")

# ==============================
# ambil path original
path_rda = "~/AIPG-Gamma/2nd Iteration/neliti/rda/"
rda_s = list.files(path_rda)
rda_s = paste0(path_rda,rda_s)
n_rda = length(rda_s)

rekap_all = data.frame()
z = 1

# gabung semua data
for(i in 1:n_rda){
  print(paste0("Ambil data: ",rda_s[i]))
  load(rda_s[i])
  for(k in 1:length(hasil)){
    print(paste0("Processing ke ",z))
    z = z + 1
    temp = hasil[[k]]
    temp$keyword = rda_s[i]
    if(is.data.frame(temp)){rekap_all = rbind(rekap_all,temp)}
  }
}

# rapihin dulu
rekap_all = 
  rekap_all %>% 
  mutate(keyword = gsub(path_rda,"",keyword),
         keyword = gsub(".rda","",keyword)) %>% 
  distinct() %>% 
  filter(!is.na(judul))

# kita rapihin dulu
rekap_awal = 
  rekap_all %>% 
  mutate(judul = tolower(judul),
         author = tolower(author)) %>%
  group_by(judul,author) %>%
  summarise(keyword = paste(keyword,collapse = ",")) %>%
  ungroup() %>% 
  distinct()

rekap_awal$id = 1:nrow(rekap_awal)

# bikin wc dari judul awal
judul_wc = 
  rekap_awal %>%
  select(id,judul) %>%
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>%
  count(words,sort = T)

judul_awal = judul_wc

# ==============================
# ambil path tambahan
path_rda_expand = "~/AIPG-Gamma/2nd Iteration/neliti/rda expand/"
rda_s = list.files(path_rda_expand)
rda_s = paste0(path_rda_expand,rda_s)
n_rda = length(rda_s)

rekap_all = data.frame()
z = 1

# gabung semua data
for(i in 1:n_rda){
  print(paste0("Ambil data: ",rda_s[i]))
  load(rda_s[i])
  for(k in 1:length(hasil)){
    print(paste0("Processing ke ",z))
    z = z + 1
    temp = hasil[[k]]
    temp$keyword = rda_s[i]
    if(is.data.frame(temp)){rekap_all = rbind(rekap_all,temp)}
  }
}

# rapihin dulu
rekap_all = 
  rekap_all %>% 
  mutate(keyword = gsub(path_rda_expand,"",keyword),
         keyword = gsub(".txt.rda","",keyword)) %>% 
  distinct() %>% 
  filter(!is.na(judul))

# kita rapihin dulu
rekap_expand = 
  rekap_all %>% 
  mutate(judul = tolower(judul),
         author = tolower(author)) %>%
  group_by(judul,author) %>%
  summarise(keyword = paste(keyword,collapse = ",")) %>%
  ungroup() %>% 
  distinct() %>% 
  filter(!grepl("tidak ada",judul,ignore.case = T))

rekap_expand$id = 1:nrow(rekap_expand)

# bikin wc dari judul awal
judul_wc = 
  rekap_expand %>%
  select(id,judul) %>%
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>%
  count(words,sort = T)

judul_expand = judul_wc

# gabung data rekap
rekap_all_data = 
  rbind(rekap_awal,rekap_expand) %>% 
  group_by(judul,author) %>%
  summarise(keyword = paste(keyword,collapse = ",")) %>%
  ungroup() %>% 
  distinct() %>% 
  filter(!grepl("tidak ada",judul,ignore.case = T))
rekap_all_data$id = 1:nrow(rekap_all_data)

judul_wc_all = 
  rbind(judul_awal,judul_expand) %>% 
  group_by(words) %>% 
  summarise(n = sum(n)) %>% 
  ungroup()

# persiapan bigrams
ready_bigram = 
  rekap_all_data %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>% 
  group_by(id) %>% 
  summarise(judul = paste(words,collapse = " ")) %>% 
  distinct() %>% 
  unnest_tokens(bigram,judul,token='ngrams',n=2) %>% 
  count(bigram,sort=T) %>% 
  filter(!is.na(bigram))

# ===========================================================
# analisa ikan
rekap_ikan = 
  rekap_all_data %>% 
  filter(grepl("ikan",keyword,ignore.case = T))

# bikin wc dari judul ikan
judul_ikan = 
  rekap_ikan %>%
  select(id,judul) %>%
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>%
  count(words,sort = T)

# persiapan bigrams
ready_bigram_ikan = 
  rekap_ikan %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>% 
  group_by(id) %>% 
  summarise(judul = paste(words,collapse = " ")) %>% 
  distinct() %>% 
  unnest_tokens(bigram,judul,token='ngrams',n=2) %>% 
  count(bigram,sort=T) %>% 
  filter(!is.na(bigram))

# persiapan bigrams
ready_bigram_non_ikan = 
  rekap_all_data %>% 
  filter(!grepl("ikan",keyword,ignore.case = T)) %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% sensor) %>% 
  group_by(id) %>% 
  summarise(judul = paste(words,collapse = " ")) %>% 
  distinct() %>% 
  unnest_tokens(bigram,judul,token='ngrams',n=2) %>% 
  count(bigram,sort=T) %>% 
  filter(!is.na(bigram))

# =======================================
# topic modelling
# tanpa ikan
for_tm = 
  rekap_all_data %>% 
  filter(!grepl("ikan",keyword)) %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% c(sensor,"l","pengaruh","analisis","kecamatan","kabupaten","kota","faktor","studi","sistem",
                       "makanan")) %>% 
  rename(doc_id = id,
         lemma = words) %>% 
  mutate(penanda = ifelse(as.numeric(lemma),1,0)) %>% 
  filter(is.na(penanda)) %>% 
  select(-penanda) %>% 
  rowwise() %>% 
  mutate(penanda = stringr::str_length(lemma)) %>% 
  ungroup() %>% 
  filter(penanda > 2) %>% 
  select(-penanda) %>% 
  group_by(doc_id) %>% 
  summarise(judul = paste(lemma,collapse = " ")) %>% 
  ungroup()


NAME = Corpus(VectorSource(for_tm$judul))
tdm = TermDocumentMatrix(NAME)

dtm = as.DocumentTermMatrix(tdm) 
rowTotals = apply(dtm , 1, sum) 
dtm = dtm[rowTotals> 0, ]           
lda = LDA(dtm, k = 6)  

# =======================================
# topic modelling
# hanya ikan
for_tm = 
  rekap_all_data %>% 
  filter(grepl("ikan",keyword)) %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% c(sensor,"l","pengaruh","analisis","kecamatan","kabupaten","kota","faktor","studi","sistem",
                       "makanan","ikan")) %>% 
  rename(doc_id = id,
         lemma = words) %>% 
  mutate(penanda = ifelse(as.numeric(lemma),1,0)) %>% 
  filter(is.na(penanda)) %>% 
  select(-penanda) %>% 
  rowwise() %>% 
  mutate(penanda = stringr::str_length(lemma)) %>% 
  ungroup() %>% 
  filter(penanda > 2) %>% 
  select(-penanda) %>% 
  group_by(doc_id) %>% 
  summarise(judul = paste(lemma,collapse = " ")) %>% 
  ungroup()


NAME = Corpus(VectorSource(for_tm$judul))
tdm = TermDocumentMatrix(NAME)

dtm = as.DocumentTermMatrix(tdm) 
rowTotals = apply(dtm , 1, sum) 
dtm = dtm[rowTotals> 0, ]           
lda_ikan = LDA(dtm, k = 6)  


# =======================================
# topic modelling
# tanpa ikan,buah,tepung,protein
for_tm = 
  rekap_all_data %>% 
  filter(!grepl("ikan|buah|tepung|protein",keyword)) %>% 
  select(id,judul) %>% 
  unnest_tokens('words',judul) %>%
  filter(!words %in% c(sensor,"l","pengaruh","analisis","kecamatan","kabupaten","kota","faktor","studi","sistem",
                       "makanan")) %>% 
  rename(doc_id = id,
         lemma = words) %>% 
  mutate(penanda = ifelse(as.numeric(lemma),1,0)) %>% 
  filter(is.na(penanda)) %>% 
  select(-penanda) %>% 
  rowwise() %>% 
  mutate(penanda = stringr::str_length(lemma)) %>% 
  ungroup() %>% 
  filter(penanda > 2) %>% 
  select(-penanda) %>% 
  group_by(doc_id) %>% 
  summarise(judul = paste(lemma,collapse = " ")) %>% 
  ungroup()


NAME = Corpus(VectorSource(for_tm$judul))
tdm = TermDocumentMatrix(NAME)

dtm = as.DocumentTermMatrix(tdm) 
rowTotals = apply(dtm , 1, sum) 
dtm = dtm[rowTotals> 0, ]           
lda_umum = LDA(dtm, k = 6)  

# ngesave dulu
save(rekap_awal,judul_awal,rekap_expand,judul_expand,
     rekap_all_data,judul_wc_all,
     ready_bigram,lda,lda_ikan,lda_umum,
     judul_ikan,ready_bigram_ikan,
     ready_bigram_non_ikan,
     file = "~/AIPG-Gamma/2nd Iteration/judul_all.rda")

waktu = Sys.time() - start
waktu = waktu %>% round(5)
print(paste0("Waktu processing: ",waktu))
print("==done all==")
