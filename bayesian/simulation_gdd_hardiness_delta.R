# goal is to simulate data for a multilevel model with crossed effects for variety and site
# main driver will be accumulated GDD > 5 between sampling dates
# secondary driver will be the change in GDD > 5 between 

# higher GDD > 5 means faster deacclimation rate
# higher change in GDD > 5 also means faster deacclimation rate but with less of an effect as total GDD > 5 sum

# Model:
# y ~ normal(mu_y, sigma_y)
# y ~ alpha_g + alpha_var + alpha_site + beta_1 * x_gdd_5_sum + sigma_y
# alpha_var ~ normal(0, sigma_var)
# alpha_site ~ normal(0, sigma_site)

library(rstanarm)
library(ggplot2)
library(dplyr)
library(tidybayes)
library(modelr)
library(tidyverse)

# set wd to be analogue to ML dir
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# Simulate Data

# parameters
sigma_y <- 1.5
alpha_g <- 2
beta_1 <- 0.2

# crossed hierarchical parameters
mu_var <- 0 # both zero because grand alpha
mu_site <- 0 

sigma_var <- 0.5
sigma_site <- 0.1

# create dataset
n_var <- 15
n_site <- 13
n_obs <- 3

n <- n_var * n_site * n_obs

# individual site alphas, drawn from site distribution
site_alphas <- rnorm(n_site, mean = mu_site, sd = sigma_site)

# individual variety alphas, drawn from variety distribution
var_alphas <- rnorm(n_var, mean = mu_var, sd = sigma_var)

# making dataframe to make easy merging
df_sites <- data.frame(site = seq(1,n_site), alpha_site = site_alphas)
df_vars <- data.frame(var = seq(1, n_var), alpha_var = var_alphas)

# create columns of combinations
sites_col <- rep(seq(1, n_site), each = n_var * n_obs)
var_col <- rep(seq(1, n_var), times = n_site, each = n_obs)

data <- data.frame(site = sites_col, var = var_col)

# add in var alphas col 
data <- merge(data, df_vars, by = "var")

# add in site alphas col
data <- merge(data, df_sites, by = "site")

# add in GDD > 5 column but simulate them looking like real data
n_sample_dates <- 20
sample_space_gdd_delta <- runif(n_sample_dates, -20, 40)
data$gdd_5_delta <- sample(sample_space_gdd_delta, n, replace = TRUE)

# add in noise
data$sigma <- rnorm(n, 0, sigma_y)

# calculate hardiness_delta
data$hardiness_delta <- alpha_g + data$alpha_var + data$alpha_site + data$gdd_5_delta * beta_1 + data$sigma

# prior definitions
# beta_1 ~ normal(mu_b_1, sigma_b_1)
prior_b1_mu = 0.2
prior_b2_mu = 0.1 
prior_b1_sigma = 0.2
prior_b2_sigma = 0.1

# check out https://www.bayesrulesbook.com/chapter-17.html for setting crossed effect priors


# fit model
fit <- stan_glmer(hardiness_delta ~ gdd_5_delta + (1 | site) + (1 | var), data = data,
    prior_intercept = normal(2, 1.5),
    prior = normal(location = prior_b1_mu, scale = prior_b1_sigma)
    )

print(fit, digits = 4)

draws <- spread_draws(fit, `(Intercept)`, gdd_5_delta)
df_posterior <- fit %>%
    as.data.frame() %>%
    as_tibble()

df_effects <- df_posterior %>%
    mutate_at(
        .vars = vars(matches("b\\[\\(Intercept")), 
        .funs = ~ . + df_posterior$`(Intercept)`
    )

df_long_effects <- df_effects %>%
    select(matches("b\\[")) %>%
    rowid_to_column("draw") %>%
    tidyr::gather(Parameter, Value, -draw)

df_long_effects$Type <- df_long_effects$Parameter %>%
    stringr::str_detect("Intercept") %>%
    ifelse(., "Intercept", "Slope_DD")

df_long_effects$Site <- df_long_effects$Parameter %>%
    stringr::str_detect("site") %>%
    ifelse(., str_extract(df_long_effects$Parameter, "\\d+"), NA)

df_long_effects$variety_encoded <- df_long_effects$Parameter %>%
    stringr::str_detect("var") %>%
    ifelse(., str_extract(df_long_effects$Parameter, "\\d+"), NA)

df_long_effects <- df_long_effects %>%
    select(draw, variety_encoded, Site, Effect = Type, Value)


variety_intercepts <- df_long_effects %>%
    filter(!is.na(variety_encoded)) %>%
    filter(Effect == "Intercept") %>%
    select(Value) %>%
    rename(Intercept = Value)

df_variety_sample <- df_long_effects %>%
    filter(!is.na(variety_encoded)) %>%
    filter(Effect == "Intercept") %>%
    select(draw, variety_encoded) %>%
    mutate(variety_intercepts, slope = sample(df_effects$gdd_5_delta, nrow(variety_intercepts), replace = TRUE)) %>%
    filter(draw %in% sample(1:length(unique(.$draw)), size = 100))

df_site_sample <- df_long_effects %>%
    filter(!is.na(Site)) %>%
    pivot_wider(names_from = Effect, values_from = Value) %>%
    select(draw, site_encoded = Site, Intercept) %>%
    mutate(slope = sample(df_effects$gdd_5_delta, nrow(.), replace = TRUE)) %>%
    filter(draw %in% sample(1:length(unique(.$draw)), size = 50))

variety_partial_pooling <- data %>% 
    mutate(variety_encoded = var) %>%
    ggplot(aes(x = gdd_5_delta, y = hardiness_delta, color = factor(site))) +
    geom_abline(
        aes(intercept = Intercept, slope = slope),
            data = df_variety_sample,
            color = "#3366FF",
            alpha = 0.1
    ) +
    geom_jitter(width = 3, alpha = 0.4) +
    facet_wrap("variety_encoded") + 
    labs(title = "Simulated Data, Faceted by Variety",
        subtitle = "Partial pooling across varieties.\n50 posterior draws are shown by variety.\nSite effect is not shown.",
        color = "Vineyard",
        x = "Change in GDD > 5",
        y = "Change in Lethal Temperature (C)")

ggsave(file="../viz/simulated_data.png", width=6, height=6, dpi=300)

# plotting model: need to do posterior predictive checks on simulation as well
data %>%
    ggplot() +
    geom_point(aes(x = gdd_5_delta, y = hardiness_delta)) +
    geom_abline(data = draws, aes(intercept = `(Intercept)`, slope = gdd_5_delta), size = 0.2, alpha = 0.1, color = 'red')
