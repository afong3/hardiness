# started March 7, 2022

# this is the complement to the simulation script 'simulation_project_3.R'
# In the simulation script, the model nicely recovered the true parameters
# Now it's time to fit the model to the real data 

# Remember, this is all deacclimation phase data

library(tidyr)
library(dplyr)
library(ggplot2)
library(ggpubr) # for making grids of ggplots

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
deacc <- data %>% filter(deacc == 1, variety != "Riesling", variety != "Pinot gris")

