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
    data_hardiness = pd.read_csv("../data/hardiness_cleaned.csv")
    data_hardiness["datetime"] = pd.to_datetime(data_hardiness["datetime"])
    
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
        season["hardiness_pct_chg"] = season["hardiness_delta"] / season["hardiness_t-1"]
        
        # making deacclimation column for binary state
        # enters deacclimation after the first occurence of a change in hardiness greater than the threshold
        # deacclimation is considered for each individual variety as some varieties deacclimate earlier than others
        ## i.e. is this sample in deacclmation phase or not 
        
        season["deacc"] = 0 # default assumption is that a sample is not in deacclimation
        
        vars = season["variety"]
        earliest_month = 2
        delta_threshold = 3.25
        
        for v in vars:
            # not saving season[season["variety"] == v] as a variable because we need to reassign the 'season' reference location
            conditional = (season["variety"] == v) & (season["month"] >= earliest_month)
            
            deacc_dates_bool = season[conditional]["hardiness_delta"] > delta_threshold # per variety
            deacc_dates = season[conditional][season["variety"] == v][deacc_dates_bool].reset_index()
            
            if len(deacc_dates) > 0:
                deacc_start_date = deacc_dates.sort_values("datetime", ascending=True)["datetime"][0] # get the earliest date of threshold 
            
                season.loc[(season["variety"] == v) & (season["datetime"] >= deacc_start_date), "deacc"] = 1 # all dates past the first date where threshold was broken gets assigned a 1
            else:
                print("No deacclimation for {variety}, in season {season}".format(variety = v, season = season["season"][0]))
                continue
            
            


    # combine seasons into final dataset 
    cols = seasons[0].columns.tolist()
    cols_final = seasons[0].columns.copy().tolist()
    
    # remove 'Unnamed' columns so that merging goes smoothly
    for col_name in cols:
        if ("Unnamed" in col_name):
            print(col_name)
            cols_final.remove(col_name)
            
    # iterate through seasons and concatenate into a final dataframe
    for idx, season in enumerate(seasons):
        if idx == 0:
            final = season[cols_final]
        else:
            final = pd.concat([final, season[cols_final]])    
        
    # adding plant id per unique combination of site, variety, 
    
    
    # adding label encoded variety and site
    le_site = preprocessing.LabelEncoder()
    le_variety = preprocessing.LabelEncoder()
    site_encoded = le_site.fit_transform(final["site"])
    variety_encoded = le_variety.fit_transform(final["variety"])
    
    final["site_encoded"] = site_encoded
    final["variety_encoded"] = variety_encoded
    
    final.to_csv("../data/targets.csv")
# %%
