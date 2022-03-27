# fitting the model that was successful on fake data in simulation_gdd_hardiness_delta.R

library(rstanarm)
library(ggplot2)
library(rstan)
library(tidybayes)
library(modelr)
library(dplyr)
library(tidyr)
library(tidyverse)

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data_3_5 <- read.csv("../data/model_train_3_5.csv")
data_3_0 <- read.csv("../data/model_train_3_0.csv")
data_2_5 <- read.csv("../data/model_train_2_5.csv")
data_2_0 <- read.csv("../data/model_train_2_0.csv")

deacc_3_5 <- data_3_5 %>% filter(deacc == 1)
deacc_3_0 <- data_3_0 %>% filter(deacc == 1)
deacc_2_5 <- data_2_5 %>% filter(deacc == 1)
deacc_2_0 <- data_2_0 %>% filter(deacc == 1)

data_3_5$threshold <- 3.5
data_3_0$threshold <- 3.0
data_2_5$threshold <- 2.5
data_2_0$threshold <- 2.0

data <- rbind(data_3_5, data_3_0, data_2_5, data_2_0)

deacc_threshold <- data %>%
    ggplot() + 
    geom_point(aes(x = days_since_aug_1, y = hardiness, color = factor(deacc))) + 
    facet_wrap(~factor(threshold))

data %>%
    filter(deacc == 1) %>%
    ggplot() + 
    geom_jitter(width = 2, aes(x = DD_5_delta_test, y = hardiness_delta, color = factor(season))) +
    facet_wrap(~factor(threshold))

# find differnces between dataframes of thresholds

# 3_0 - 3_5
deacc_diff_1 <- deacc_3_0 %>% anti_join(deacc_3_5, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# 2_5 - 3_0 
deacc_diff_2 <- deacc_2_5 %>% anti_join(deacc_3_0, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# 2_0 - 2_5
deacc_diff_3 <- deacc_2_0 %>% anti_join(deacc_2_5, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# add the differences to a deacc_3_5 
diffs <- deacc_3_5 %>%
    mutate(threshold = "> 3.5 C")

diffs <- diffs %>%
    rbind(., deacc_diff_1 %>% mutate(threshold = "> 3.0 C")) %>%
    rbind(., deacc_diff_2 %>% mutate(threshold = "> 2.5 C")) %>%
    rbind(., deacc_diff_3 %>% mutate(threshold = "> 2.0 C")) 

# plot the differences 
diffs %>%
    ggplot() + 
    geom_jitter(width = 3, aes(x = days_since_aug_1, y = hardiness, color = threshold, shape = variety == "Pinot gris")) +
    labs(title = "Varying Deacclimation Thresholds and the Additional Data that is Introduced",
    y = "Lethal Temperature (C)",
    x = "") + 
    scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
    labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) # Nov, Dec, Jan, Feb, Mar, Apr #nolint

nrow(diffs)
nrow(deacc_2_0)