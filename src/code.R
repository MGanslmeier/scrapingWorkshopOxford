# load libraries via pacman
pacman::p_load(plyr, dplyr, rvest, stringr, tidyr, RSelenium, lubridate)
rm(list = ls())

###########################
###########################

# NATLEX
baseURL <- 'http://www.ilo.org/dyn/natlex/'
url <- 'http://www.ilo.org/dyn/natlex/natlex4.bySubject?p_lang=en&p_order=ALPHABETIC'

# get the links to the domains
domain_links <- url %>%
  read_html(.) %>% 
  html_nodes('#colMain > div.featureMultiple.FM2 > ol > li > a') %>% 
  html_attr('href') %>% 
  paste(baseURL, ., sep = '') %>%
  paste(., '&p_pagelength=20000000', sep = '')

# get links to all entries
entryLinks <- c()
for(i in 1:length(domain_links)){
  entryLinks <- domain_links[i] %>%
    read_html(.) %>% 
    html_nodes('.lawsList li .titleList a') %>% 
    html_attr('href') %>%
    paste(baseURL, ., sep = '') %>%
    c(entryLinks, .)
}

# extract information from entry pages
natlex_final <- data.frame(stringsAsFactors = F)
for(i in 1:length(entryLinks)){
  
  # extract information from Natlex entry
  tryCatch({
    temp <- entryLinks[i] %>%
      read_html() %>% 
      html_nodes('.page') %>% 
      html_table() %>% 
      as.data.frame(.) %>%
      spread(., X1, X2) %>%
      mutate(url = entryLinks[i])
    
    # add entry to final dataframe
    natlex_final <- bind_rows(natlex_final, temp)
  }, error = function(e){})
}
