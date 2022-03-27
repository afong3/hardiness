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
