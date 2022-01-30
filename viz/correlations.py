# Adam Fong
# January 22, 2022
# Home base for looking at correlation between derived weather variables and recorded hardiness 
# Do not summarize data in this, only good for visualizing. Honestly might be better to put this into /viz

# NOTE: Hardiness recordings are bimonthly. Weather metrics must summarize data between recordings (roughly 14 days).
#       Keep that in mind with the following metrics...

# Weather Metrics in Question
## 14 day average (tmin, tmax, and average)
## Cooling Degree Days (CDD) (vary threshold temps?)
## precipitation 
## sunny days
## cloudy days
## days past Aug 1st
## photoperiod (simple daylight calculation or include cloudy / sunny in some model)

# Comparisons
## Metrics by variety
## Metrics by samples in acclimation
## Metrics by samples in deep dormancy
## Metrics by samples in deacclimation

#%%
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt



def plot_all_varieties():
    # visualize correlated features for all varieties

    corr = data.corr()
    fig, ax = plt.subplots()
    fig.set_size_inches(10,11)
    ax.set_title("All Varieties Correlations")
    # plot heatmap for hardiness and hardiness_delta
    sns.heatmap(corr[["hardiness", "hardiness_delta", "hardiness_delta_abs"]], annot = True, linewidths = 0.5, cmap = "bwr")

    plt.savefig('plots/{n_samples}_all_varieties.png'.format(n_samples = data.shape[0]))

def plot_by_variety():
    #### Plotting by variety ####
    # split hardiness into seasons for tidyness
    grouped = data.groupby("variety")
    varieties = [grouped.get_group(x).reset_index(drop = True) for x in grouped.groups]

    for variety in varieties:
        corr = variety.corr()
        fig, ax = plt.subplots()
        fig.set_size_inches(10,11)
        v = variety.variety[0]
        ax.set_title("{} Correlations".format(v))

        # plot heatmap for hardiness and hardiness_delta
        sns.heatmap(corr[["hardiness", "hardiness_delta", "hardiness_delta_abs"]], annot = True, linewidths = 0.5, cmap = "bwr")

        plt.savefig('plots/{n_samples}_{var}.png'.format(var = v, n_samples = variety.shape[0]).replace(" ", "_"))
        
if __name__ == "__main__":
    # import data
    data = pd.read_csv("../data/model_inputs.csv")
    data = data.iloc[:, 1:]
    
    # plot
    plot_all_varieties()
    plot_by_variety()