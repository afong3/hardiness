#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import datetime
from sklearn.impute import SimpleImputer 

# load hardiness data into a dictionary and compare their column names  
hardiness = {}
for root, dirs, files in os.walk("c:/code/python/hardinessPrediction/data/"):
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


# Hardiness Data Cleaning

def cleanHardinessData(dataset, index):
    sites_for_melting = ["2012 - 2013", "2013 - 2014", "2014 - 2015",
    "2015 - 2016", "2016 - 2017", "2017 - 2018", "2018 - 2019"]

    data = dataset

    dataMelted = data.melt(id_vars = [sites_for_melting[index], "Variety"])
    dataMelted["Site"] = dataMelted[sites_for_melting[index]]

    dataMelted[['DayOfMonth', 'Month_str']] = dataMelted['variable'].str.split('-', expand = True)

    twoYears = data.columns[0].split(' - ')
    firstYear = int(twoYears[0])
    secondYear = int(twoYears[1])

    mapMonths = {"Oct": 10, "Nov": 11, "Dec": 12, 
    "Jan": 1, "Feb": 2, "Mar":3, "Apr": 4}

    mapYears = {"Oct": firstYear, "Nov": firstYear, "Dec": firstYear, 
    "Jan": secondYear, "Feb": secondYear, "Mar":secondYear, "Apr": secondYear}

    ###converting the ugly formatting of data collection into julian days 
    dataMelted["Month_num"] = dataMelted["Month_str"].map(mapMonths)
    dataMelted["Year"] = dataMelted["Month_str"].map(mapYears)
    dataMelted["datetime"] = pd.to_datetime(dict(year = dataMelted['Year'], 
    month = dataMelted["Month_num"], day = dataMelted["DayOfMonth"]))
    dataMelted["julian_day"] = dataMelted["datetime"].dt.strftime('%j').astype("int")
    dataMelted['Hardiness'] = dataMelted['value']
    dataMelted["julian_day"] = dataMelted["julian_day"].astype("int")

    ###keep columns we want

    ###remove data without hardiness values
    dataMelted = dataMelted[-np.isnan(dataMelted["Hardiness"])]

    # add day of growing season to dataMelted
    dataMelted['growDay'] = dataMelted['julian_day'].map(julianDayMap)


    #####For the 2012 to 2013 growing season

    dataMelted = dataMelted[['Site', 'Variety', 'Hardiness','datetime', 'Month_num', 'Year', 'julian_day', 'growDay']]

    

    return dataMelted

dataHardiness = hardiness["budhardiness2012to13.csv"]
dataHardiness = dataHardiness.melt(id_vars = ["2012 - 2013", "Variety"])
dataHardiness['Site'] = dataHardiness["2012 - 2013"]

dataHardiness[['DayOfMonth', 'Month_str']] = dataHardiness['variable'].str.split('-', expand = True)

mapMonths = {"Nov": 11, "Dec": 12, "Jan": 1, "Feb": 2, "Mar":3, "Apr": 4}
mapYears = {"Nov": 2012, "Dec": 2012, "Jan": 2013, "Feb": 2013, "Mar":2013, "Apr": 2013}

###converting the ugly formatting of data collection into julian days 
dataHardiness["Month_num"] = dataHardiness["Month_str"].map(mapMonths)
dataHardiness["Year"] = dataHardiness["Month_str"].map(mapYears)
dataHardiness["datetime"] = pd.to_datetime(dict(year = dataHardiness['Year'], month = dataHardiness["Month_num"], day = dataHardiness["DayOfMonth"]))
dataHardiness["julian_day"] = dataHardiness["datetime"].dt.strftime('%j').astype("int")
dataHardiness['Hardiness'] = dataHardiness['value']
dataHardiness["julian_day"] = dataHardiness["julian_day"].astype("int")

###keep columns we want

###remove data without hardiness values
dataHardiness = dataHardiness[-np.isnan(dataHardiness["Hardiness"])]

# add day of growing season to dataHardiness
dataHardiness['growDay'] = dataHardiness['julian_day'].map(julianDayMap)


#####For the 2012 to 2013 growing season

dataHardiness = dataHardiness[['Site', 'Variety', 'Hardiness','datetime', 'Month_num', 'Year', 'julian_day', 'growDay']]



dataHardiness = dataHardiness.reset_index()

# will fail if this the cleaned file has already been put into the destination folder.
for i, file in enumerate(hardiness):
    if i == 0:
        restOfHardiness = cleanHardinessData(hardiness[file], i)
    # put the for loop outside of the definition so we can debug where the issues in data are 
    else:
        restOfHardiness = restOfHardiness.append(cleanHardinessData(hardiness[file], i), ignore_index = True)

dataHardiness = dataHardiness.drop(['index', 'growDay'], axis = 1)
restOfHardiness = restOfHardiness.drop(['growDay'], axis = 1)


completeData = pd.concat([dataHardiness, restOfHardiness], axis = 0)

completeData.to_csv('hardiness_cleaned.csv')
# %%
