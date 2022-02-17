# plotting the hardiness for all varieties and all sites 
library(ggplot2)
library(dplyr)

# load data

# plot hardiness and hardiness pct_chg on same graph per season
# differentiate variety with colors and site with shapes
# ggplot aes() object specs https://ggplot2.tidyverse.org/articles/ggplot2-specs.html # nolint

# setting wd to ./viz to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/viz")

weather <- read.csv("../data/predictors.csv")
hardiness <- read.csv("../data/model_train.csv")

# filter so that weather is only for the period we care about
max_d <- max(hardiness$days_since_aug_1)
min_d <- min(hardiness$days_since_aug_1)
weather <- weather[(weather$days_since_aug_1 > min_d) & (weather$days_since_aug_1 < max_d), ]


# changing datetime to be the correct type
hardiness$datetime <- as.Date(hardiness$datetime, format = "%Y-%m-%d")

### WITHOUT PHASE BOUNDARIES

base <- ggplot(hardiness, aes(days_since_aug_1, hardiness)) + # nolint
geom_point(aes(color = variety)) +
ylim(-30, -5) +
labs(title = "Lethal Temperature Threshold for Grapevines in Dormancy 2012 - 2018", #nolint
y = expression("Lethal Temperature Threshold" * degree * "C"),
x = "Date",
colour = "Variety") +

# converting days since august 1st to be month abbreviations
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) # Nov, Dec, Jan, Feb, Mar, Apr #nolint

ggsave(paste0("hardiness/", "hardiness_all", ".png"))


### WITH PHASE BOUNDARIES

hardiness_phases <- ggplot(hardiness, aes(days_since_aug_1, hardiness)) + # nolint
geom_point(aes(color = variety)) +
ylim(-30, 15) +
labs(title = "Grapevine Hardiness and Mean Air Temperature, 2012 - 2018", #nolint
y = expression("Temperature " * degree * "C"),
x = "Date",
colour = "Legend") +

# MLE trendline
geom_smooth(method = 'gam', color = "black", linetype = "dashed", se = FALSE) +

# converting days since august 1st to be month abbreviations
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) +# Nov, Dec, Jan, Feb, Mar, Apr #nolint

# emphasizing the deep dormancy phase
geom_vline(xintercept = c(122, 214),
linetype = "dashed", colour = "black") + 

# adding tmean
geom_point(aes(x = days_since_aug_1, y = tmean_avg_14, color = "14 Day Mean Temperature"), data = weather) 

ggsave(paste0("hardiness/", "hardiness_all_with_phases", ".png"))
