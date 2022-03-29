# fitting the model that was successful on fake data in simulation_gdd_hardiness_delta.R

library(rstanarm)
library(ggplot2)
library(rstan)
library(tidybayes)
library(modelr)
library(dplyr)
library(tidyr)
library(tidyverse)

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data_3_5 <- read.csv("../data/model_train_3_5.csv")
data_3_0 <- read.csv("../data/model_train_3_0.csv")
data_2_5 <- read.csv("../data/model_train_2_5.csv")
data_2_0 <- read.csv("../data/model_train_2_0.csv")

deacc_3_5 <- data_3_5 %>% filter(deacc == 1)
deacc_3_0 <- data_3_0 %>% filter(deacc == 1)
deacc_2_5 <- data_2_5 %>% filter(deacc == 1)
deacc_2_0 <- data_2_0 %>% filter(deacc == 1)

data_3_5$threshold <- "Least Data: 3.5 (C)"
data_3_0$threshold <- "3.0 (C)"
data_2_5$threshold <- "2.5 (C)"
data_2_0$threshold <- "Most Data: 2.0 (C)"

data <- rbind(data_3_5, data_3_0, data_2_5, data_2_0)

# making names that are too long, shorter
data$site <- ifelse(data$site == "Osoyoos, northeast", "Osoyoos, NE", data$site)
data$site <- ifelse(data$site == "Osoyoos, southeast", "Osoyoos, SE", data$site)

data$variety <- ifelse(data$variety == "Cabernet Sauvignon", "Cabernet Sauv", data$variety)

deacc_threshold <- data %>%
    ggplot() + 
    geom_jitter(width = 3, size = 0.66, aes(x = days_since_aug_1, y = hardiness, color = deacc == 1)) + 
    facet_wrap(~factor(threshold)) +
    labs(title = "Grapevine Cold Hardiness from 2012 - 2018",
    subtitle = "Deacclimation begins once a grapevine loses X (Celsius) of hardiness",
    y = "Lethal Temperature Threshold (C)",
    x = "Date (jittered)",
    color = "Deacclimation Period") + 
    scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
    labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) # Nov, Dec, Jan, Feb, Mar, Apr #nolint

ggsave(file="../viz/varying_deacc_thresholds.png", width=6, height=4, dpi=300)
# find differnces between dataframes of thresholds
# 3_5 has the least amount of data, 2_0 has the most amount of data

