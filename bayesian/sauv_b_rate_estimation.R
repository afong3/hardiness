# running stan LR to get the estimate of the true parameters set in
# ../scripts/sauv_b_data_simulation.R # nolint

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# set seed
set.seed(100)

# load stan
library(rstanarm)
library(shinystan)

# loading data
eco <- read.csv("../data/simulations/ecodormancy_sim.csv")
endo <- read.csv("../data/simulations/endodormancy_sim.csv")

# True parameters
# mu = 1, sigma ~ normal(0, 3), intercept = 0
fit_eco <- stan_glm(hardiness_delta ~ tmean_avg_14, data = eco)

# True parameters
# mu = -1.5, sigma ~ normal(0, 3), intercept = 0
fit_endo <- stan_glm(hardiness_delta ~ tmean_avg_14, data = endo)

# Playing with priors and small amounts of data
eco_small <- eco[sample(nrow(eco), 10), ] # 10 random samples from eco

fit_eco_small <- stan_glm(hardiness_delta ~ tmean_avg_14, data = eco_small,
prior = normal(0, 0.2), prior_intercept = normal(10, 2)) # strong priors

# same prior, full data
fit_eco_strong_priors <- stan_glm(hardiness_delta ~ tmean_avg_14, data = eco,
prior = normal(0, 0.2), prior_intercept = normal(10, 2)) # strong priors

# saving to this file
png(file = "../viz/simulations/simulated_data_eco_endo.png")

# open plot space
par(mfrow = c(2, 2), mar = c(5.1, 4.1, 6, 2.1))

# plotting the simulated data and the estimated line from stan_glm
plot(hardiness_delta ~ tmean_avg_14, data = eco,
xlab = "Mean Average Temperature", ylab = "Change in Hardiness",
xlim = c(-10, 10), ylim = c(-20, 20))
abline(coef(fit_eco)[1], coef(fit_eco)[2])
title(main = "Ecodormancy, Default Priors", line = 0.5)

plot(hardiness_delta ~ tmean_avg_14, data = endo,
xlab = "Mean Average Temperature", ylab = "Change in Hardiness",
xlim = c(-10, 10), ylim = c(-20, 20))
abline(coef(fit_endo)[1], coef(fit_endo)[2])
title(main = "Endodormancy, Default Priors", line = 0.5)

plot(hardiness_delta ~ tmean_avg_14, data = eco_small,
xlab = "Mean Average Temperature", ylab = "Change in Hardiness",
xlim = c(-10, 10), ylim = c(-20, 20))

# plot sample lines from posterior
n <- 5
a_post <- rnorm(n, fit_eco_small$coefficients[1], fit_eco_small$ses[1])
b_post <- rnorm(n, fit_eco_small$coefficients[2], fit_eco_small$ses[2])

for (i in seq_len(a_post)) {
    abline(a_post[i], b_post[i])
}

title(main = "10 Samples from Eco, Strong Priors\n5 Posterior Draws")

plot(hardiness_delta ~ tmean_avg_14, data = eco,
xlab = "Mean Average Temperature", ylab = "Change in Hardiness",
xlim = c(-10, 10), ylim = c(-20, 20))
abline(coef(fit_eco_strong_priors)[1], coef(fit_eco_strong_priors)[2])
title(main = "Ecodormancy, Strong Priors", line = 0.5)


mtext("Simulated Data with Fitted Parameters",
side = 3, line = -2, outer = TRUE)

# saving the png file
dev.off()
