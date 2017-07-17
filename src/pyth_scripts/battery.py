# battery.py plots battery voltage time series for multiple stations
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

def init_plot(title, yMin=9, yMax=15):  # Set plot dimensions and parameters
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext, fontsize=11)
    plt.ylabel(ytext, fontsize=11)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=5):
    plt.legend(loc=3, fontsize=10, title='Station')
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date and time')
ytext = ('Battery Voltage')

#Import data from successive files
data = readfiles(['waMVD116_14d.txt'],2)
data_1 = ma.fix_invalid(data, fill_value = 'nan')
column_0_MVD116 = np.array(data_1)[0][:,0]
battery_volt_MVD116 = np.array(data_1)[0][:,1]

data = readfiles(['waWatertonA_14d.txt'],2)
data_1 = ma.fix_invalid(data, fill_value = 'nan')
column_0_MWatA= np.array(data_1)[0][:,0]
battery_volt_MWatA = np.array(data_1)[0][:,1]

data = readfiles(['waWatertonB_14d.txt'],2)
data_1 = ma.fix_invalid(data, fill_value = 'nan')
column_0_MWatB = np.array(data_1)[0][:,0]
battery_volt_MWatB = np.array(data_1)[0][:,1]

data = readfiles(['waMWWD_14d.txt'],2)
data_1 = ma.fix_invalid(data, fill_value = 'nan')
column_0_MWWD = np.array(data_1)[0][:,0]
battery_volt_MWWD = np.array(data_1)[0][:,1]

data = readfiles(['waMLP_14d.txt'],2)
data_1 = ma.fix_invalid(data, fill_value = 'nan')
column_0_MLP = np.array(data_1)[0][:,0]
battery_volt_MLP = np.array(data_1)[0][:,1]

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

#Draw and save plots

init_plot('Battery voltage at all Stations')

plt.plot(column_0_MVD116, battery_volt_MVD116, linestyle='-', color='b', label='VH')
plt.plot(column_0_MWatA, battery_volt_MWatA, linestyle='-', color='r', label='LS-a')
plt.plot(column_0_MVD116, battery_volt_MWatB, linestyle='-', color='g', label='LS-b')
plt.plot(column_0_MVD116, battery_volt_MLP, linestyle='-', color='m', label='M1')
plt.plot(column_0_MVD116, battery_volt_MWWD, linestyle='-', color='c', label='M2')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='Muk_battery.png')
