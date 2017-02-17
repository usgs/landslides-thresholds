# Tensiometer_Press.py plots pressure head measurements for tensiometers for hillside stations in Mukilteo, WA
# By Rex L. Baum and Sarah J. Fischer, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
#
# Get libraries
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

# Set fontsize for plots

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Define functions
def readfiles(file_list,c1,c2,c3): # read timestamp and 3 columns of data
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,c1,c2,c3),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data


def init_plot(title, yMin=-90, yMax=25): # Set plot dimensions and parameters
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
ytext = ('Pressure, kPa')

# Import data and assign to arrays
data = readfiles(['waMVD116_14d.txt'],11,12,13) #Columns 11,12,13
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]
# Compute pressures
tensMult = -0.1
tensOffs = 100

corrTensPres_kPa_1_mvd = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_mvd = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_mvd = corrTensPres_V_3 * tensMult + tensOffs
# Draw and save plot
init_plot('Tensiometer Pressure at Marine View Drive & 116 St. SW')

plt.plot(column_0, corrTensPres_kPa_1_mvd, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensPres_kPa_2_mvd, linestyle='-', color='r', label='3 110 cm')
plt.plot(column_0, corrTensPres_kPa_3_mvd, linestyle='-', color='g', label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_Tensiometer_Press.png')

# ------------------------
# Import data and assign to arrays
data = readfiles(['waWatertonA_14d.txt'],12,13,14) # Columns 12,13,14
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]
# Compute pressures
corrTensPres_kPa_1_wca = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_wca = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_wca = corrTensPres_V_3 * tensMult + tensOffs
# Draw and save plot
init_plot('Tensiometer Pressure at Waterton Circle Station A')

plt.plot(column_0, corrTensPres_kPa_1_wca, linestyle='-', color='b', alpha=0, label='2 110 cm')
plt.plot(column_0, corrTensPres_kPa_2_wca, linestyle='-', color='r', alpha=0, label='3 110 cm')
plt.plot(column_0, corrTensPres_kPa_3_wca, linestyle='-', color='g', label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_Tensiometer_Press.png')

# ------------------------
# Import data and assign to arrays
data = readfiles(['waWatertonB_14d.txt'],11,12,13) # Columns 11,12,13
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]
# Compute pressure
corrTensPres_kPa_1_wcb = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_wcb = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_wcb = corrTensPres_V_3 * tensMult + tensOffs
# Draw and save plot
init_plot('Tensiometer Pressure at Waterton Circle Station B')

plt.plot(column_0, corrTensPres_kPa_1_wcb, linestyle='-', color='b', alpha=0, label='2 110 cm')
plt.plot(column_0, corrTensPres_kPa_2_wcb, linestyle='-', color='r', alpha=0, label='3 170 cm')
plt.plot(column_0, corrTensPres_kPa_3_wcb, linestyle='-', color='g', alpha=0, label='4 177 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_Tensiometer_Press.png')

# Define function to plot data from all stations
def init_plot1(title, yMin=-90, yMax=25): # Set plot dimensions and paramters
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext, fontsize=10)
    plt.ylabel(ytext, fontsize=10)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot1(name=None, cols=5):
    plt.legend(loc=2, ncol=cols, fontsize=10, title='  Sensor Position & Depth, cm\nVH          LS-a          LS-b')
    if name:
        plt.savefig(name, bbox_inches='tight')

# Draw and save plot
init_plot1('Tensiometer Pressure at Mukilteo Stations')

# Use alpha=0 to hide lines for sensor that are malfunctioning or have been removed.
plt.plot(column_0, corrTensPres_kPa_1_mvd, linestyle='-', color='b', label='2 110')
plt.plot(column_0, corrTensPres_kPa_2_mvd, linestyle='-', color='r', label='3 110')
plt.plot(column_0, corrTensPres_kPa_3_mvd, linestyle='-', color='g', label='4 100')
plt.plot(column_0, corrTensPres_kPa_1_wca, linestyle='--', color='b', alpha=0, label='2 110')
plt.plot(column_0, corrTensPres_kPa_2_wca, linestyle='--', color='r', alpha=0, label='3 110')
plt.plot(column_0, corrTensPres_kPa_3_wca, linestyle='--', color='g', label='4 100')
plt.plot(column_0, corrTensPres_kPa_1_wcb, linestyle='-.', color='b', alpha=0, label='2 110')
plt.plot(column_0, corrTensPres_kPa_2_wcb, linestyle='-.', color='r', alpha=0, label='3 170')
plt.plot(column_0, corrTensPres_kPa_3_wcb, linestyle='-.', color='g', alpha=0, label='4 177')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot1(name='Muk_Tensiometer_Press.png', cols=3)
