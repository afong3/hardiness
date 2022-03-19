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

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
# Riesling and Pinot gris are artifacts of this flaw 
deacc <- data %>% filter(deacc == 1, variety != "Riesling", variety != "Pinot gris")

# s
deacc$sunlight_14_adjusted <- deacc$sunlight_14_total - min(deacc$sunlight_14_total)

# sunlight_14_total: total number of hours of 'daylight' in the previous two weeks. calculated based on date and location
# tmax_delta_14: change between sample dates of maximum daily temperature averaged in the previous two weeks
fit <- stan_glmer(hardiness_delta ~ sunlight_14_adjusted + (1 + tmax_delta_14 | variety), data = deacc, iter = 5000)

fit2 <- stan_glm(hardiness_delta ~ sunlight_14_adjusted, data = deacc)

fit3 <- stan_glmer(hardiness_delta ~ (1 + tmax_delta_14 | variety), data = deacc, iter = 5000)

print(fit, digits = 4)
print(fit2, digits = 4)
print(fit3, digits = 4)

launch_shinystan(fit)

min(deacc$sunlight_14_total)

head(deacc$sunlight_14_adjusted)

pairs(deacc[,c("sunlight_14_adjusted", "tmax_delta_14")])

cor(deacc[,c("sunlight_14_adjusted", "tmax_delta_14")])

cor(drop_na(deacc[,c("tmax_delta_14", "hardiness_delta")]))

vif(fit)
