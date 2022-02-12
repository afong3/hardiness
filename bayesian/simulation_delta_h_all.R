# Started Feb 11, 2022

# simulate data for delta hardiness & 14 day avg temp

# target <- change in hardiness range(-10, 10)
# predictor <- mean daily temperature range(-8, 15) & phase
# phase interactions:
# 1) Cold Acclimation
# 2) Deep Dormancy
# 3) Deacclimation
# beta1 != beta2 != beta3

# target ~ a + beta_CA*temp*CA + beta_DD*temp*DD + beta_DA*temp*DA
# CA, DD, and DA will be one hot encoded

# Simulated Data
# DD will not have much hardiness change 
# CA will be positively correlated with temperature
# DA will be negatively correlated with temperature 
library(ggplot2)
library(rstanarm)
library(shinystan)

intercept <- 0
beta_CA <- 0.33
beta_DD <- -0.02
beta_DA <- -0.33 

n <- 500

# H == Hardiness (LTE50)

# simulate DD data
## start with temperature data
temp_DD <- rnorm(n, -5, 4)
H_DD <- temp_DD * beta_DD + intercept
sigmaH_DD <- rnorm(n, 0, 1)
H_DD <- H_DD + sigmaH_DD
phase_DD <- rep("DD", n)

# simulate CA data
temp_CA <- rnorm(n, 7.5, 3) 
H_CA <- temp_CA * beta_CA + intercept
sigmaH_CA <- rnorm(n, 0, 2.5)
H_CA <- H_CA + sigmaH_CA
phase_CA <- rep("CA", n)

# simulate DA data
temp_DA <- rnorm(n, 8.5, 3.5)
H_DA <- temp_DA * beta_DA + intercept
sigmaH_DA <- rnorm(n, 0, 2)
H_DA <- H_DA + sigmaH_DA
phase_DA <- rep("DA", n)

# concatenate all phases
temp <- c(temp_DD, temp_CA, temp_DA)
H <- c(H_DD, H_CA, H_DA)
phase <- c(phase_DD, phase_CA, phase_DA)

# ordering the factors to make deep dormancy be the base intercept & slope 
data <- data.frame(mean_temp = temp, hardiness = H, phase = factor(phase, levels = c("DD", "CA", "DA"))) 

# plotting with regression lines (NOT THE LINES THAT SIM WAS BASED ON)
base_scatter <- ggplot(data,
aes(x = temp,
y = hardiness,
color = phase)) +
geom_point()

# fitting model
fit <- stan_glm(hardiness ~ mean_temp * phase, data = data)

# plotting lm regression lines ontop of base
base_scatter +
geom_smooth(method = "lm", se = F)

# plotting regression lines for interactions from stan
