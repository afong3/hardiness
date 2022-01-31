# January 30, 2022

# setting up a template for legibility
import os
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from pickle import dump

def load_data()->pd.DataFrame:
    '''
    Returns data as pd.DataFrame
    
    '''
    # iterates through all files in a path
    rel_path = ""
    for root, dirs, files in os.walk(rel_path):
        for file in files:  
            # fill in load data logic here or delete loop 
            print(file)

def pickle_scaler(sc, rel_path):
    '''
    Pickles standard scaler if the model is to be deployed
    Returns nothing
    '''
    dump(sc, open(rel_path +".pkl"), 'wb')
    

def scale_data(X_raw: np.array, y_raw: np.array)->tuple(np.array, np.array, StandardScaler, StandardScaler):
    '''
    Returns X_scaled, y_scaled, X_scaler, y_scaler
    
    '''
    # instantiate scaler objects
    sc_X = StandardScaler()
    sc_y = StandardScaler()
    
    X_scaled = sc_X.fit_transform(X_raw)
    y_scaled = sc_y.fit_transform(y_raw)
    
    return X_scaled, y_scaled, sc_X, sc_y

def preprocess_data(data: pd.DataFrame, X_cols= None, y_col = None)->tuple(np.array, np.array, StandardScaler, StandardScaler):
    '''
    All preprocessing is done in here. Scaling will most likely occur but there is a 
    high probability of other preprocessing prior to scaling. Enter the columns you want as predictors,
    and the column you want as the final prediction. 
    
    Returns X_scaled, y_scaled, X_scaler, y_scaler
    '''
    if X_cols != None:
        X_raw = data[X_cols]
        
    if y_col != None:
        y_raw = data[y_col]
    


def train_model():
    '''
    Returns fitted model
    
    '''
    
    


def create_data_for_model_interpolation():
    '''
    Returns X_interp_scaled, y_interp_scaled
    
    '''
    
    
    
def validate_model():
    ''' 
    Prints validation statistics
    
    '''
    
    

def plot_model():
    '''
    Plots model in the correct context
    
    ''' 
    
    

if __name__ == "__main__":
    # main for modeling
    
    pass
    