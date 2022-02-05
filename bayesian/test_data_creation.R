# Started Feburary 4, 2022

# Creating hardiness simulation data to validate that stan model is correctly estimating parameters. 

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

hardiness <- read.csv("../data/model_train.csv")

# changing datetime to be the correct type
hardiness$datetime = as.Date(hardiness$datetime, format = "%Y-%m-%d")

sb <- hardiness[hardiness$variety == "Sauvignon blanc",]
sb_oe <- sb[sb$site == "Oliver, east",]

par(mfrow = c(3,3))

for (season in unique(hardiness$season)){
    plot(hardiness_delta ~ tmean_avg_14, data = sb[sb$season == season,], ylim = c(-9, 9), col = site_encoded)
    title(main = paste(season))
    }


