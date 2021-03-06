# fitting the model that was successful on fake data in simulation_gdd_hardiness_delta.R

library(rstanarm)
library(ggplot2)
library(rstan)
library(tidybayes)
library(modelr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(bayesplot)

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

deacc_threshold = "2_0" # change me to "2_0", "2_5", "3_0", or "3_5"

# load hardiness data
data <- read.csv(paste0("../data/model_train_", deacc_threshold, ".csv"))
# filter for when deacclimation starts, not including Riesling and Pinot gris because 
# my deacclimation logic is flawed but fixing it is not the most important task as of now
# Riesling and Pinot gris are artifacts of this flaw 
deacc <- data %>% filter(deacc == 1)

fit <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 | site_encoded) + (1 | variety_encoded), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

fit_only_variety <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 | variety_encoded), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

fit_only_variety_interaction <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 + DD_5_delta_test| variety_encoded), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

fit_only_site <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 | site_encoded), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

fit_only_season <- stan_glmer(hardiness_delta ~ DD_5_delta_test + (1 | season), data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1),
        prior_covariance = decov(shape = 1, 
                                scale = 1)
)

fit_complete_pool <- stan_glm(hardiness_delta ~ DD_5_delta_test, data = deacc,
        prior = normal(0.2, 0.2),
        prior_intercept = normal(2, 1.5),
        prior_aux = exponential(1)
)

print(fit, digits = 4)

draws <- spread_draws(fit, `(Intercept)`, DD_5_delta_test)

# saving draws
write.csv(draws, paste0("../data/posterior_", deacc_threshold,".csv"))


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

write.csv(df_variety_sample, paste0("../data/variety_posterior_sample_", deacc_threshold,".csv"))
write.csv(df_site_sample, paste0("../data/site_posterior_sample_", deacc_threshold,".csv"))
# save 

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
    geom_jitter(width = 3, alpha = 0.4, aes(color = site)) +
    facet_wrap("variety") + 
    labs(title = "Grapevine Cold Hardiness Deacclimation Rate Response to Air Temperature\nin the Okanagan Valley, BC 2012 - 2018",
        subtitle = "Partial pooling across varieties.\n50 posterior draws are shown with varying slopes and intercepts by variety.\nSite effect is not shown.",
        color = "Vineyard",
        x = "Change in GDD > 5",
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

fit_loo <- loo(fit)
fit_complete_pool_loo <- loo(fit_complete_pool)
fit_only_variety_loo <- loo(fit_only_variety)
fit_only_site_loo <- loo(fit_only_site)
fit_only_season_loo <- loo(fit_only_season)
fit_only_variety_interaction_loo <- loo(fit_only_variety_interaction)

loo_compare(fit_loo, fit_complete_pool_loo, fit_only_variety_loo, fit_only_site_loo, fit_only_season_loo, fit_only_variety_interaction_loo)

post_vs_prior_variety <- posterior_vs_prior(fit, regex_par = 'va') + 
    ggplot2::geom_hline(yintercept = 0, size = 0.3, linetype = 3) +
    ggplot2::coord_flip() +
    ggplot2::ggtitle("Comparing the Prior and Posterior for Variety Level") +
    theme(legend.position="none")
    

ggsave(file="../viz/post_vs_prior_variety.png", width=5.5, height=4, dpi=300)

post_vs_prior_site <- posterior_vs_prior(fit, regex_par = 'sit') + 
    ggplot2::geom_hline(yintercept = 0, size = 0.3, linetype = 3) +
    ggplot2::coord_flip() +
    ggplot2::ggtitle("Comparing the Prior and Posterior for Site Level") +
    theme(legend.position="none")

ggsave(file="../viz/post_vs_prior_site.png", width=5, height=4, dpi=300)

post_vs_prior_beta_and_alpha_grand <- posterior_vs_prior(fit, c("alpha", "beta", "sigma")) + 
    ggplot2::geom_hline(yintercept = 0, size = 0.3, linetype = 3) +
    ggplot2::coord_flip() +
    ggplot2::ggtitle("Comparing the Prior and Posterior for Beta and Grand Alpha") 

ggsave(file="../viz/post_vs_prior_grand.png", width=12, height=4, dpi=300)

hist_facet_ppc <- ppc_hist(y = deacc$hardiness_delta[!is.na(deacc$hardiness_delta)], 
                    yrep = posterior_predict(fit, draws = 8)) +
                    labs(title = "Histogram PPC")

ggsave(file="../viz/ppc_hist.png", width=6, height=7, dpi=300)
 
dens_overlay <- pp_check(fit) +
    labs(title = "Density Overlay PPC")
ggsave(file="../viz/ppc_dens_overlay.png", width=6, height=7, dpi=300)


ppc_scatter_avg(y = deacc$hardiness_delta[!is.na(deacc$hardiness_delta)], yrep = posterior_predict(fit, draws = 5))

