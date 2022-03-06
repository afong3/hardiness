# Trying to get just deacclimation phase by filtering for negative percent change with large magnitude
library(tidyr)
library(dplyr)
# setting wd to ./bayesian to adhere to analogue to ML wd
setwd("c:/users/adamf/onedrive/documents/code/hardiness/bayesian")

# load hardiness data
data <- read.csv("../data/model_train.csv")

# deacclimation can be estimated with negative percent change and large magnitude. Also filter out anomalies that are in 
# in late winter
pct_threshold = 0.1 # 0.075 results in 858 rows, 0.1 results in 734 rows
deacc <- data[(data["hardiness_pct_chg"] < 0) & 
        (abs(data["hardiness_pct_chg"]) > pct_threshold) & 
        (data["month"] < 11),] %>%
        drop_na() 

plot(hardiness_delta ~ tmax_avg_14, data = deacc)
