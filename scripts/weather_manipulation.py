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

def days_from_date(dt, target):
    '''
    Find how many days dt is from target.
    
    dt: datetime
    target: datetime (currently want August 1st)
    '''
    timedelta = dt - target
    days = timedelta.days
    
    return(days)

def get_aug_1st(sample_date):
    '''
    Return the correct datetime of august 1st as it gets funky when the year changes but within the same growing season
    sample_date: datetime
    '''
    if sample_date.month > 8:
        # use the same year as this 
        aug_first = pd.to_datetime("1-8-{year}".format(year = sample_date.year), format = "%d-%m-%Y")
        
        return aug_first
    else:
        # use the previous year 
        aug_first = pd.to_datetime("1-8-{year}".format(year = sample_date.year - 1), format = "%d-%m-%Y")

        return aug_first

def get_cumulative_temp_swings(weather):
    '''
    Return the cumulative temperature swings between tmin and tmax between days
    weather: pd.DataFrame
    '''
    
    temp_swings = weather["Max Temp C"] - weather["Min Temp C"]
    return temp_swings.sum()

def get_per_change(weather, metric):
    '''
    Return the percent change between this and the previous sample
    weather: pd.DataFrame of weather
    metric: string for the column name aka weather metric
    '''
    
    first_date = weather["datetime"][0]
    # same number of plants exist throughout the entire season, get this number
    n_plants = weather[weather["datetime"] == first_date].shape[0] 
    
    prev_weather = weather[metric].shift(n_plants)
    
    
    per_change = (weather[metric] - prev_weather) / prev_weather
    
    return per_change


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
        
        ### 1 ### taking tmin, tmax, tavg, precip BETWEEN sample dates, not necessarily 14 days... 
        tmin_mean = []
        tmax_mean = []
        tavg_mean = []
        precip_summed = []
                
        ### 2 ###
        # taking tmin, tmax, tavg, precip 
        tmin_tminus1 = []
        tmin_tminus2 = []
        tmax_tminus1 = []
        tmax_tminus2 = []
        tavg_tminus1 = []
        tavg_tminus2 = []
        precip_tminus1 = []
        precip_tminus2 = []
        
        ### 3 ###
        # how many days has it been since Aug 1st - attempting to include acclimation period in model
        days_from_aug_first = []
        
        ### 4 ###
        # cumulative temperature swings
        temp_swing_cumulative = []
        
        ### 5 ###
        # percent change in temperature between sampling dates
        tmin_per_change = []
        tmax_per_change = []
        tavg_per_change = []
        precip_per_change = []
        swing_per_change = []
        ### 5 ### 
        # taking tmin, tmax, tavg, precip 14 days before sample day

        dt = season["datetime"]
        for sample_date in dt:
            first_date = dt[0]
            # skip the first entry bc a different model will be used for this 
            if sample_date == first_date:
                ### 1 ###
                tmin_mean.append(np.NaN)
                tmax_mean.append(np.NaN)
                tavg_mean.append(np.NaN)
                precip_summed.append(np.NaN)
                ### 2 ###
                tmin_tminus1.append(np.NaN)
                tmin_tminus2.append(np.NaN)
                tmax_tminus1.append(np.NaN)
                tmax_tminus2.append(np.NaN)
                tavg_tminus1.append(np.NaN)
                tavg_tminus2.append(np.NaN)
                precip_tminus1.append(np.NaN)
                precip_tminus2.append(np.NaN)
                
                ### 3 ###
                days_from_aug_first.append(np.NaN)
                
                ### 4 ### 
                temp_swing_cumulative.append(np.NaN)
                
            else:
                start_date = find_prev_date(dt, sample_date)

                filtered = data_between_dates(data_weather, "datetime", start_date, sample_date).reset_index(drop = True)
                
                ### 1 ###
                tmin_mean.append(filtered["Min Temp C"].mean())
                tmax_mean.append(filtered["Max Temp C"].mean())
                tavg_mean.append(filtered["Mean Temp C"].mean())
                precip_summed.append(filtered["Total Precip (mm)"].sum())
                
                ### 2 ###
                # get the previous days tmin, tmax, tavg
                prev_day = filtered.shape[0] - 1
                two_days_prior = filtered.shape[0] - 2
                                
                tmin_tminus1.append(filtered["Min Temp C"][prev_day])
                tmin_tminus2.append(filtered["Min Temp C"][two_days_prior])
                tmax_tminus1.append(filtered["Max Temp C"][prev_day])
                tmax_tminus2.append(filtered["Max Temp C"][two_days_prior])
                tavg_tminus1.append(filtered["Mean Temp C"][prev_day])
                tavg_tminus2.append(filtered["Mean Temp C"][two_days_prior])
                precip_tminus1.append(filtered["Total Precip (mm)"][prev_day])
                precip_tminus2.append(filtered["Total Precip (mm)"][two_days_prior])
                
                ### 3 ###
                # get how many days this sample is from August 1st
                aug1st = get_aug_1st(sample_date)
                days_from_aug_first.append(days_from_date(sample_date, aug1st))
                
                ### 4 ###
                # cumulative temperature swings
                temp_swing_cumulative.append(get_cumulative_temp_swings(filtered))
                

        # save the derived parameters to the hardiness data
        ### 1 ###
        season["tmin"] = tmin_mean
        season["tmax"] = tmax_mean
        season["tavg"] = tavg_mean
        season["precip"] = precip_summed
        ### 2 ###
        season["tmin_t-1"] = tmin_tminus1
        season["tmin_t-2"] = tmin_tminus2
        season["tmax_t-1"] = tmax_tminus1
        season["tmax_t-2"] = tmax_tminus2
        season["tmavg_t-1"] = tavg_tminus1
        season["tmavg_t-2"] = tavg_tminus2
        season["precip_t-1"] = precip_tminus1
        season["precip_t-2"] = precip_tminus2
        ### 3 ###
        season["days_from_aug_1"] = days_from_aug_first
        ### 4 ###
        season["temp_swing_cumulative"] = temp_swing_cumulative
        
        ### 5 ###
        # change between the previous sample date and this one 
        season["tmin_per_change"] = (get_per_change(season, "tmin"))
        season["tmax_per_change"] = (get_per_change(season, "tmax"))
        season["tavg_per_change"] = (get_per_change(season, "tavg"))
        season["precip_per_change"] = (get_per_change(season, "precip"))                       
        season["swing_per_change"] = (get_per_change(season, "temp_swing_cumulative"))
    
    # get rid of 'Unnamed' columns
    cols = seasons[0].columns.tolist()
    cols_final = seasons[0].columns.copy().tolist()
    for col_name in cols:
        if ("Unnamed" in col_name):
            print(col_name)
            cols_final.remove(col_name)
            
    # concatentate into final dataframe
    for idx, season in enumerate(seasons):
        if idx == 0:
            final = season[cols_final]
        else:
            final = pd.concat([final, season[cols_final]])    
    
    
    final.to_csv("../data/hardiness_and_weather.csv")

# %%