# 3_0 - 3_5
deacc_diff_1 <- deacc_3_0 %>% anti_join(deacc_3_5, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# 2_5 - 3_0 
deacc_diff_2 <- deacc_2_5 %>% anti_join(deacc_3_0, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# 2_0 - 2_5
deacc_diff_3 <- deacc_2_0 %>% anti_join(deacc_2_5, by = c("hardiness_delta", "hardiness", "hardiness_pct_chg", "site", "variety"))

# add the differences to a deacc_3_5 
diffs <- deacc_3_5 %>%
    mutate(threshold = "> 3.5 C")

diffs <- diffs %>%
    rbind(., deacc_diff_1 %>% mutate(threshold = "> 3.0 C (77 new)")) %>%
    rbind(., deacc_diff_2 %>% mutate(threshold = "> 2.5 C (91 new)")) %>%
    rbind(., deacc_diff_3 %>% mutate(threshold = "> 2.0 C (115 new)")) 

# making names that are too long, shorter
diffs$site <- ifelse(diffs$site == "Osoyoos, northeast", "Osoyoos, NE", diffs$site)
diffs$site <- ifelse(diffs$site == "Osoyoos, southeast", "Osoyoos, SE", diffs$site)

diffs$variety <- ifelse(diffs$variety == "Cabernet Sauvignon", "Cabernet Sauv", diffs$variety)


# plot the differences in deacclimation
add_plot <- diffs %>%
    ggplot() + 
    geom_jitter(width = 3, alpha = 0.6, aes(x = days_since_aug_1, y = hardiness, color = threshold)) +
    labs(title = "Additional Data for Differing Deacclimation Thresholds",
    subtitle = "Faceted by Season",
    y = "Lethal Temperature (C)",
    x = "Jittered Sampling Date",
    color = "Deacclimation\nThreshold") + 
    scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
    labels = c("Nov", "Dec", "Jan", "Feb", "Mar", "Apr")) + # Nov, Dec, Jan, Feb, Mar, Apr #nolint
    facet_wrap(~season)

entire_fit_MLE <- data %>%
    ggplot() +
    geom_jitter(width = 0.2, alpha = 0.5, aes(x = DD_5_delta_test, y = hardiness_delta)) +
    geom_smooth(aes(x = DD_5_delta_test, y = hardiness_delta)) 

# looking at posteriors
post_3_5 <- read.csv("../data/posterior_3_5.csv") %>% mutate(th = "> 3.5 C")
post_3_0 <- read.csv("../data/posterior_3_0.csv") %>% mutate(th = "> 3.0 C (77 new)")
post_2_5 <- read.csv("../data/posterior_2_5.csv") %>% mutate(th = "> 2.5 C (91 new)")
post_2_0 <- read.csv("../data/posterior_2_0.csv") %>% mutate(th = "> 2.0 C (115 new)")

summary(post_3_5$DD_5_delta_test)
summary(post_3_0$DD_5_delta_test)
summary(post_2_5$DD_5_delta_test)
summary(post_2_0$DD_5_delta_test)

# site and variety posterior samples per deacclimation threshold
variety_sample_3_5 <- read.csv("../data/variety_posterior_sample_3_5.csv") %>% mutate(threshold = "> 3.5 C")
site_sample_3_5 <- read.csv("../data/site_posterior_sample_3_5.csv") %>% mutate(threshold = "> 3.5 C")
variety_sample_3_0 <- read.csv("../data/variety_posterior_sample_3_0.csv") %>% mutate(threshold = "> 3.0 C (77 new)")
site_sample_3_0 <- read.csv("../data/site_posterior_sample_3_0.csv") %>% mutate(threshold = "> 3.0 C (77 new)")
variety_sample_2_5 <- read.csv("../data/variety_posterior_sample_2_5.csv") %>% mutate(threshold = "> 2.5 C (91 new)")
site_sample_2_5 <- read.csv("../data/site_posterior_sample_2_5.csv") %>% mutate(threshold = "> 2.5 C (91 new)")
variety_sample_2_0 <- read.csv("../data/variety_posterior_sample_2_0.csv") %>% mutate(threshold = "> 2.0 C (115 new)")
site_sample_2_0 <- read.csv("../data/site_posterior_sample_2_0.csv") %>% mutate(threshold = "> 2.0 C (115 new)")

# mapping names into encoded variety names
variety_posterior_samples <- rbind(variety_sample_3_5, variety_sample_3_0, variety_sample_2_5, variety_sample_2_0)
site_posterior_samples <- rbind(site_sample_3_5, site_sample_3_0, site_sample_2_5, site_sample_2_0)

variety_name_map <- data %>%
    select(variety, variety_encoded) %>%
    distinct()

site_name_map <- data %>%
    select(site, site_encoded) %>%
    distinct() 


variety_posterior_samples <- merge(variety_posterior_samples, variety_name_map, by = "variety_encoded")
site_posterior_samples <- merge(site_posterior_samples, site_name_map, by = "site_encoded")

variety_plot <- diffs %>%
    ggplot() + 
    geom_jitter(width = 3, alpha = 0.6, aes(x = DD_5_delta_test, y = hardiness_delta, color = threshold)) +
    labs(title = "Change in Lethal Temperature Threshold in Grapevines in the\nOkanagan Valley, BC 2012-2018",
    subtitle = "Faceted by Variety",
    y = "Change in Lethal Temperature (C)",
    x = "Change in GDD > 5 (jittered)",
    color = "Deacclimation\nThreshold") + 
    facet_wrap("variety")

ggsave(file="../viz/real_variety_plot.png", width=6, height=6, dpi=300)

variety_posterior_plot <- diffs %>%
    ggplot() + 
    geom_jitter(width = 3, alpha = 0.6, aes(x = DD_5_delta_test, y = hardiness_delta, color = threshold)) +
    geom_abline(aes(intercept = Intercept, slope = slope, color = threshold), data = variety_posterior_samples, alpha = 0.03) +
    labs(title = "Change in Lethal Temperature Threshold in Grapevines in the\nOkanagan Valley, BC 2012-2018",
    subtitle = "Faceted by Variety.\n50 Posterior Draws for Each Deacclimation Threshold",
    y = "Change in Lethal Temperature (C)",
    x = "Change in GDD > 5 (jittered)",
    color = "Deacclimation\nThreshold") + 
    facet_wrap("variety")

ggsave(file="../viz/real_variety_posterior_plot.png", width=6, height=6, dpi=300)


# GDD 5 vs. hardiness_delta, faceted by site
site_plot <- diffs %>%
    ggplot() + 
    geom_jitter(width = 3, alpha = 0.6, aes(x = DD_5_delta_test, y = hardiness_delta, color = variety)) +
    labs(title = "Site Dependent Intercepts",
    subtitle = "Faceted by Site",
    y = "Change in Lethal Temperature (C)",
    x = "Difference in GDD > 5 from Previous Sampling Dates",
    color = "Variety") + 
    facet_wrap("site")

# posterior draws added to site_plot
site_posterior_plot <- diffs %>%
    ggplot() + 
    geom_jitter(width = 3, alpha = 0.6, aes(x = DD_5_delta_test, y = hardiness_delta, color = threshold)) +
    geom_abline(aes(intercept = Intercept, slope = slope, color = threshold), data = variety_posterior_samples, alpha = 0.03) +
    labs(title = "Site Dependent Intercepts",
    subtitle = "Faceted by Site",
    y = "Lethal Temperature (C)",
    x = "Difference in GDD > 5 from Previous Sampling Dates",
    color = "Deacclimation\nThreshold") + 
    facet_wrap("site")

#order for presentation

# hardiness introduction
deacc_threshold 
add_plot

# model
# rstanarm: hardiness_delta ~ GDD_5_delta + (1 | variety) + (1 | site)
# math:		see OneNote

# model params
plot(fit)

variety_plot
variety_posterior_plot
site_plot
site_posterior_plot
# add in the overlaying densities

# LOO to compare with and without crossed hierarchy 

# questions
# Does anyone know how to interpret the decov() or lkj() priors for crossed hierarchies in rstanarm? I'm thoroughly confused

# future work
# expand beyond the deacclimation phase
# 