# Feb 1st 2022

# Merge the predictors dataset and targets dataset for a training set 
#%%
import pandas as pd

def load_data():
    df1 = pd.read_csv("../data/predictors.csv")
    df2 = pd.read_csv("../data/targets_3_0.csv")
    
    return df1, df2


if __name__ == "__main__":
    predictors, targets = load_data()
    
    merged = predictors.merge(targets, how = "inner", on = "datetime", )
    # rename season_x to  be season
    
    merged = merged.rename(columns={"season_x": "season"})
    # get rid of unnamed columns
    # combine seasons into final dataset 
    cols = merged.columns.tolist()
    cols_final = merged.columns.copy().tolist()
    
    # remove 'Unnamed' columns so that merging goes smoothly
    for col_name in cols:
        if ("Unnamed" in col_name):
            print(col_name)
            cols_final.remove(col_name)
            
    final = merged[cols_final]
    
    final.to_csv("../data/model_train_2_0.csv")