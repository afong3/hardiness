#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import datetime
from sklearn.impute import SimpleImputer 


# Hardiness Data Cleaning

def clean_data(data, index):
    sites_for_melting = ["2012 - 2013", "2013 - 2014", "2014 - 2015",
    "2015 - 2016", "2016 - 2017", "2017 - 2018", "2018 - 2019"]

    data_melted = data.melt(id_vars = [sites_for_melting[index], "Variety"])
    data_melted['site'] = data_melted[sites_for_melting[index]]

    data_melted[['DayOfMonth', 'Month_str']] = data_melted['variable'].str.split('-', expand = True)

    twoYears = data.columns[0].split(' - ')
    firstYear = int(twoYears[0])
    secondYear = int(twoYears[1])

    mapMonths = {"Oct": 10, "Nov": 11, "Dec": 12, 
    "Jan": 1, "Feb": 2, "Mar":3, "Apr": 4}

    mapYears = {"Oct": firstYear, "Nov": firstYear, "Dec": firstYear, 
    "Jan": secondYear, "Feb": secondYear, "Mar":secondYear, "Apr": secondYear}

    ###converting the ugly formatting of data collection into julian days 
    data_melted["month"] = data_melted["Month_str"].map(mapMonths)
    data_melted['year'] = data_melted["Month_str"].map(mapYears)
    data_melted["datetime"] = pd.to_datetime(dict(year = data_melted['year'], 
    month = data_melted["month"], day = data_melted["DayOfMonth"]))
    data_melted["julian_day"] = data_melted["datetime"].dt.strftime('%j').astype("int")
    data_melted['hardiness'] = data_melted['value']
    data_melted["julian_day"] = data_melted["julian_day"].astype("int")

    # add season for easy DataFrame.groupby() methods
    data_melted["season"] = [index + 1] * data_melted.shape[0]

    # make 'Variety' col 'variety'
    data_melted["variety"] = data_melted["Variety"]
    
    #####For the 2012 to 2013 growing season

    data_melted = data_melted[['site', 'variety', 'month', 'year','datetime', 'julian_day', 'season', 'hardiness']]


    return data_melted

if __name__ == "__main__":
    # load hardiness data into a dictionary and compare their column names  
    hardiness = {}
    for root, dirs, files in os.walk("../data/hardiness_original/"):
        for file in files:
            if("hardi" in file):
                hardiness[file] = pd.read_csv(root + file)


    # for index, key in enumerate(hardiness):
    #     print(hardiness[key].shape)

    # OK I think I'm a bit in over my head if I want to combine data for every year right now
    # I should try to do this quick for one year and see what's up. Extrapolating over mulitple years sounds harder 

    # map for a julian day to a day of growing season 
    julianDayMap = {}
    julianDayMapKeys = np.arange(0, 257, 1)
    julianDayMapValues = np.concatenate([np.arange(230, 366, 1), np.arange(0, 121, 1)])

    for key in julianDayMapKeys:

        julianDayMap[julianDayMapValues[key]] = key




    # will fail if this the cleaned file has already been put into the destination folder.
    # combine into one 
    for i, file in enumerate(hardiness):
        if i == 0:
            final = clean_data(hardiness[file], i)
        # put the for loop outside of the definition so we can debug where the issues in data are 
        else:
            final = pd.concat([final, clean_data(hardiness[file], i)], ignore_index = True)

    final.to_csv('../data/hardiness_cleaned.csv')
    # %%
