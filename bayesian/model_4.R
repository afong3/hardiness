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
data <- read.csv("../data/model_train.csv")
# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
# Riesling and Pinot gris are artifacts of this flaw 
deacc <- data %>% filter(deacc == 1)

fit <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 | site_encoded) + (1 | variety_encoded) + (1 + DD_5_delta_test | season), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

print(fit, digits = 4)

launch_shinystan(fit)

draws <- spread_draws(fit, `(Intercept)`, DD_5_delta_test)

# trying to get a nice plot, inspiration from https://www.tjmahr.com/plotting-partial-pooling-in-mixed-effects-models/

df_posterior <- fit %>%
    as.data.frame() %>%
    as_tibble()

df_effects <- df_posterior %>%
    mutate_at(
        .vars = vars(matches("b\\[\\(Intercept")), 
        .funs = ~ . + df_posterior$`(Intercept)`
    )
    #  %>% # adding crossed effect slopes to main slope
    # mutate_at(
    #     .vars = vars(matches("b\\[DD")),
    #     .funs = ~ . + df_posterior$DD_5_delta_test
    # )

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
    stringr::str_detect("variety") %>%
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
    mutate(variety_intercepts, slope = sample(df_effects$DD_5_delta_test, nrow(variety_intercepts), replace = TRUE)) %>%
    filter(draw %in% sample(1:length(unique(.$draw)), size = 100))

df_site_sample <- df_long_effects %>%
    filter(!is.na(Site)) %>%
    pivot_wider(names_from = Effect, values_from = Value) %>%
    select(draw, site_encoded = Site, Intercept) %>%
    mutate(slope = sample(df_effects$DD_5_delta_test, nrow(.), replace = TRUE)) %>%
    filter(draw %in% sample(1:length(unique(.$draw)), size = 50))

# merging variety and site name so they're not encoded
variety_name_map <- deacc %>%
    select(variety, variety_encoded) %>%
    distinct()

site_name_map <- deacc %>%
    select(site, site_encoded) %>%
    distinct()

df_variety_sample <- merge(df_variety_sample, variety_name_map, by = 'variety_encoded')
df_site_sample <- merge(df_site_sample, site_name_map, by.x = 'site_encoded')

# nothing drastic on this end either 
variety_partial_pooling <- deacc %>%
    ggplot(aes(x = DD_5_delta_test, y = hardiness_delta)) +
    geom_abline(
        aes(intercept = Intercept, slope = slope),
            data = df_variety_sample,
            color = "#3366FF",
            alpha = 0.1
    ) +
    geom_jitter(width = 3, alpha = 0.4, aes(color = factor(season))) +
    facet_wrap("variety") + 
    labs(title = "Grapevine Cold Hardiness Deacclimation Rate Response to Air Temperature\nin the Okanagan Valley, BC 2012 - 2018",
        subtitle = "Partial pooling across varieties.\n50 posterior draws are shown with varying slopes and intercepts by variety.\nSite effect is not shown.",
        color = "Vineyard Location",
        x = "Change GDD > 5 between Sample Dates",
        y = "Change in Lethal Temperature (C)")

# nothing drastic on this end 
site_partial_pooling <- deacc %>%
    ggplot(aes(x = DD_5_delta_test, y = hardiness_delta)) +
    geom_abline(
        aes(intercept = Intercept, slope = 0.1),
            data = df_site_sample,
            color = "#3366FF",
            alpha = 0.1
    ) +
    geom_jitter(width = 3, alpha = 0.5, aes(color = factor(season))) +
    facet_wrap("site") +
    labs(x = "Change GDD > 5 between Sample Dates",
        y = "Change in Lethal Temperature (C)")

