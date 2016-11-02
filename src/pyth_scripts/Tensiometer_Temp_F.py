# Tensiometer_Temp_F.py plots ground temperatures (Fahrenheit) measured by tensiometers at hillside sites in Mukilteo, WA
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
# import csv
from numpy import ma
from matplotlib.dates import strpdate2num

def readfiles(file_list,c1,c2,c3): # Read time stamp and three columns of data
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

def init_plot(title, yMin=0, yMax=100): # Set plot parameters and dimensions
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
ytext = ('Temperature, deg F')

# Import data and assign to arrays
data = readfiles(['waMVD116_14d.txt'],14,15,16) # columns 14,15,16
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensTemp_V_1 = np.array(data_1)[0][:,1]
corrTensTemp_V_2 = np.array(data_1)[0][:,2]
corrTensTemp_V_3 = np.array(data_1)[0][:,3]

tensMult = 0.05
tensOffs = -30

corrTensTemp_kPa_1 = corrTensTemp_V_1 * tensMult + tensOffs
corrTensTemp_kPa_2 = corrTensTemp_V_2 * tensMult + tensOffs
corrTensTemp_kPa_3 = corrTensTemp_V_3 * tensMult + tensOffs
# Convert to Fahrenheit
corrTensTemp_F_1 = 32. + 9.*corrTensTemp_kPa_1/5.
corrTensTemp_F_2 = 32. + 9.*corrTensTemp_kPa_2/5.
corrTensTemp_F_3 = 32. + 9.*corrTensTemp_kPa_3/5.

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs
# Draw and save plot
init_plot('Tensiometer Temperature at Marine View Drive & 116 St. SW')

plt.plot(column_0, corrTensTemp_F_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_F_2, linestyle='-', color='r', label='3 110 cm')
plt.plot(column_0, corrTensTemp_F_3, linestyle='-', color='g', label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_Tensiometer_Temp_F.png')

# ------------------------
# Import data and assign to arrays
data = readfiles(['waWatertonA_14d.txt'],15,16,17) # columns 15,16,17
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensTemp_V_1 = np.array(data_1)[0][:,1]
corrTensTemp_V_2 = np.array(data_1)[0][:,2]
corrTensTemp_V_3 = np.array(data_1)[0][:,3]

corrTensTemp_kPa_1 = corrTensTemp_V_1 * tensMult + tensOffs
corrTensTemp_kPa_2 = corrTensTemp_V_2 * tensMult + tensOffs
corrTensTemp_kPa_3 = corrTensTemp_V_3 * tensMult + tensOffs
# Convert to Fahrenheit
corrTensTemp_F_1 = 32. + 9.*corrTensTemp_kPa_1/5.
corrTensTemp_F_2 = 32. + 9.*corrTensTemp_kPa_2/5.
corrTensTemp_F_3 = 32. + 9.*corrTensTemp_kPa_3/5.

# Draw and save plot
init_plot('Tensiometer Temperature at Waterton Circle Station A')

plt.plot(column_0, corrTensTemp_F_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_F_2, linestyle='-', color='r', label='3 110 cm')
plt.plot(column_0, corrTensTemp_F_3, linestyle='-', color='g', alpha=0, label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_Tensiometer_Temp_F.png')

# ------------------------
# Import data and assign to arrays
data = readfiles(['waWatertonB_14d.txt'],14,15,16) # Columns 14,15,16
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensTemp_V_1 = np.array(data_1)[0][:,1]
corrTensTemp_V_2 = np.array(data_1)[0][:,2]
corrTensTemp_V_3 = np.array(data_1)[0][:,3]

corrTensTemp_kPa_1 = corrTensTemp_V_1 * tensMult + tensOffs
corrTensTemp_kPa_2 = corrTensTemp_V_2 * tensMult + tensOffs
corrTensTemp_kPa_3 = corrTensTemp_V_3 * tensMult + tensOffs
# Convert to Fahrenheit
corrTensTemp_F_1 = 32. + 9.*corrTensTemp_kPa_1/5.
corrTensTemp_F_2 = 32. + 9.*corrTensTemp_kPa_2/5.
corrTensTemp_F_3 = 32. + 9.*corrTensTemp_kPa_3/5.

# Draw and save plot
init_plot('Tensiometer Temperature at Waterton Circle Station B')

plt.plot(column_0, corrTensTemp_F_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_F_2, linestyle='-', color='r', alpha=0, label='3 170 cm')
plt.plot(column_0, corrTensTemp_F_3, linestyle='-', color='g', label='4 177 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_Tensiometer_Temp_F.png')
