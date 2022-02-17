# Started Feb 11, 2022

# simulate data for delta hardiness & 14 day avg temp

# target <- change in hardiness range(-10, 10)
# predictor <- mean daily temperature range(-8, 15) & phase
# phase interactions:
# 1) Cold Acclimation
# 2) Deep Dormancy
# 3) Deacclimation
# beta1 != beta2 != beta3

# The following is the regression if CA, DD, DA are one hot encoded for phase
# baseline is Deep Dormancy
# target ~ a + a_CA*CA + a_DA*DA +
#          temp*beta + beta_CA*temp*CA + beta_DA*temp*DA

library(ggplot2)
library(rstanarm)
library(shinystan)
library(tidybayes) # want add_posterior_epred
library(dplyr) # want %>%
library(modelr) # only want modelr::data_grid()

# set wd to be analogue to ML dir
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# set seed
set.seed(100)

# Simulated Data
# DD will not have much hardiness change 
# DA will be positively correlated with temperature
# CA will be negatively correlated with temperature 

# defining fake data parameters 
intercept_CA <- 0
intercept_DD <- 0
intercept_DA <- 0
beta_CA <- -0.33
beta_DD <- -0.02
beta_DA <- 0.33 

n <- 500

# H == Hardiness (LTE50)

# simulate DD data
## start with temperature data
temp_DD <- rnorm(n, -5, 4)
H_DD <- temp_DD * beta_DD + intercept_DD
sigmaH_DD <- rnorm(n, 0, 1)
H_DD <- H_DD + sigmaH_DD
phase_DD <- rep("Deep Dormancy", n)

# simulate CA data
temp_CA <- rnorm(n, 7.5, 3) 
H_CA <- temp_CA * beta_CA + intercept_CA
sigmaH_CA <- rnorm(n, 0, 2.5)
H_CA <- H_CA + sigmaH_CA
phase_CA <- rep("Cold Acclimation", n)

# simulate DA data
temp_DA <- rnorm(n, 8.5, 3.5)
H_DA <- temp_DA * beta_DA + intercept_DA
sigmaH_DA <- rnorm(n, 0, 2)
H_DA <- H_DA + sigmaH_DA
phase_DA <- rep("Deacclimation", n)

# concatenate all phases
temp <- c(temp_DD, temp_CA, temp_DA)
H <- c(H_DD, H_CA, H_DA)
phase <- c(phase_DD, phase_CA, phase_DA)

# ordering the factors to make deep dormancy (DD) be the base intercept & slope 
data <- data.frame(mean_temp = temp, hardiness_delta = H, phase = factor(phase, levels = c("Deep Dormancy", "Cold Acclimation", "Deacclimation"))) 

# fitting model
fit <- stan_glm(hardiness_delta ~ mean_temp * phase, data = data)

# plotting with regression lines (NOT THE LINES THAT SIM WAS BASED ON)
base_scatter <- ggplot(data,
aes(x = temp,
y = hardiness_delta,
color = phase)) +
geom_point() 

# plotting true lines on scatter 
true_params <- base_scatter +
    geom_abline(
        intercept = c(intercept_DD, intercept_CA, intercept_DA),
        slope = c(beta_DD, beta_CA, beta_DA),
        colour = c("red", "green", "blue")
    ) + 
    labs(
        title = "Simulated Hardiness Change and Temperature Data with True Linear Parameters",
        x = "Mean Temperature of Previous 14 Days",
        y = expression(Delta * "T, " * "Change in Lethal Temperature " * degree * "C"),
        color = "Dormancy Phase"
    )

ggsave(paste0("../viz/presentations/project_2/", "sim_true_params", ".png"))

# check out tidy bayes for good vignettes to plot posteriors with interactions 
# https://cran.r-project.org/web/packages/tidybayes/vignettes/tidy-rstanarm.html
# adding posterior draws 
posterior_preds <- data %>%
    group_by(phase) %>%
    data_grid(
    mean_temp = seq_range(mean_temp, n = 101),
    hardiness_delta = seq_range(hardiness_delta, n = 101)
    ) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    ggplot(aes(x = mean_temp, y = hardiness_delta, color = phase)) +
    geom_line(aes(y = .epred, group = paste(phase, .draw)), alpha = 0.1) +
    geom_point(data = data) +
    labs(
        title = "Simulation of Grapevine Cold Hardiness Response to Mean Temperature",
        subtitle = expression(Delta * "T =" * "T"["t"] - "T"["t-1"]),
        color = 'Phase',
        x = "Mean Temperature of Previous 14 Days",
        y = expression(Delta * "T, " * "Change in Lethal Temperature " * degree * "C")
    )

ggsave(paste0("../viz/presentations/project_2/", "sim_posterior_draws", ".png"))

# plotting regression lines for interactions from stan
# Regression Equation Terms:
## Intercept         | Deep dormancy phase regression intercept
## mean_temp         | mean_temp effect on deep dormancy
## phaseCA           | Cold acclimation phase regression intercept
## phaseDA           | Deacclimation phase regression intercept
## mean_temp:phaseCA | increase in effect of change of mean_temp on hardiness in CA
## mean_temp:phaseDA | decrease '     '    '    '   '      '     '     '     '   DA
## sigma (aux)       | error standard deviation  

# Stan successfully recovered the simulated data parameters across each phase

fit_coef <- coef(fit)
