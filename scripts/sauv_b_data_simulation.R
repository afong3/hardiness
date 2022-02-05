# Started Feb 4th, 2022
# Simulating endo and eco dormancy hardiness delta for tmean

# setting wd to ./scripts to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/scripts")

# housekeeping
rm(list = ls())
options(stringsAsFactors = FALSE)

par(mfrow = c(1, 2), mar = c(5.1, 4.1, 6, 2.1))

# setting seed
set.seed(100)

# ecodormancy

n <- 100
b_0 <- 1 # change in hardiness per degree C tmean
x_0 <- runif(n, -10, 10) # mean temperature between -10 and 10
error_0 <- rnorm(n, 0, 3)
eco_sim <- b_0 * x_0 + error_0
eco <- data.frame("tmean_avg_14" = x_0, "hardiness_delta" = eco_sim)

plot(eco_sim ~ x_0, xlab = "Mean Temperature Sim",
ylab = "Change in Hardiness LTE50 Sim")
title(main = "Ecodormancy", line = 0.5)

# endodormancy`

b_1 <- -1.5 # change in hardiness per degree C tmean
x_1 <- runif(n, -10, 10) # mean temperature between -10 and 10
error_1 <- rnorm(n, 0, 4)
endo_sim <- b_1 * x_1 + error_1
endo <- data.frame("tmean_avg_14" = x_1, "hardiness_delta" = endo_sim)

plot(endo_sim ~ x_1, xlab = "Mean Temperature Sim",
ylab = "Change in Hardiness LTE50 Sim")

title(main = "Endodormancy", line = 0.5)

mtext("Simulated Endo and Eco Dormancy Hardiness Delta ",
 side = 3, line = -2, outer = TRUE)

# saving simulated data

write.csv(eco, "../data/simulations/ecodormancy_sim.csv")
write.csv(endo, "../data/simulations/endodormancy_sim.csv")