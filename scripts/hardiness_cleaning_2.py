# Adam Fong
# January 28, 2022

# Taking care of data entry errors with variety and site

# Taking care of shiraz naming and sauv blanc naming
#%%
import pandas as pd

data = pd.read_csv("../data/hardiness_cleaned.csv")
varieties = data["variety"]
varieties = pd.Series(varieties)
varieties.loc[varieties == "Shiraz cl.174"] = "Shiraz"
varieties.loc[varieties == "Sauv blanc"] = "Sauvignon blanc"
varieties.value_counts()

# taking care of similar, but still different site names
sites = data["site"]

## Naramata bench and Naramata Bench
sites.loc[sites == "Naramata bench"] = "Naramata Bench"
## Osoyoos northeast and Osoyoos, northeast
sites.loc[sites == "Osoyoos northeast"] = "Osoyoos, northeast"
## etc.
sites.loc[sites == "Oliver east"] = "Oliver, east"
sites.loc[sites == "Osoyoos west"] = "Osoyoos, west"

sites.value_counts()

data["site"] = sites
data["variety"] = varieties

data.to_csv("../data/hardiness_cleaned.csv")