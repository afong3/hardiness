# plotting the change in hardiness between 
library(ggplot2)
library(dplyr)

# load data

# plot hardiness and hardiness pct_chg on same graph per season
# differentiate variety with colors and site with shapes
# ggplot aes() object specs https://ggplot2.tidyverse.org/articles/ggplot2-specs.html # nolint

# setting wd to ./viz to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/viz")

hardiness <- read.csv("../data/model_train.csv")

# changing datetime to be the correct type
hardiness$datetime <- as.Date(hardiness$datetime, format = "%Y-%m-%d")


ggplot(hardiness, aes(days_since_aug_1, hardiness_delta)) + # nolint
geom_point(aes(color = variety)) +
ylim(-10, 10) +
labs(title = "Change in Lethal Temperature Threshold in Grapevines in Dormancy", #nolint
subtitle = expression(Delta * "T =" * "T"["t"] - "T"["t-1"]),
y = expression("Change in Lethal Temperature " * degree * "C"),
x = "Date",
colour = "Variety") +
geom_smooth(color = "black", linetype = "dashed", se = FALSE) +
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) # Nov, Dec, Jan, Feb, Mar, Apr #nolint

ggsave(paste0("hardiness_delta/", "hardiness_delta_all", ".png"))
