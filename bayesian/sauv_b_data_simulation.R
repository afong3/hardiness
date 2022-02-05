# Started Feb 4th, 2022
# Simulating endo and eco dormancy hardiness delta for tmean

# housekeeping
rm(list = ls())
options(stringsAsFactors = FALSE)

par(mfrow = c(1, 2))

# ecodormancy

n <- 100
b_0 <- 1 # change in hardiness per degree C tmean
x_0 <- runif(n, -10, 10) # mean temperature between -10 and 10
error_0 <- rnorm(n, 0, 3)
eco_sim <- b_0 * x_0 + error_0

plot(eco_sim ~ x_0)
title(main = "Ecodormancy", line = 0.5)

# endodormancy

b_1 <- -1.5 # change in hardiness per degree C tmean
x_1 <- runif(n, -10, 10) # mean temperature between -10 and 10
error_1 <- rnorm(n, 0, 4)
endo_sim <- b_1 * x_1 + error_1

plot(endo_sim ~ x_1)
title(main = "Endodormancy", line = 0.5)

mtext("Seasonal Plots of Hardiness Change in Endodormancy",
side = 3, line = -2, outer = TRUE)
