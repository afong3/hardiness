# visualizing percent change in hardiness to separate CA / CD phases
# plotting pct_chg and hardiness on the same plot screen

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

# split up the data into unique seasons
seasons <- hardiness %>% group_by(season) %>% group_split()

for (season in unique(hardiness$season)) {
    site_counts <- seasons[[season]] %>%
    group_by(site) %>%
    summarize(count = n())

    max_site <- site_counts$site[site_counts$count == max(site_counts$count)]

    max_site_data <- seasons[[season]][seasons[[season]]$site == max_site, ]
    season_num <- unique(seasons[[season]]$season)[1]

    ggplot(seasons[[season]], aes(datetime, hardiness_pct_chg)) + # nolint
    geom_point(aes(color = variety)) +
    ylim(-0.6, 0.6) +
    labs(title = paste("Season", season_num, "Across all Sites"),
    y = "Change in Hardiness (%)",
    x = "Date",
    colour = "Variety")

    ggsave(paste0("pct_chg/", "season", "_", season_num, ".png"))
}
