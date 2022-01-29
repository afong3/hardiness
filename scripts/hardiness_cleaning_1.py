# Adam Fong
# January 28, 2022

# getting rid of the "Average Hardiness" ish entries in hardiness_cleaned.csv 
#%%
import pandas as pd

data_hardiness = pd.read_csv("../data/hardiness_cleaned.csv")

average_removed = data_hardiness[data_hardiness["site"] != "Average Bud Hardiness (all sites, all varieties)"].reset_index(drop=True)

average_removed.to_csv("../data/hardiness_cleaned_1.csv")