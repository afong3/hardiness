# Started Feburary 4, 2022

# Creating hardiness simulation data to validate that
# stan model is correctly estimating parameters.

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

hardiness <- read.csv("../data/model_train.csv")

# changing datetime to be the correct type
hardiness$datetime = as.Date(hardiness$datetime, format = "%Y-%m-%d")

sb <- hardiness[hardiness$variety == "Sauvignon blanc", ]
sb_oe <- sb[sb$site == "Oliver, east", ]

# filter for ecodormancy and endodormancy based on the
# boundary set by Fergusen et al.
# their relationship with temperature should be opposite
sb_endo <- sb_oe[sb_oe$DD_sum >= -300, ]

ylim_min <- min(na.omit(sb_endo$hardiness_delta)) - 0.5
ylim_max <- max(na.omit(sb_endo$hardiness_delta)) + 0.5
xlim_min <- min(na.omit(sb_endo$tmean_avg_14)) - 0.5
xlim_max <- max(na.omit(sb_endo$tmean_avg_14)) + 0.5


par(mfrow = c(3, 3), mar = c(5.1, 4.1, 6, 2.1))

# plot to show endodormancy vs tmean
for (season in unique(hardiness$season)) {
    years_list <- unique(format(sb[sb$season == season,]$datetime, "%Y"))
    year0 <- years_list[1]
    year1 <- years_list[2]

    plot(hardiness_delta ~ tmean_avg_14,
    data = sb_endo[sb_endo$season == season, ],
    ylim = c(ylim_min, ylim_max), xlim = c(xlim_min, xlim_max))

    title(main = paste(year0, "-", year1, "Season"), line = 0.5)
}

plot(hardiness_delta ~ tmean_avg_14, data = sb_eco, 
ylim = c(ylim_min, ylim_max), xlim = c(xlim_min, xlim_max))

title(main = "All Seasons", line = 0.5)

mtext("Seasonal Plots of Hardiness Change in Endodormancy",
side = 3, line = -2, outer = TRUE)
