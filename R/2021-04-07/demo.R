##################################################
# R Script to go with DSiEUR Ch.11
# Layla Bouzoubaa
# April 7, 2021
###-----------------------------------------------

### Loading data -------
library(tidyverse)
library(here)
library(dataedu)
library(tidytext)

# from dataedu pacakge
raw_tweets <- dataedu::tt_tweets

glimpse(raw_tweets)

# from rtweet package

library(rtweet)
#limited to the last 7 days on the free tier
tt <- search_tweets("#TidyTuesday", n = 10000, include_rts = FALSE)

### Process Data ------------

tweets <-
  raw_tweets %>%
  #filter for English tweets
  filter(lang == "en") %>%
  select(status_id, text) %>%
  # Convert the ID field to the character data type
  mutate(status_id = as.character(status_id))

# tokenize data
tokens <- 
  tweets %>%
  unnest_tokens(output = word, input = text)

# remove stop words

data(stop_words)

tokens <-
  tokens %>%
  anti_join(stop_words, by = "word")

### Count frequent words ----------------

tokens %>% 
  count(word, sort = TRUE) %>% 
  # calculate the cumulative percentage
  mutate(percent = n / sum(n) * 100)


### Sentiment Analysis ----------
library(textdata)

nrc_pos <-
  get_sentiments("nrc") %>%
  filter(sentiment == "positive")

# Match to tokens
pos_tokens_count <-
  tokens %>%
  inner_join(nrc_pos, by = "word") %>%
  # Total appearance of positive words
  count(word, sort = TRUE) 

# visualize the frequency or positive words that appear more than 75 times
pos_tokens_count %>%
  # only words that appear 75 times or more
  filter(n >= 75) %>%
  ggplot(., aes(x = reorder(word, -n), y = n)) +
  geom_bar(stat = "identity", fill = dataedu_colors("darkblue")) +
  labs(
    title = "Count of Words Associated with Positivity",
    subtitle = "Tweets with the hashtag #tidytuesday",
    caption = "Data: Twitter and NRC",
    x = "",
    y = "Count"
  ) +
  theme_dataedu()

# get the status_ids of tweets that contain the word "dataviz"
dv_tokens <-
  tokens %>%
  filter(word == "dataviz") %>% 
  # there are several duplicate status ids
  distinct(status_id)

# get the status_ids of tweets that contain a positive word
pos_tokens <- 
  tokens %>%
  filter(word %in% nrc_pos$word) %>% 
  # there are several duplicate status ids
  distinct(status_id)

# finally, filter our tweet data for those tweets that contain dataviz
# and see if that id also contained a positive word

dv_pos <-
  tweets %>%
  # Only tweets that have the dataviz status_id
  filter(status_id %in% dv_tokens$status_id) %>%
  # Is the status_id from our vector of positive word?
  mutate(positive = if_else(status_id %in% pos_tokens$status_id, 1, 0))

# get proportion of tweets that contained a dataviz and a positive word
dv_pos %>%
  count(positive) %>%
  mutate(perc = n / sum(n))

### Zooming out ----------

# to get a random sample of tweets
pos_tweets <-
  tweets %>%
  mutate(positive = if_else(status_id %in% pos_tokens$status_id, 1, 0)) %>%
  filter(positive == 1)

set.seed(123)

View(pos_tweets %>% 
  sample_n(., size = 10))
