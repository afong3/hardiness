# January 30, 2022

# SVR for a unique site and variety. 
# The combination with the most samples (214) is Sauvignon Blanc from Oliver, east
#%%

import os
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from pickle import dump
from sklearn.svm import SVR

def load_data()->pd.DataFrame:
    '''
    Returns data as pd.DataFrame
    
    '''
    # iterates through all files in a path
    rel_path = "../data/model_train.csv"
    
    # load into dataframe
    data = pd.read_csv(rel_path)
    
    # group by variety and site
    grouped = data.groupby(["variety", "site"])
    
    # choose correct group and get rid of na values
    group = grouped.get_group(("Sauvignon blanc", "Oliver, east")).dropna()
    
    season = group["season"]
    
    return group, season.reset_index(drop = True)

def pickle_scaler(sc, rel_path):
    '''
    Pickles standard scaler if the model is to be deployed
    Returns nothing
    '''
    dump(sc, open(rel_path +".pkl"), 'wb')
    

def scale_data(X_raw: np.array, y_raw: np.array): #np.array, np.array, StandardScaler, StandardScaler
    '''
    Returns X_scaled, y_scaled, scaler_X
    
    '''
    # instantiate scaler objects
    sc_X = StandardScaler()
    X_scaled = sc_X.fit_transform(X_raw)

    # not scaling y because they are already well scaled
    y_scaled = y_raw
    
    
    return X_scaled, y_scaled, sc_X

def preprocess_data(data: pd.DataFrame, predictors = None, target = None): #pd.DataFrame, pd.DataFrame, StandardScaler, StandardScaler
    '''
    All preprocessing is done in here. Scaling will most likely occur but there is a 
    high probability of other preprocessing prior to scaling. Enter the columns you want as predictors,
    and the column you want as the final prediction. 
    
    Returns X_scaled, y_scaled, scaler
    '''
    if (predictors != None) & (target != None):
        # get raw data
        X_raw = data[predictors]
        y_raw = data[target]
        
        #scale data
        X_scaled, y_scaled, scaler_X = scale_data(X_raw.to_numpy(), y_raw.to_numpy())

        # reform the np.arrays back into dataframes nicely so that test train goes smoothly
        X = pd.DataFrame(X_scaled, columns = predictors)
        y = pd.DataFrame(y_scaled, columns = target)
        
        # if you want to save the scalers
        # pickle_scaler(scaler_X, "scalers/X_sauvb_oliver_east")
        
        return X, y, scaler_X
    else:
        print("add the columns of the predictors and target as separate lists!")
   
def test_train_split(X:pd.DataFrame, y:pd.Series, season):
    # add the season column to data to filter
    # take a couple of seasons out to use as test data
    test_season_condition = (season == 3) | (season == 6)
    train_season_condition = (season != 3) & (season != 6)
    
    X_test = X[test_season_condition]
    X_train = X[train_season_condition]
    y_test = y[test_season_condition]
    y_train = y[train_season_condition]
    
    return X_test.to_numpy(), X_train.to_numpy(), y_test.to_numpy(), y_train.to_numpy()

def train_model(X, y):
    '''
    Returns fitted model
    
    '''
    regressor = SVR(kernel = 'rbf') # rbf is the most common but we can try other ones 
    regressor.fit(X, y)
    
    return regressor

def create_data_for_model_interpolation():
    '''
    Returns X_interp_scaled, y_interp_scaled
    
    '''
    predictors = pd.read_csv("../data/predictors.csv")
    
    return predictors
    
def validate_model(model, X_test, y_test):
    ''' 
    Prints validation statistics
    
    '''
    score = model.score(X_test, y_test)
    
    print(score)
    

def plot_model():
    '''
    Plots model in the correct context
    
    ''' 
    
    

if __name__ == "__main__":
    # main for modeling
    data, season = load_data()
    
    # process the data 
    predictors =  ["tmax_avg_14", "temp_swing_cumulative_14", "tmax_t-1", "tmax_t-2"]
    target = ["hardiness_delta"]
    
    # scale data 
    X, y, X_scaler = preprocess_data(data, predictors, target)
    X_test, X_train, y_test, y_train = test_train_split(X, y, season)
    
    # train SVR
    model = train_model(X_train, y_train.ravel())
    
    # get predictors
    pred = create_data_for_model_interpolation()
    
    # Get predictions for all data 
    X_line = pred[predictors].to_numpy()
    y_line = model.predict(X_line)
    
    # Plotting!
    
    # get dates from predictions
    line = pd.DataFrame()
    line["datetime"] = pred["datetime"]
    line["prediction"] = y_line
    line["season"] = pred["season"]
    