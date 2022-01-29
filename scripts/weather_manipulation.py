# Adam Fong
# January 28, 2022

# Creating a framework for averaging, summing, etc. of values between two dates
#%%
import pandas as pd
import datetime 

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

if __name__ == "__main__":
    
    # load data
    data_weather = pd.read_csv("../data/penticton_weather_data.csv")
    data_hardiness = pd.read_csv("../data/hardiness_cleaned.csv")

    # create column with datetime type for easy filtering
    data_weather["datetime"] = pd.to_datetime(data_weather["Date"], format = "%d/%m/%Y")
    data_hardiness["datetime"] = pd.to_datetime(data_hardiness["datetime"], format = "%Y-%m-%d")

    # split hardiness into seasons for tidyness
    grouped = data_hardiness.groupby("season")
    seasons = [grouped.get_group(x) for x in grouped.groups]

    # get the average temperature between all 
# %%
