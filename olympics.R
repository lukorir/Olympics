# The olympics: With a focuss on summer olympics between 1960-2020
# Author Luke Korir
# Date: September 2021

# Load packages _  _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ 
pacman::p_load(dplyr, reticulate, ggplot2, tidyr, ggh4x, scales, gridExtra)
options(scipen=999)

# Load python script to webscrape Tokyo 2020 data _  _ _ _ _ _ _ _ _  _ _ _ _
use_python("/usr/local/bin/python")
source_python('tokyo_2020.py')

# Clear unnecessary variables 
rm(list = setdiff(ls(), "tokyo_2020"))

# Load data from Kaggle  
olympics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-27/olympics.csv') %>%
  filter(season == "Summer") %>%
  select(name, team, sport, year)

# Process data and merge the 2 datasets _  _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _  _  
tokyo_2020 <- tokyo_2020 %>% select(name, team, sport, year) %>%
  separate(team, c("team", "team_b"), sep = "([;])") %>% 
  separate(sport, c("sport", "sport_b"), sep = "([;])") %>% 
  select(-contains("_b")) %>% 
  mutate(name = as.character(name)) %>% 
  bind_rows(olympics) %>%
  mutate(team = case_when(team == "United States-1" | team == "United States-2" | team == "United States-3" ~ "United States",
                          TRUE ~ team)) 

# Function to create basic bar plot  
plot_bar_char <- function(df, var1){
  df %>% filter(year >= 1960) %>%
    group_by({{ var1 }}, year) %>% 
    filter(!duplicated({{ var1 }})) %>% 
    count(year) %>% 
    ggplot(aes(y = n, x = year)) +
    theme_bw() +
    theme(panel.border = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.minor.y=element_blank(),
          panel.grid.minor.x=element_blank(),
          panel.grid.major.x=element_blank(),
          panel.grid.major = element_line(colour = "grey80", size = 1),
          axis.text = element_text(size = 12),
          plot.title = element_text(size = 16),
          plot.subtitle = element_text(size = 12, face = "bold"),
          plot.caption = element_text(hjust = 0), 
          plot.title.position = "plot",
          plot.caption.position =  "plot") 
  } 

# Bar plot of teams competing 
countries_competing <-tokyo_2020 %>% 
  select(-c(sport, name)) %>%
  plot_bar_char(team) +
  geom_bar(stat = "identity",  fill = '#4682B4') +
  scale_x_continuous(limits = c(1956, 2024), breaks = seq(1960, 2020, by = 4), labels = c("1960", "", "", "", "", "1980", "", "", "", "", "2000", "", "", "", "", "2020*")) +
  scale_y_continuous(limits = c(0, 300), breaks = seq(0,300, by = 50), position = 'right', expand = c(0,0)) +
  geom_hline(yintercept = 0, color = "black", size = 2) +
  #theme(axis.ticks.length.x = unit(0.25, "cm")) +
  labs(title = "Sports over the years",
       subtitle = "The Summer Olympic Games\n \n—\nCountries competing",
       caption = "Source: 1960-2016-Kaggle; 2020-olympics.com\n \n@lukorir")

# Bar plot of number of athletes competing
athletes_competing <- tokyo_2020 %>% 
  select(-c(sport, team)) %>%
  plot_bar_char(name) +
  geom_bar(stat = "identity",  fill = '#00CED1') +
  scale_x_continuous(limits = c(1956, 2024), breaks = seq(1960, 2020, by = 4), labels = c("1960", "", "", "", "", "1980", "", "", "", "", "2000", "", "", "", "", "2020†")) +
  scale_y_continuous(limits = c(0, 12000), breaks = seq(0,12000, by = 2000), position = 'right', expand = c(0,0),
                     labels = label_number(suffix = "", scale = 1e-3, accuracy = 1)) +
  geom_hline(yintercept = 0, color = "black", size = 2) +
  #theme(axis.ticks.length.x = unit(0.25, "cm")) +
  labs(title = "",
       subtitle = " \n \n—\nAthletes competing '000",
       caption = "† Includes IOC refugee team\n \n")

# Bar plot of number of sports
number_sports <- tokyo_2020 %>% 
  select(-c(name, team)) %>%
  plot_bar_char(sport) +
  geom_bar(stat = "identity",  fill = '#66CDAA')  + 
  scale_x_continuous(limits = c(1956, 2024), breaks = seq(1960, 2020, by = 4), labels = c("1960", "", "", "", "", "1980", "", "", "", "", "2000", "", "", "", "", "2020")) +
  scale_y_continuous(limits = c(0, 50), breaks = seq(0,50, by = 10), position = 'right', expand = c(0,0)) +
  geom_hline(yintercept = 0, color = "black", size = 2) +
  #theme(axis.ticks.length.x = unit(0.25, "cm")) +
  labs(title = "",
       subtitle = " \n \n—\nNumber of sports",
       caption = "* Held in 2021\n \n")

# Combine the plots
grid.arrange(countries_competing, athletes_competing, number_sports, nrow = 1)
#  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _  END _ _ _ _ _ _ _ _ _ _ _ _ _