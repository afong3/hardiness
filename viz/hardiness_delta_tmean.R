# February 11, 2022
# plotting the change in hardiness and compare it to
# mean temperature in different acclimation phases
library(ggplot2)
library(dplyr)

# setting wd to ./viz to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/viz")

# load data
hardiness <- read.csv("../data/model_train.csv")

# changing datetime to be the correct type
hardiness$datetime <- as.Date(hardiness$datetime, format = "%Y-%m-%d")

# breaking data into three phases, Cold Acclimation (CA), Deep Dormancy (DD), Deacclimation (DA) #nolint
# CA < December, December < DD < March, DA > Mar
data_CA <- hardiness[hardiness$days_since_aug_1 < 122, ] # nolint
data_DD <- hardiness[(hardiness$days_since_aug_1 >= 122) & (hardiness$days_since_aug_1 < 214), ] #nolint
data_DA <- hardiness[(hardiness$days_since_aug_1 >= 214), ] #nolint

# assign factors to data_phase
data_CA$phase <- factor(rep("Cold Acclimation", nrow(data_CA)))
data_DD$phase <- factor(rep("Deep Dormancy", nrow(data_DD)))
data_DA$phase <- factor(rep("Deacclimation", nrow(data_DA)))

# combine data back together
data <- rbind(data_CA, data_DD, data_DA)

# change level of factors
data$phase <- factor(data$phase, levels = c("Deep Dormancy", "Cold Acclimation", "Deacclimation"))

# relationship between tmax and hardiness delta and color by phase
hardiness_delta_tmean <- ggplot(data, aes(tmax_avg_14, hardiness_delta)) + # nolint
geom_point(aes(color = phase)) +
ylim(-10, 10) +
labs(title = "Change in Lethal Temperature Threshold in Grapevines in Dormancy", #nolint
subtitle = expression(Delta * "T =" * "T"["t"] - "T"["t-1"]),
y = expression(Delta * "T Change in Lethal Temperature " * degree * "C"),
x = expression("14 Day Average of Mean Daily Temperature " * degree * "C"), #nolint
color = "Dormancy Phase")

ggsave(paste0("hardiness_delta/", "hardiness_delta_tmean", ".png"))
