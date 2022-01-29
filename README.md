# Home for Grapevine Cold Hardiness Predicition
## Okanagan Valley, BC

# Description
Predicting grapevine cold hardiness in the Okanagan Valley, BC.

# Data Sources
## Environment Canada
Instructions for getting Penticton Weather Station Data: https://drive.google.com/drive/folders/160ZGld_zZrqju29GFk2PVAerIeVxKotn

Cygwin query: ``` for year in `seq 2012 2022`;do for month in `seq 1 1`;do wget --content-disposition "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=50269&Year=${year}&Month=${month}&Day=14&timeframe=2&submit= Download+Data" ;done;done ```


# Correlation Analyses

# Approaches

## ML 

Good tutorials for RNN & correlation analysis:
* https://github.com/anujdutt9/Feature-Selection-for-Machine-Learning/blob/master/Filter%20Methods/Correlation.ipynb
* https://github.com/tirthajyoti/Deep-learning-with-Python/blob/master/Notebooks/Weather-RNN.ipynb

## Bayesian
