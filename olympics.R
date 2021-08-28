# The olypics: With a focuss on athletics
pacman::p_load(dplyr, reticulate, ggplot2)

# Scraope Tokyo 2020 data using Python
use_python("/usr/local/bin/python")
source_python('tokyo_2020.py')

# Data
olympics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-27/olympics.csv') %>% 
  filter(sport == "Athletics" & medal != "") %>% 
  group_by(team, games) %>% 
  mutate(total = n()) %>% 
  filter(!duplicated(total)) %>% 
  ungroup() %>% 
  select(team, total, year) %>% 
  bind_rows(tokyo_2020) 

p <- ggplot(olympics %>% filter(year > 1960), aes(x = year, y = total,  group = team)) + geom_line() +
  theme_bw()

