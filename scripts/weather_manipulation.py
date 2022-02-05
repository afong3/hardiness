# January 31, 2022

# This script takes all of the metrics from weather manipulation and calculates the values between and on sample dates.
# The data that will be generated is necessary for plotting models.
#%%
import pandas as pd
import numpy as np
import astral
from astral.sun import sun 

def load_data():
    # load raw weather data
    weather = pd.read_csv("../data/penticton_weather_data.csv", parse_dates={"datetime": ["Date"]}, dayfirst = True)

    ## seasons are between for now lets just say September 1st and May 1st
    # the last recorded data date in this file is April 16, 2019 
    s_start_month = 9 #inclusive so that we can do previous 14 day averages and still capture all of october

    s_end_month = 5 # exclusive

    # rename ugly names
    weather = weather.rename(columns= {"Min Temp C": "tmin", "Max Temp C": "tmax", "Mean Temp C": "tmean", "Total Precip (mm)": "precip"})
    
    # filter out non dormant or shoulder seasons
    weather_filtered = weather[(weather["Month"] < s_end_month) | (weather["Month"] >= s_start_month)].reset_index(drop = True)

    # make precipitation 0 if na
    weather_filtered["precip"] = weather["precip"].fillna(0)

    return weather_filtered

def create_seasons(data):
    ### Make a 'season' column to make for easier groupby's in the future

    # a season extends from september, year to may, year+1
    years_unique = data["Year"].unique()

    # brute force :(
    season = [] # empty list to populate in for loop
    for s, year in enumerate(years_unique):
        if (year == years_unique[len(years_unique) - 1]): # end before calling index out of bounds 
            continue
        season_start = pd.to_datetime("09-01-{}".format(year), format = "%m-%d-%Y")
        season_end = pd.to_datetime("05-01-{}".format(year+1), format = "%m-%d-%Y")
        
        season_length = data[(data["datetime"] >= season_start) & (data["datetime"] < season_end)].shape[0]
        season.extend([s+1] * season_length)

    data["season"] = season
    
    return data

def calculate_sunlight(date):
    # theoretical maximum light in a day
    # lat long in decimal is - 40.76, 73.984 based on 
    # this tool https://www.sunearthtools.com/dp/tools/conversion.php?lang=en
    # and Penticton Weather Station A location in decimal degrees https://climate.weather.gc.ca/climate_data/daily_data_e.html?StationID=50269 
    station = astral.LocationInfo("Penticton", "Canada", "North America", 40.76, 73.984)
    s = sun(station.observer, date = date)
    
    sunlight_hours = (s["sunset"] - s["sunrise"]).seconds / 60 / 60
    
    return sunlight_hours

if __name__ == "__main__":
    # load data
    weather = load_data()
    
    # create a season column
    weather = create_seasons(weather)
    
    # split hardiness into seasons for tidyness
    grouped = weather.groupby("season")
    seasons = [grouped.get_group(season).reset_index(drop = True) for season in grouped.groups]

    # calculate all the metrics so that you can merge weather data and hardiness data
   
    # NOTE: shifting by 2 after doing a rolling average achieves not having the current data included in the window
    # index 6 should have the value of 9.0 after the rolling sum to have only summed the previous 5 values
    # l = [1,2,3]*5
    # test = pd.Series(l)
    # test.rolling(5).sum().shift(2)
    
    # average of the previous 14 days of a metric
    weather["tmin_avg_14"] = weather["tmin"].rolling(14).mean().shift(2)
    weather["tmax_avg_14"] = weather["tmax"].rolling(14).mean().shift(2)
    weather["tmean_avg_14"] = weather["tmean"].rolling(14).mean().shift(2)
    weather["precip_total_14"] = weather["precip"].rolling(14).sum().shift(2)
    
    # average of the previous 7 days of a metric
    weather["tmin_avg_7"] = weather["tmin"].rolling(7).mean().shift(2)
    weather["tmax_avg_7"] = weather["tmax"].rolling(7).mean().shift(2)
    weather["tmean_avg_7"] = weather["tmean"].rolling(7).mean().shift(2)
    weather["precip_total_7"] = weather["precip"].rolling(7).sum().shift(2)
    
    # temperature swings 
    weather["temp_swing"] = weather["tmax"] - weather["tmin"] 
    
    # cumulative temp swings of the past 14 and 7 days
    weather["temp_swing_cumulative_14"] = weather["temp_swing"].shift(1).rolling(14).sum()
    weather["temp_swing_cumulative_7"] = weather["temp_swing"].shift(1).rolling(7).sum()
    
    # day - 1 of tmin, tmax, tmean, precip
    weather["tmin_t-1"] = weather["tmin"].shift(1)
    weather["tmax_t-1"] = weather["tmax"].shift(1)
    weather["tmean_t-1"] = weather["tmean"].shift(1)
    weather["precip_t-1"] = weather["precip"].shift(1)
    
    # day - 2 of tmin, tmax, tmean, precip
    weather["tmin_t-2"] = weather["tmin"].shift(2)
    weather["tmax_t-2"] = weather["tmax"].shift(2)
    weather["tmean_t-2"] = weather["tmean"].shift(2)
    weather["precip_t-2"] = weather["precip"].shift(2)    # days since august 1st of this season 
    
    # calculate amount of maximum daylight in a day
    weather["sunlight"] = weather["datetime"].apply(calculate_sunlight)
    
    # total sunlight in previous 14 and 7 days
    weather["sunlight_14_total"] = weather["sunlight"].rolling(14).sum().shift(2)

    weather["sunlight_7_total"] = weather["sunlight"].rolling(7).sum().shift(2)
    
    # chilling degree days: thermal time below a threshold temperature T_th
    th_c = 10 # from Fergusen et al, threshold temperature common to all genotypes
    
    weather["DD"] = weather["tmean"] - th_c
    
    # check Fergusen et al. to find the endo dormancy boundary for different varieties
    weather["DD_sum"] = weather.groupby(["season"])["DD"].cumsum()
    
    # now that we have the rolling metrics complete, let's start at october 1st
    final = weather[weather["Month"] != 9]
    
    final.to_csv("../data/predictors.csv")