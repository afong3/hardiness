# Adam Fong
# January 28, 2022

# Creating a framework for averaging, summing, etc. of values between two dates
# NOTE: this is dependent on having no missing values in hardiness data. 
#       The previous date regardless of whether there was actually a sample is taken as the start date to filter weather data.

# VALIDATION: the png named 'weather_manipulation_validation.png' shows the true avg and sum of tmax, tmin, tavg, precip from the weather station, caluclated in excel.
# Look at the saved dataset from this file visually to compare. 

#%%
import pandas as pd
import datetime 
import numpy as np

def data_between_dates(df: pd.DataFrame, datetime_col: str, start: datetime, end: datetime) -> pd.DataFrame:
    '''
    Return a dataframe that is a chunk between the start (inclusive) and end (exclusive).
    
    df: data to be split 
    datetime_col: column in df of dtype: datetime64
    start: take data after this date (inclusive)
    end: take data before this date (exclusive)
    '''

    filtered = df[(df[datetime_col] >= start) & (df[datetime_col] < end)]
    
    return filtered

# TODO: This could be a poor implementation for edge cases. Try to come up with something else
def find_prev_date(dates, current_date):
    '''
    Return a datetime that is the first occurrence of a new date before the current date
    
    dates: pd.Series of dtype datetime
    current_date_idx: the index current date to search after 
    '''
    new_dates = dates[dates < current_date]
    last_idx = len(new_dates) - 1
    new_date = new_dates[last_idx]
    return new_date
    

if __name__ == "__main__":
    
    # load data
    data_weather = pd.read_csv("../data/penticton_weather_data.csv")
    data_hardiness = pd.read_csv("../data/hardiness_cleaned.csv")

    # create column with datetime type for easy filtering
    data_weather["datetime"] = pd.to_datetime(data_weather["Date"], format = "%d/%m/%Y")
    data_hardiness["datetime"] = pd.to_datetime(data_hardiness["datetime"], format = "%Y-%m-%d")

    # split hardiness into seasons for tidyness
    grouped = data_hardiness.groupby("season")
    seasons = [grouped.get_group(x).reset_index(drop = True) for x in grouped.groups]

   
    # get the average temperature between all samples
    # inelegant loop but such is life, this kinda seems like the most logical way to account for all the edge conditions
    # wanted to use a rolling window but it doesn't seem this is a use case
    for season in seasons:
            # instantiate lists to populate through the loop
        tmin_mean = []
        tmax_mean = []
        tavg_mean = []
        precip_summed = []
        dt = season["datetime"]
        for d in dt:
            first_date = dt[0]
            # skip the first entry bc a different model will be used for this 
            if d == first_date:
                tmin_mean.append(np.NaN)
                tmax_mean.append(np.NaN)
                tavg_mean.append(np.NaN)
                precip_summed.append(np.NaN)
            else:
                start_date = find_prev_date(dt, d)
                print(start_date)
                print(d)
                break
                filtered = data_between_dates(data_weather, "datetime", start_date, d)
                                
                tmin_mean.append(filtered["Min Temp C"].mean())
                tmax_mean.append(filtered["Max Temp C"].mean())
                tavg_mean.append(filtered["Mean Temp C"].mean())
                precip_summed.append(filtered["Total Precip (mm)"].sum())

        # save the derived parameters to the hardiness data
        season["param_tmin"] = tmin_mean
        season["param_tmax"] = tmax_mean
        season["param_tavg"] = tavg_mean
        season["param_precip"] = precip_summed

    # combine seasons into final dataset 
    cols = ["datetime", "season", "site", "variety", "param_tmin", "param_tmax", "param_tavg", "param_precip", "hardiness"]
    
    # combine all seasons into one dataframe
    for idx, season in enumerate(seasons):
        if idx == 0:
            final = season[cols]
        else:
            final = pd.concat([final, season[cols]])    
    
    
    final.to_csv("../data/hardiness_and_weather.csv")

# %%
