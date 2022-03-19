# Trying to get just deacclimation phase by filtering for negative percent change with large magnitude
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggpubr) # for making grids of ggplots

# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# filter for when deacclimation starts, not including Riesling because it's behaving very unexpectedly
deacc <- data %>% filter(deacc == 1)

deacc$sunlight_14_adjusted <- deacc$sunlight_14_total - min(deacc$sunlight_14_total)

# the main photoperiod effect is changed by how much the max temperatures
p1 <- deacc %>%
filter(variety != "Riesling", variety != "Pinot gris") %>%
ggplot() +
geom_point(aes(x = sunlight_14_adjusted, y = hardiness_delta, color = tmax_delta_14)) + 
scale_color_gradient(low = "#0c2abf", high = "#e01e1e") + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days))") + 
ylab("Lethal Temp Change (C)") +
labs(title = "Real Data", subtitle = "hardiness_delta ~ photoperiod + (temp_delta | variety)")

p2 <- deacc %>%
filter(variety != "Riesling", variety != "Pinot gris") %>%
ggplot() +
geom_point(aes(x = sunlight_14_adjusted, y = hardiness_delta, color = factor(season))) + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days))") + 
ylab("Lethal Temp Change (C)")

p3 <- deacc %>%
filter(variety != "Riesling", variety != "Pinot gris") %>%
ggplot() +
geom_point(aes(x = sunlight_14_adjusted, y = hardiness_delta, color = tmin_delta_14)) + 
scale_color_gradient(low = "#bf0c89", high = "#1ee03b") + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days))") + 
ylab("Lethal Temp Change (C)")


figure <- ggarrange(p1, p3, p2, ncol = 1)

annotate_figure(figure, 
top = "Visualizing Covariates for Intuitive Explanation of Response\n")

# hardiness delta vs. photoperiod and tmin_delta_14

deacc %>%
filter(variety != "Riesling", variety != "Pinot gris") %>%
ggplot() +
geom_point(aes(x = sunlight_14_adjusted, y = hardiness_delta, color = tmin_delta_14)) + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days))") + 
ylab("Lethal Temp Change (C)") + 
scale_color_gradient(low = "#bf0c89", high = "#1ee03b") + 
facet_wrap(~season) +
labs(title = "Deacclimation Change in Hardiness \nby Season as a Function of Photoperiod \nand Change in Minimum Temperature")


# hardiness delta vs. photoperiod and tmin_delta_14

deacc %>%
filter(variety != "Riesling", variety != "Pinot gris") %>%
ggplot() +
geom_point(aes(x = sunlight_14_adjusted, y = hardiness_delta, color = tmax_delta_14)) + 
xlab("Increase in Daylight Hours from Winter Solstice (total in 14 days))") + 
ylab("Lethal Temp Change (C)") + 
scale_color_gradient(low = "#0c2abf", high = "#e01e1e") + 
facet_wrap(~season) +
labs(title = "Deacclimation Change in Hardiness \by Season as a Function of Photoperiod \nand Change in Maximum Temperature")



# seasonal plots of hardiness and deacclimation 

data %>%
filter() %>%
ggplot() + 
geom_point(aes(x = days_since_aug_1, y = hardiness, color = factor(deacc)))+
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("N", "D", "J", "F", "M", "A")) +# Nov, Dec, Jan, Feb, Mar, Apr #nolint
facet_wrap(~season) + 
labs(title = "Deacclimation Across all Varieties Separated by Season", y = "Lethal Temperature (C)", x = "Month")

# varietal plots of hardiness and deacclimation pooled by season
data %>%
filter() %>%
ggplot() + 
geom_point(aes(x = days_since_aug_1, y = hardiness, color = factor(deacc)))+
scale_x_continuous(breaks = c(91, 122, 153, 184, 214, 245),
labels = c("N", "D", "J", "F", "M", "A")) +# Nov, Dec, Jan, Feb, Mar, Apr #nolint
facet_wrap(~variety) + 
labs(title = "Deacclimation Across all Seasons Separated by Variety", y = "Lethal Temperature (C)")
