# visualizing change in hardiness to separate CA / CD phases
# plotting hardiness_delta and hardiness on the same plot screen
# only sauvignon blanc from oliver east will be plotted
library(ggplot2)
library(dplyr)

# load data

# separate by season

# plot hardiness and hardiness pct_chg on same graph per season
# differentiate variety with colors and site with shapes
# ggplot aes() object specs https://ggplot2.tidyverse.org/articles/ggplot2-specs.html # nolint

# setting wd to ./viz to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/viz")

hardiness <- read.csv("../data/model_train.csv")

# changing datetime to be the correct type
hardiness$datetime <- as.Date(hardiness$datetime, format = "%Y-%m-%d")

sauv_b <- hardiness[hardiness$variety == "Sauvignon blanc", ]

# split up the data into unique seasons
seasons <- sauv_b %>% group_by(season) %>% group_split()

for (season in unique(hardiness$season)) {
    site_counts <- seasons[[season]] %>%
    group_by(site) %>%
    summarize(count = n())

    oe_data <- seasons[[season]][seasons[[season]]$site == "Oliver, east", ]

    ggplot(oe_data, aes(datetime, hardiness_delta)) + # nolint
    geom_point(aes(color = variety)) +
    ylim(-10, 10) +
    labs(title = paste("Season", season, "Sauvignon Blanc, Oliver East"),
    y = "Change in Hardiness (LTE 50)",
    x = "Date",
    colour = "Variety") +
    geom_hline(yintercept = c(-2.5, 2.5), linetype = "dashed", color = "#8fc77c") + # nolint
    geom_text(aes(median(datetime), 2.5, label = "Simplified Deep Dormancy Boundary", vjust = - 1)) #nolint

    ggsave(paste0("hardiness_delta/", "sauvb_oe_", "season", "_", season, ".png")) # nolint
}
