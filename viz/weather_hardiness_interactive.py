#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.impute import SimpleImputer 
from matplotlib.widgets import RadioButtons, CheckButtons
import matplotlib.dates as mdates

# Warning: I repeated myself

####################
# DATA PREPARATION #
####################

dataWeather = pd.read_csv("data/penticton_weather_data_v1.csv")
dataHardiness = pd.read_csv("data/hardiness_cleaned.csv")

# drop weird unnamed column
dataHardiness = dataHardiness.drop("Unnamed: 0", axis = 1)

# fix weird variety names
dataHardiness['Variety'].loc[dataHardiness['Variety'] == 'Shiraz cl.174'] = 'Shiraz'
dataHardiness['Variety'].loc[dataHardiness['Variety'] == 'Sauv blanc'] = 'Sauvignon blanc'
# add julian day to dataWeather

dataWeather["datetime"] = pd.to_datetime(dict(year = dataWeather['Year'], month = dataWeather["Month"], day = dataWeather["Day"]))
dataWeather["julian_day"] = dataWeather["datetime"].dt.strftime('%j')
dataWeather["julian_day"] = dataWeather["julian_day"].astype("int")

# impute missing data to be median
imputer_median = SimpleImputer(missing_values = np.nan, strategy = "mean", verbose = 1)
dataWeather["Total Precip (mm)"] = imputer_median.fit_transform(dataWeather["Total Precip (mm)"].values.reshape(-1,1))


# prepare weather data into dormant seasons for plotting
years = dataWeather["Year"].unique()

dormantSeasonWeather = {}
max_temps = {}
min_temps = {}
cumulative_precip = {}
hardiness_variety = {}
hardiness_variety_year = {}
heat_deg = {}
cool_deg = {}
heat_deg_cumul = {}
cool_deg_cumul = {}

startJulianDay = 246

#adjust hardiness data to fit on the plot based on the startJulianDay
dataHardiness["plot_x_location"] = dataHardiness["julian_day"].apply(lambda x : x - startJulianDay if x >= startJulianDay else x + (366 - startJulianDay))

# split hardiness by variety
varieties = dataHardiness["Variety"].unique()
for variety in varieties:
    hardiness_variety[variety] = dataHardiness[dataHardiness["Variety"] == variety]

    for year in years:
        hardiness_variety_year["{v}_{y}".format(v = variety, y = year)] = hardiness_variety[variety][(((hardiness_variety[variety]["Year"] == year) & (hardiness_variety[variety]["julian_day"] > startJulianDay)) | ((hardiness_variety[variety]["Year"] == year + 1) & (hardiness_variety[variety]["julian_day"] <= startJulianDay)))]

for year in years:
    dormantSeasonWeather[year] = dataWeather[(((dataWeather["Year"] == year) & (dataWeather["julian_day"] > startJulianDay)) | ((dataWeather["Year"] == year + 1) & (dataWeather["julian_day"] <= startJulianDay)))]

for year in years:
    max_temps[year] = dormantSeasonWeather[year]["Max Temp C"].reset_index(drop = True)
    min_temps[year] = dormantSeasonWeather[year]["Min Temp C"].reset_index(drop = True)
    cumulative_precip[year] = dormantSeasonWeather[year]["Total Precip (mm)"].cumsum().reset_index(drop = True)
    heat_deg[year] = dormantSeasonWeather[year]["Heat Deg"].reset_index(drop = True)
    cool_deg[year] = dormantSeasonWeather[year]["Cool Deg"].reset_index(drop = True)
    heat_deg_cumul[year] = dormantSeasonWeather[year]["Heat Deg"].cumsum().reset_index(drop = True)
    cool_deg_cumul[year] = dormantSeasonWeather[year]["Cool Deg"].cumsum().reset_index(drop = True)
    
    
chosen_year = 2012
x_data = dormantSeasonWeather[chosen_year]["julian_day"] # don't plot by julian_date because it will force it to be in increasing order, not stop at 366


