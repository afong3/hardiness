# Adam Fong
# January 29, 2022

# Goal here is to elegantly find the change in hardiness between each sample 
# The solution is based on the assumption that you didn't drop rows without hardiness!!!
# Therefore, there will need to be some imputation. 

#%%
import pandas as pd
import datetime 
import numpy as np
from sklearn import preprocessing


if __name__ == "__main__":
    
    # load data
    data_hardiness = pd.read_csv("../data/hardiness_and_weather.csv")

    # split hardiness into seasons for tidyness
    grouped = data_hardiness.groupby("season")
    seasons = [grouped.get_group(x).reset_index(drop = True) for x in grouped.groups]

   
    # in each season, calculate the difference in hardiness between plants
    # this is based on the assumption that there are an equal number of recordings in each dataframe per unique plant
    for season in seasons:
        
        dt = season["datetime"]
        first_date = dt[0]
        season_n_plants = season[season["datetime"] == first_date].shape[0]

        # shifting the hardiness values down the number of unique plants in a season
        season["hardiness_t-1"] = season["hardiness"].shift(season_n_plants)
        season["hardiness_delta"] = season["hardiness"] - season["hardiness_t-1"]
        season["hardiness_delta_abs"] = season["hardiness_delta"].abs()

    # combine seasons into final dataset 
    cols = seasons[0].columns.tolist()
    cols_final = seasons[0].columns.copy().tolist()
    for col_name in cols:
        if ("Unnamed" in col_name):
            print(col_name)
            cols_final.remove(col_name)
            
    
    for idx, season in enumerate(seasons):
        if idx == 0:
            final = season[cols_final]
        else:
            final = pd.concat([final, season[cols_final]])    
    
    # adding label encoded variety and site
    le_site = preprocessing.LabelEncoder()
    le_variety = preprocessing.LabelEncoder()
    site_encoded = le_site.fit_transform(final["site"])
    variety_encoded = le_variety.fit_transform(final["variety"])
    
    final["site_encoded"] = site_encoded
    final["variety_encoded"] = variety_encoded
    
    
    
    final.to_csv("../data/model_inputs.csv")
# %%
