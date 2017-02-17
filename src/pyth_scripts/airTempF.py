# airTempF.py plots air temperature at stations near Mukilteo, WA in degrees Fahrenheit
# By Rex L. Baum and Sarah J. Fischer, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
#
#Get libraries
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import csv
from numpy import ma
from matplotlib.dates import strpdate2num

# Define Functions
def readfiles(file_list,temp_col):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,temp_col),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data

def init_plot(title, yMin=-10, yMax=100):
    plt.figure(figsize=(12, 6)) 
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=5):
    plt.legend(bbox_to_anchor=(0, -.15, 1, -0.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-1.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Air Temperature, deg F')

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# --------------****************-----------------------
# Import data, scale and plot; repeat for each station
# --------------****************-----------------------

data = readfiles(['waMVD116_14d.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000 data logger
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at VH')

plt.plot(column_0, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_airTemp.png')

# ------------------------

data = readfiles(['waMLP_14d.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at M1')

plt.plot(column_0, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MLP_airTemp.png')

# ------------------------

data = readfiles(['waMWWD_14d.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at M2')

plt.plot(column_0, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWWD_airTemp.png')

# ------------------------

data = readfiles(['waWatertonA_14d.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000 data logger
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at LS-a')

plt.plot(column_0, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWat_airTemp.png')