#################
# PLOT CREATION #
################# 
    
# idea is to have check buttons with years & check buttons with metrics and show all the metrics for each
def plot_all_metrics():
    
    ## DEFINE AXES AND FIGURE ## 
    fig, ax = plt.subplots()
    
    x_values = list(range(startJulianDay, 366)) + list(range(1, startJulianDay - 1))
    x_count = range(len(x_values))
    plt.subplots_adjust(left=0.25)
    
    # celcius axis & date
    ax.set_xticks(x_count[::30]) # goes to the end of x_count by increments of 30
    ax.set_xticklabels(['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'], rotation = "vertical")
    ax.set_yticks(range(-28, 40, 2), minor = True)
    ax.set_ylabel("Degrees Celcius")
    
    # precipitation axis
    ax2 = ax.twinx()
    ax2.set_ylabel = "Precipitation (mm)"
    
    # third axis does not help at all
    # ax3 = ax.twinx()
    # ax3.set_ylabel = "Cumulative Degrees"
    ## CREATING LINES ##
    
    windowsize = 7
    # tmin max envelope
    l, = ax.plot(min_temps[2012].index, min_temps[2012].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='red', label = '2012', visible = False)
    l1, = ax.plot(min_temps[2013].index, min_temps[2013].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='orange', label='2013', visible = False)
    l2, = ax.plot(min_temps[2014].index, min_temps[2014].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='gold', label='2014', visible = False)
    l3, = ax.plot(min_temps[2015].index, min_temps[2015].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='g', label='2015', visible = False)
    l4, = ax.plot(min_temps[2016].index, min_temps[2016].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='indigo', label='2016', visible = False)
    l5, = ax.plot(min_temps[2017].index, min_temps[2017].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='purple', label='2017', visible = False)
    l6, = ax.plot(min_temps[2018].index, min_temps[2018].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='silver', label='2018', visible = False)
    l7, = ax.plot(np.repeat((366 - startJulianDay), 40), range(-20, 20), lw =4, color = 'pink', label = "New Year", visible = False)
    
    maxEnvelope_Tmin = [l, l1, l2, l3, l4, l5, l6]

    # chardonnay hardiness
    l8 = ax.scatter(hardiness_variety_year["Chardonnay_2012"]["plot_x_location"], hardiness_variety_year["Chardonnay_2012"]["Hardiness"], alpha = 0.3, color = 'red', marker = 'd', label = "2012", visible = False)
    l9 = ax.scatter(hardiness_variety_year["Chardonnay_2013"]["plot_x_location"], hardiness_variety_year["Chardonnay_2013"]["Hardiness"], alpha = 0.3, color = 'orange', marker = 'd', label = "2013", visible = False)
    l10 = ax.scatter(hardiness_variety_year["Chardonnay_2014"]["plot_x_location"], hardiness_variety_year["Chardonnay_2014"]["Hardiness"], alpha = 0.3, color = 'gold', marker = 'd', label = "2014", visible = False)
    l11 = ax.scatter(hardiness_variety_year["Chardonnay_2015"]["plot_x_location"], hardiness_variety_year["Chardonnay_2015"]["Hardiness"], alpha = 0.3, color = 'green', marker = 'd', label = "2015", visible = False)
    l12 = ax.scatter(hardiness_variety_year["Chardonnay_2016"]["plot_x_location"], hardiness_variety_year["Chardonnay_2016"]["Hardiness"], alpha = 0.3, color = 'indigo', marker = 'd', label = "2016", visible = False)
    l13 = ax.scatter(hardiness_variety_year["Chardonnay_2017"]["plot_x_location"], hardiness_variety_year["Chardonnay_2017"]["Hardiness"], alpha = 0.3, color = 'purple', marker = 'd', label = "2017", visible = False)
    l14 = ax.scatter(hardiness_variety_year["Chardonnay_2018"]["plot_x_location"], hardiness_variety_year["Chardonnay_2018"]["Hardiness"], alpha = 0.3, color = 'silver', marker = 'd', label = "2018", visible = False)

    chardonnayHardiness = [l8, l9, l10, l11, l12, l13, l14]

    # tmin min envelope
    l15, = ax.plot(min_temps[2012].index, min_temps[2012].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='red', label = '2012', visible = False)
    l16, = ax.plot(min_temps[2013].index, min_temps[2013].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='orange', label='2013', visible = False)
    l17, = ax.plot(min_temps[2014].index, min_temps[2014].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='gold', label='2014', visible = False)
    l18, = ax.plot(min_temps[2015].index, min_temps[2015].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='g', label='2015', visible = False)
    l19, = ax.plot(min_temps[2016].index, min_temps[2016].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='indigo', label='2016', visible = False)
    l20, = ax.plot(min_temps[2017].index, min_temps[2017].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='purple', label='2017', visible = False)
    l21, = ax.plot(min_temps[2018].index, min_temps[2018].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '-.', lw=1, color='silver', label='2018', visible = False)

    minEnvelope_Tmin = [l15, l16, l17, l18, l19, l20, l21]

    # Tmax min window
    l22, = ax.plot(max_temps[2012].index, max_temps[2012].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='red', label = '2012', visible = False)
    l23, = ax.plot(max_temps[2013].index, max_temps[2013].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='orange', label='2013', visible = False)
    l24, = ax.plot(max_temps[2014].index, max_temps[2014].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='gold', label='2014', visible = False)
    l25, = ax.plot(max_temps[2015].index, max_temps[2015].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='g', label='2015', visible = False)
    l26, = ax.plot(max_temps[2016].index, max_temps[2016].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='indigo', label='2016', visible = False)
    l27, = ax.plot(max_temps[2017].index, max_temps[2017].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='purple', label='2017', visible = False)
    l28, = ax.plot(max_temps[2018].index, max_temps[2018].rolling(window = windowsize).min().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='silver', label='2018', visible = False)
    
    minEnvelope_Tmax = [l22, l23, l24, l25, l26, l27, l28]
    
    # Tmax max window
    l29, = ax.plot(max_temps[2012].index, max_temps[2012].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='red', label = '2012', visible = False)
    l30, = ax.plot(max_temps[2013].index, max_temps[2013].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='orange', label='2013', visible = False)
    l31, = ax.plot(max_temps[2014].index, max_temps[2014].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='gold', label='2014', visible = False)
    l32, = ax.plot(max_temps[2015].index, max_temps[2015].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='g', label='2015', visible = False)
    l33, = ax.plot(max_temps[2016].index, max_temps[2016].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='indigo', label='2016', visible = False)
    l34, = ax.plot(max_temps[2017].index, max_temps[2017].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='purple', label='2017', visible = False)
    l35, = ax.plot(max_temps[2018].index, max_temps[2018].rolling(window = windowsize).max().shift(int(-windowsize/2)), linestyle = '--', lw=1, color='silver', label='2018', visible = False)

    maxEnvelope_Tmax = [l29, l30, l31, l32, l33, l34, l35]
    
    # tmin
    l36, = ax.plot(min_temps[2012].index, min_temps[2012], lw=1, color='red', label = '2012', visible = False)
    l37, = ax.plot(min_temps[2013].index, min_temps[2013], lw=1, color='orange', label='2013', visible = False)
    l38, = ax.plot(min_temps[2014].index, min_temps[2014], lw=1, color='gold', label='2014', visible = False)
    l39, = ax.plot(min_temps[2015].index, min_temps[2015], lw=1, color='g', label='2015', visible = False)
    l40, = ax.plot(min_temps[2016].index, min_temps[2016], lw=1, color='indigo', label='2016', visible = False)
    l41, = ax.plot(min_temps[2017].index, min_temps[2017], lw=1, color='purple', label='2017', visible = False)
    l42, = ax.plot(min_temps[2018].index, min_temps[2018], lw=1, color='silver', label='2018', visible = False)
    
    tmin = [l36, l37, l38, l39, l40, l41, l42]
    
    # tmax
    l43, = ax.plot(max_temps[2012].index, max_temps[2012], lw=1, color='red', label = '2012', visible = False)
    l44, = ax.plot(max_temps[2013].index, max_temps[2013], lw=1, color='orange', label='2013', visible = False)
    l45, = ax.plot(max_temps[2014].index, max_temps[2014], lw=1, color='gold', label='2014', visible = False)
    l46, = ax.plot(max_temps[2015].index, max_temps[2015], lw=1, color='g', label='2015', visible = False)
    l47, = ax.plot(max_temps[2016].index, max_temps[2016], lw=1, color='indigo', label='2016', visible = False)
    l48, = ax.plot(max_temps[2017].index, max_temps[2017], lw=1, color='purple', label='2017', visible = False)
    l49, = ax.plot(max_temps[2018].index, max_temps[2018], lw=1, color='silver', label='2018', visible = False)
    
    tmax = [l43, l44, l45, l46, l47, l48, l49]
    
    # precip 
    l50, = ax2.plot(cumulative_precip[2012].index, cumulative_precip[2012], lw=1, color='red', label = '2012', visible = False)
    l51, = ax2.plot(cumulative_precip[2013].index, cumulative_precip[2013], lw=1, color='orange', label='2013', visible = False)
    l52, = ax2.plot(cumulative_precip[2014].index, cumulative_precip[2014], lw=1, color='gold', label='2014', visible = False)
    l53, = ax2.plot(cumulative_precip[2015].index, cumulative_precip[2015], lw=1, color='g', label='2015', visible = False)
    l54, = ax2.plot(cumulative_precip[2016].index, cumulative_precip[2016], lw=1, color='indigo', label='2016', visible = False)
    l55, = ax2.plot(cumulative_precip[2017].index, cumulative_precip[2017], lw=1, color='purple', label='2017', visible = False)
    l56, = ax2.plot(cumulative_precip[2018].index, cumulative_precip[2018], lw=1, color='silver', label='2018', visible = False)
    
    cumulativePrecip = [l50, l51, l52, l53, l54, l55, l56]

    # heat degrees
    l57, = ax.plot(heat_deg[2012].index, heat_deg[2012], lw=1, color='red', label = '2012', visible = False)
    l58, = ax.plot(heat_deg[2013].index, heat_deg[2013], lw=1, color='orange', label='2013', visible = False)
    l59, = ax.plot(heat_deg[2014].index, heat_deg[2014], lw=1, color='gold', label='2014', visible = False)
    l60, = ax.plot(heat_deg[2015].index, heat_deg[2015], lw=1, color='g', label='2015', visible = False)
    l61, = ax.plot(heat_deg[2016].index, heat_deg[2016], lw=1, color='indigo', label='2016', visible = False)
    l62, = ax.plot(heat_deg[2017].index, heat_deg[2017], lw=1, color='purple', label='2017', visible = False)
    l63, = ax.plot(heat_deg[2018].index, heat_deg[2018], lw=1, color='silver', label='2018', visible = False)
    
    heatDeg = [l57, l58, l59, l60, l61, l62, l63]
    
    # cool degrees
    l71, = ax.plot(cool_deg[2012].index, cool_deg[2012], lw=1, color='red', label = '2012', visible = False)
    l72, = ax.plot(cool_deg[2013].index, cool_deg[2013], lw=1, color='orange', label='2013', visible = False)
    l73, = ax.plot(cool_deg[2014].index, cool_deg[2014], lw=1, color='gold', label='2014', visible = False)
    l74, = ax.plot(cool_deg[2015].index, cool_deg[2015], lw=1, color='g', label='2015', visible = False)
    l75, = ax.plot(cool_deg[2016].index, cool_deg[2016], lw=1, color='indigo', label='2016', visible = False)
    l76, = ax.plot(cool_deg[2017].index, cool_deg[2017], lw=1, color='purple', label='2017', visible = False)
    l77, = ax.plot(cool_deg[2018].index, cool_deg[2018], lw=1, color='silver', label='2018', visible = False)
    
    coolDeg = [l71, l72, l73, l74, l75, l76, l77]
    
    # merlot hardiness
    l78 = ax.scatter(hardiness_variety_year["Merlot_2012"]["plot_x_location"], hardiness_variety_year["Merlot_2012"]["Hardiness"], alpha = 0.3, color = 'red', marker = 'X', label = "2012", visible = False)
    l79 = ax.scatter(hardiness_variety_year["Merlot_2013"]["plot_x_location"], hardiness_variety_year["Merlot_2013"]["Hardiness"], alpha = 0.3, color = 'orange', marker = 'X', label = "2013", visible = False)
    l80 = ax.scatter(hardiness_variety_year["Merlot_2014"]["plot_x_location"], hardiness_variety_year["Merlot_2014"]["Hardiness"], alpha = 0.3, color = 'gold', marker = 'X', label = "2014", visible = False)
    l81 = ax.scatter(hardiness_variety_year["Merlot_2015"]["plot_x_location"], hardiness_variety_year["Merlot_2015"]["Hardiness"], alpha = 0.3, color = 'green', marker = 'X', label = "2015", visible = False)
    l82 = ax.scatter(hardiness_variety_year["Merlot_2016"]["plot_x_location"], hardiness_variety_year["Merlot_2016"]["Hardiness"], alpha = 0.3, color = 'indigo', marker = 'X', label = "2016", visible = False)
    l83 = ax.scatter(hardiness_variety_year["Merlot_2017"]["plot_x_location"], hardiness_variety_year["Merlot_2017"]["Hardiness"], alpha = 0.3, color = 'purple', marker = 'X', label = "2017", visible = False)
    l84 = ax.scatter(hardiness_variety_year["Merlot_2018"]["plot_x_location"], hardiness_variety_year["Merlot_2018"]["Hardiness"], alpha = 0.3, color = 'silver', marker = 'X', label = "2018", visible = False)

    merlotHardiness = [l78, l79, l80, l81, l82, l83, l84]

    # pinot gris hardiness 
    
    l85 = ax.scatter(hardiness_variety_year["Pinot gris_2012"]["plot_x_location"], hardiness_variety_year["Pinot gris_2012"]["Hardiness"], alpha = 0.3, color = 'red', marker = 'o', label = "2012", visible = False)
    l86 = ax.scatter(hardiness_variety_year["Pinot gris_2013"]["plot_x_location"], hardiness_variety_year["Pinot gris_2013"]["Hardiness"], alpha = 0.3, color = 'orange', marker = 'o', label = "2013", visible = False)
    l87 = ax.scatter(hardiness_variety_year["Pinot gris_2014"]["plot_x_location"], hardiness_variety_year["Pinot gris_2014"]["Hardiness"], alpha = 0.3, color = 'gold', marker = 'o', label = "2014", visible = False)
    l88 = ax.scatter(hardiness_variety_year["Pinot gris_2015"]["plot_x_location"], hardiness_variety_year["Pinot gris_2015"]["Hardiness"], alpha = 0.3, color = 'green', marker = 'o', label = "2015", visible = False)
    l89 = ax.scatter(hardiness_variety_year["Pinot gris_2016"]["plot_x_location"], hardiness_variety_year["Pinot gris_2016"]["Hardiness"], alpha = 0.3, color = 'indigo', marker = 'o', label = "2016", visible = False)
    l90 = ax.scatter(hardiness_variety_year["Pinot gris_2017"]["plot_x_location"], hardiness_variety_year["Pinot gris_2017"]["Hardiness"], alpha = 0.3, color = 'purple', marker = 'o', label = "2017", visible = False)
    l91 = ax.scatter(hardiness_variety_year["Pinot gris_2018"]["plot_x_location"], hardiness_variety_year["Pinot gris_2018"]["Hardiness"], alpha = 0.3, color = 'silver', marker = 'o', label = "2018", visible = False)

    pinotGrisHardiness = [l85, l86, l87, l88, l89, l90, l91]

    
    ## CHECKBUTTON CREATION AND LOGIC ##
    
    # Make checkbuttons with all plotted maxEnvelope_Tmin with correct visibility
    
    # TOP CHECKBUTTON
    rax = plt.axes([0.01, 0.55, 0.17, 0.25])
    metricsLabels = ["Tmax", "Tmin", "Tmax Min Envelope '--'", "Tmax Max Envelope '--'", "Tmin Min Envelope '-.'", "Tmin Max Envelope '-.'", "Chardonnay LTE50 'd'", "Merlot LTE50 'x'", "Pinot Gris LTE50 'o'", "Cumulative Precipitation", "Heat Deg", "Cool Deg"]
    #metricsLists = [tmax, tmin, minEnvelope_Tmax, maxEnvelope_Tmax, minEnvelope_Tmin, maxEnvelope_Tmin, hardiness, cumulativePrecip, heatDeg, heatDegCumul, coolDeg, coolDegCumul]
    metricsLists = [tmax, tmin, minEnvelope_Tmax, maxEnvelope_Tmax, minEnvelope_Tmin, maxEnvelope_Tmin, chardonnayHardiness, merlotHardiness, pinotGrisHardiness, cumulativePrecip, heatDeg, coolDeg]
    visibility = [False, False, False, False, False, False, False,False, False, False, False, False, False, False]
    metricCheck = CheckButtons(rax, metricsLabels, visibility)

    plt.title("Metric Selection")
    # formatting plot by picking which variety to look at 

    # MIDDLE CHECKBUTTON
    rax1 = plt.axes([0.01, 0.25, 0.1, 0.2])
    yearsLabels = ["2012", "2013", "2014", "2015", "2016", "2017", "2018"]
    visibility1 = [False, False, False, False, False, False, False]
    yearCheck = CheckButtons(rax1, yearsLabels, visibility1)

    # creating checks for minimum envelope
    plt.title("Year Selection")
    
    # get indeces of current clicked metrics and years 
    def gatherIndeces():
        selectedMetricsIdx = []
        selectedYearsIdx = []
        metricStatus = metricCheck.get_status()
        yearStatus = yearCheck.get_status()
        for idx in range(len(metricStatus)):
            if metricStatus[idx] == True:
                selectedMetricsIdx.append(idx)
        
        for idx in range(len(yearStatus)):
            if yearStatus[idx] == True:
                selectedYearsIdx.append(idx)
            
        return selectedMetricsIdx, selectedYearsIdx
    
    # remove all lines from plot
    def clearPlotOfLines():
        
        for idx in range(len(metricsLists)):
            for idx2 in range(len(yearsLabels)):
                metricsLists[idx][idx2].set_visible(False)
        plt.draw()
    
    # plots a line based on its metric and year 
    def drawMetric(metricIndex, yearIndex):
        metricsLists[metricIndex][yearIndex].set_visible(not metricsLists[metricIndex][yearIndex].get_visible())
        plt.draw()
        
        
    # CALLBACK: plots all the lines that have been selected in the checkbuttons
    def updatePlot(label):
        clearPlotOfLines()
        currentMetricIdx, currentYearsIdx = gatherIndeces()
        for metricIdx in currentMetricIdx:
            for yearIdx in currentYearsIdx:
                drawMetric(metricIdx, yearIdx)
    
        
        
    # PLOT LOGIC #
    metricCheck.on_clicked(updatePlot)
    yearCheck.on_clicked(updatePlot)

    plt.suptitle("Comparing Penticton Weather Metrics and LTE 50 Data 2012 - 2018")
    
    # plt.title("Testing2")
    ax.grid(visible = True, which = 'both', axis = 'y', color = 'grey', alpha = 0.5)
    plt.show()

if (__name__ == "__main__"):
    plot_all_metrics()
# %%
