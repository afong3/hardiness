# Started January 30th, 2022
# Simulate change in hardiness cold hardiness as a function of average air temperature")

# housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

# adding space for second axis
par(mfrow = c(5,5), mar=c(1.5,1.5,1.5,1.5) + 0.3)

# import data
data = read.csv("../data/model_inputs.csv")

# make datetime into a datetime object
data$datetime = strptime(data$datetime, format = "%Y-%m-%d")

# make julian day 
data$julian = julian(data$datetime)

# focus on one variety first - with most samples... Merlot
merlot = data[data$variety == "Merlot",]

# 7 seasons of data
n_seasons = unique(merlot$season)

# plot the hardiness in a season
for (season in n_seasons){
  merlot_season = merlot[merlot$season == season,]
  plot(hardiness_delta_abs ~ julian, data = merlot_season, ylim = c(-10, 10), col = "red")
  par(new = TRUE)
  plot(param_tmax ~ julian, data = merlot_season, axes = FALSE, col = "green")
  axis(side = 4, at = pretty(range(merlot$param_tmax)))
}
