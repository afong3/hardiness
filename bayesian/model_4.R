# fitting the model that was successful on fake data in simulation_gdd_hardiness_delta.R

library(rstanarm)
library(ggplot2)
library(rstan)
library(tidybayes)
library(modelr)

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")
# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
# Riesling and Pinot gris are artifacts of this flaw 
deacc <- data %>% filter(deacc == 1, variety != "Riesling", variety != "Pinot gris")

fit <- stan_glmer(hardiness_delta ~ DD_5_delta_test + DD_5_14 + (1 | site_encoded) + (1 | variety_encoded), data = deacc)

print(fit, digits = 4)

launch_shinystan(fit)

deacc %>%
    data_grid(DD_5_delta_test = DD_5_delta_test, DD_5_14 = DD_5_14, site_encoded = site_encoded, variety_encoded = variety_encoded) %>%
    add_predicted_draws(fit) %>%
    ggplot(aes(x = DD_5_delta_test, y = hardiness_delta)) +
    stat_lineribon(aes(y = .prediction), .width = c(0.99, 0.95, 0.8, 0.5), color = "#08519C")
