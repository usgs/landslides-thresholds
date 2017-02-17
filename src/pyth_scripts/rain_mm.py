# rain_mm.py plots 15-minute rainfall increments converted to millimeters for stations near Mukilteo, WA
# By Rex L. Baum and Sarah J. Fischer, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.

# Get libraries
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import csv
from matplotlib.dates import strpdate2num

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Define functions
def readfiles(file_list,c1):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,c1),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data

def init_plot(title, yMin=0, yMax=13):  #Set plot dimensions & parameters
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
ytext = ('15-minute rainfall, mm')

# --------------****************-----------------------
# Import data, scale and plot; repeat for each station
# --------------****************-----------------------

data = readfiles(['waMVD116_14d.txt'],5)

column_0 = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]

#Compute Rainfall
rain_mm = rain_tipCount * 0.254

init_plot('Rainfall at VH')

plt.plot(column_0, rain_mm, linestyle='-', color='b', label='Rainfall')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_rain.png')

# ------------------------

data = readfiles(['waMLP_14d.txt'],3)

column_0 = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]

#Compute Rainfall
rain_mm = rain_tipCount * 0.254

init_plot('Rainfall at M1')

plt.plot(column_0, rain_mm, linestyle='-', color='b', label='Rainfall')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MLP_rain.png')

# ------------------------

data = readfiles(['waMWWD_14d.txt'],3)

column_0 = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]

#Compute Rainfall
rain_mm = rain_tipCount * 0.254

init_plot('Rainfall at M2')

plt.plot(column_0, rain_mm, linestyle='-', color='b', label='Rainfall')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWWD_rain.png')

# ------------------------

data = readfiles(['waWatertonA_14d.txt'],6)

column_0 = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]

#Compute Rainfall
rain_mm = rain_tipCount * 0.254

init_plot('Rainfall at LS-a')

plt.plot(column_0, rain_mm, linestyle='-', color='b', label='Rainfall')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_rain.png')

