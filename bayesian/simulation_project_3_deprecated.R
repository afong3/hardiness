# Started March 7, 2022

# simulate data for delta hardiness & 14 day avg temp

# focusing on the deacclimation phase 
# seems like there is a baseline increase in hardiness deacclimation rate as photoperiod increases
# but this relationship can deviate based on the air temperature
# decrease in temperature means decrease in deacclimation rate
# increase in temperature means increase in deacclimation rate 

library(ggplot2)
library(rstanarm)
library(shinystan)
library(dplyr) # want %>%
library(modelr) # only want modelr::data_grid()

# set wd to be analogue to ML dir
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# set seed
set.seed(100)

# Simulated Data
# defining fake data parameters 
intercept <- 0 # if no change in temperature across the sample dates then photoperiod dominates
beta <- 0.33 

intercept_P <- 0.25 # photoperiod range of deacclimation is 140 - 180 so intercept will be ugly, I could adjust this by the smallest value but don't worry about this now
beta_P <- 0.1 

n <- 490 # to nicely fit the length of the sequence for photoperiod

# simulate DA data
temp <- rnorm(n, 4, 2.5) # mostly positive changes in temperature but the occasional cold spell
H_temp <- temp * beta + intercept
sigmaH_temp <- rnorm(n, 0, 1.5) # TODO: error that can eventually be accounted for by variety and site 
H_temp <- H_temp + sigmaH_temp
phase <- rep("Deacclimation", n)

# simulate photoperiod data
# in the real data, I sum the 'daylight hours' between sample dates
# This works out to be roughly 140 - 180 hours
# real data is biweekly so have the values have approx gaps between each other

photoperiod = seq(140, 180, 3)
photoperiod_gap_adj = rnorm(length(photoperiod), 0, 1)
P <- round(photoperiod - photoperiod_gap_adj) - 137.75 # subtract the lowest value possible 

H_P <- P * beta_P + intercept_P 

# making lists to append in the loop. Funky but gets the job done. Classic brute force
append_me_H <- c()
append_me_P <- c()

# making errors for each date and repeating photoperiod values
for (sample in 1:length(H_P)){
    sigmaH_P_per_sample_date <- rnorm(n / length(P), 0, 0.35) # let's just say there's a smaller error for photoperiod's effect
    H_P_adjusted <- sigmaH_P_per_sample_date + H_P[sample]
    
    P_rep <- rep(P[sample], length(H_P_adjusted))

    append_me_P <- c(append_me_P, P_rep)
    append_me_H <- c(append_me_H, H_P_adjusted)
}

P_column <- append_me_P
H_p_column <- append_me_H
temp_column <- temp
H_temp_column <- H_temp

# making changes on simulation by variety. There are 3 combinations of different slope, intercept, etc.
# variety 1: different temp slope, same intercept
# variety 2: different temp slope, different intercept
# variety 3: same temp slope, same intercept

# this should provide coverage for all possible outcomes
vs <- c(1,2,3)
varieties <- rep(vs, n / 2)[1:n] # get samples of all varieties


data <- data.frame(temp_delta = temp_column, photoperiod = P_column, hardiness_delta = H_p_column + H_temp_column, variety = varieties)

v1_slope_diff <- 0.1
v2_slope_diff <- -0.05
v2_intercept_diff <- -1

v1_hardiness_adj_slope <- ifelse(data$variety == 1, data$temp_delta * (v1_slope_diff), 0) # different temp slope, subtract from hardiness

v2_hardiness_adj_slope <- ifelse(data$variety == 2, data$temp_delta* (v2_slope_diff), 0) # different temp slope 
v2_hardiness_adj_intercept <- ifelse(data$variety == 2, v2_intercept_diff, 0) # different intercept

v3_hardiness_adj <- ifelse(data$variety == 3, 0, 0) # same slope and intercept

# adjusting hardiness data by variety
data$hardiness_delta <- data$hardiness_delta + v1_hardiness_adj_slope + v2_hardiness_adj_intercept + v2_hardiness_adj_slope + v3_hardiness_adj


# plotting model with both predictors 
data %>%
ggplot() + 
geom_point(aes(x = photoperiod, y = hardiness_delta, color = temp_delta)) + 
scale_color_gradient(low = "#0c2abf", high = "#e01e1e") + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days)") + 
ylab("Lethal Temp Change (C)")+
labs(title = "Data Simulation", subtitle = "hardiness_delta ~ photoperiod + (temp_delta | variety)")
# fitting model
fit <- stan_glmer(hardiness_delta ~ photoperiod + (1 + temp_delta | variety), data = data, iter = 3000, adapt_delta = 0.999 ) # adapt delta to prevent divergent 


launch_shinystan(fit)

print(coef(fit), digits = 4)
