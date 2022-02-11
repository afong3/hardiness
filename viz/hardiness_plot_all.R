# plotting the hardiness for all varieties and all sites 
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


ggplot(hardiness, aes(days_since_aug_1, hardiness)) + # nolint
geom_point(aes(color = variety)) +
ylim(-30, -5) +
labs(title = "Lethal Temperature Threshold for Grapevines in Dormancy", #nolint
y = expression("Lethal Temperature Threshold" * degree * "C"),
x = "Date",
colour = "Variety") +

# MLE trendline
geom_smooth(color = "black", linetype = "dashed", se = FALSE) +

# converting days since august 1st to be month abbreviations
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) +# Nov, Dec, Jan, Feb, Mar, Apr #nolint

# emphasizing the deep dormancy phase
geom_vline(xintercept =  = c(122, 214),
linetype = "dashed", color = "#000000",
show.legend = TRUE)


ggsave(paste0("hardiness/", "hardiness_all", ".png"))
