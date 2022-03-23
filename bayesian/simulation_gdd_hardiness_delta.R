# goal is to simulate data for a multilevel model with crossed effects for variety and site
# main driver will be accumulated GDD > 5 between sampling dates
# secondary driver will be the change in GDD > 5 between 

# higher GDD > 5 means faster deacclimation rate
# higher change in GDD > 5 also means faster deacclimation rate but with less of an effect as total GDD > 5 sum

# Model:
# y ~ alpha_g + alpha_var + alpha_site + beta_1 * x_gdd_5_sum + beta_2 * x_gdd_5_delta + sigma_y

# set wd to be analogue to ML dir
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# Simulate Data

# parameters
sigma_y <- 1.5
alpha_g <- 0.5
beta_1 <- 0.2
beta_2 <- 0.05

# crossed hierarchical parameters
mu_var <- 0 # both zero because grand alpha
mu_site <- 0 

sigma_var <- 0.25
sigma_site <- 0.1

# create dataset
n_var <- 10
n_site <- 8
n_obs <- 4

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
sample_space_gdd_sum <- runif(n_sample_dates, 0, 40)
data$gdd_5_sum <- sample(sample_space_gdd_sum, n, replace = TRUE)

sample_space_gdd_delta <- runif(n_sample_dates, -4, 4)
data$gdd_5_delta <- sample(sample_space_gdd_delta, n, replace = TRUE)

# add in noise
data$sigma <- rnorm(n, 0, sigma_y)

# calculate hardiness_delta
data$hardiness_delta <- data$alpha_var + data$alpha_site + data$gdd_5_sum * beta_1 + data$gdd_5_delta * beta_2 + data$sigma
