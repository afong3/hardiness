# started March 7, 2022

# this is the complement to the simulation script 'simulation_project_3.R'
# In the simulation script, the model nicely recovered the true parameters
# Now it's time to fit the model to the real data 

# Remember, this is all deacclimation phase data

library(tidyr)
library(dplyr)
library(ggplot2)
library(ggpubr) # for making grids of ggplots
library(rstanarm)
library(rstan)

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

data$sunlight_14_adjusted <- data$sunlight_14_total - min(data$sunlight_14_total)

# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
# Riesling and Pinot gris are artifacts of this flaw 
deacc <- data %>% filter(deacc == 1, variety != "Riesling", variety != "Pinot gris")
acc <- data %>% filter(deacc == 0, variety != "Riesling", variety != "Pinot gris")

# s

# sunlight_14_total: total number of hours of 'daylight' in the previous two weeks. calculated based on date and location
# tmax_delta_14: change between sample dates of maximum daily temperature averaged in the previous two weeks
fit <- stan_glmer(hardiness_delta ~ sunlight_14_adjusted + (1 + tmax_delta_14 | variety), data = deacc, iter = 5000)

fit2 <- stan_glm(hardiness_delta ~ sunlight_14_adjusted, data = deacc)

fit3 <- stan_glmer(hardiness_delta ~ (1 + tmax_delta_14 | variety), data = deacc, iter = 5000)

fit4 <- stan_glmer(hardiness_delta ~ days_since_aug_1 + (1 + tmax_delta_14 | variety), data = deacc, iter = 5000)

print(fit, digits = 4)
print(fit2, digits = 4)
print(fit3, digits = 4)
print(fit4, digits = 4)

launch_shinystan(fit)

cor(drop_na(deacc[,c("hardiness_delta", "DD_5_14", "DD_5_delta_14", "days_since_aug_1", "sunlight_delta_14")]))
cor(drop_na(acc[,c("hardiness_delta", "DD_5_14", "DD_5_delta_14", "DD_0_14", "sunlight_delta_14")]))
cor(drop_na(data[,c("hardiness_delta", "DD_5_14", "DD_5_delta_14", "DD_0_14", "sunlight_delta_14")]))

deacc %>%
    ggplot() + 
    geom_point(aes(x = DD_5_14, y = hardiness_delta, color = DD_5_delta_14)) 

# checkout this plot tho

interesting <- data %>%
    ggplot() +
    geom_point(aes(x = DD_5_delta_14, y = hardiness_delta, color = tmax_delta_14))
