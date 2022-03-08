# Trying to get just deacclimation phase by filtering for negative percent change with large magnitude
library(tidyr)
library(dplyr)
library(ggplot2)
# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# filter for when deacclimation starts, not including Riesling because it's behaving very unexpectedly
deacc <- data %>% filter(deacc == 1)

deacc %>%
filter(season != 3, variety != "Riesling") %>%
ggplot() +
geom_point(aes(x = sunlight_14_total, y = hardiness_delta, color = tmax_delta_14))

# wtf is going on with riesling 

data %>%
filter(deacc == 1) %>%
ggplot() + 
geom_point(aes(x = days_since_aug_1, y = hardiness))+
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) # Nov, Dec, Jan, Feb, Mar, Apr #nolint

