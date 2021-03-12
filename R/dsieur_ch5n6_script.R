`# using the filter() function from the stats package  
x <- 1:100  

stats::filter(x, rep(1, 3))  

`# using the filter() function from the dplyr package  
starwars %>%   
  dplyr::filter(mass > 85)

dataedu::ma_data_init

dataedu::ma_data_init -> ma_data

ma_data_init <- dataedu::ma_data_init

# you probably wrote these 3 library() lines in your R script file earlier
# if you have not yet run them, you will need to run these three lines before running the rest of the chunk
library(tidyverse)
library(dataedu)
library(skimr)
library(janitor)

# Exploring and manipulating your data
names(ma_data_init)

glimpse(ma_dat_init) 

glimpse(ma_data_init)

summary(ma_data_init)

glimpse(ma_data_init$Town)

summary(ma_data_init$Town)

glimpse(ma_data_init$AP_Test Takers)

glimpse(ma_data_init$`AP_Test Takers`)

summary(ma_data_init$`AP_Test Takers`)


ma_data_init %>% 
  group_by(District Name) %>%  
  count()

ma_data_init %>% 
  group_by(`District Name`) %>% 
  count()  

ma_data_init %>% 
  group_by(`District Name`) %>% 
  count() %>% 
  filter(n > 10)

ma_data_init %>% 
  group_by(`District Name`) %>% 
  count() %>% 
  filter(n > 10) %>% 
  arrange()
