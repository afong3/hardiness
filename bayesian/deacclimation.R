# Trying to get just deacclimation phase by filtering for negative percent change with large magnitude
library(tidyr)
library(dplyr)
library(ggplot2)
# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# filter for when deacclimation starts
deacc <- data %>% filter(deacc == 1)

deacc %>%
filter(variety == "Riesling") %>%
ggplot() +
geom_point(aes(x = tmax_avg_14, y = hardiness_delta, color = factor(season)))

# wtf is going on with riesling in season 5 

data %>%
filter( season == "2") %>%
ggplot() + 
geom_point(aes(x = days_since_aug_1, y = hardiness, color = factor(site)))
