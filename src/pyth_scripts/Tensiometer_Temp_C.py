# Tensiometer_Temp_C.py plots ground temperatures (Celcius) measured by tensiometers at hillside sites in Mukilteo, WA
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

# Define Functions
def readfiles(file_list,c1,c2,c3): # Read timestamp and 3 columns of data
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

def init_plot(title, yMin=-10, yMax=40): # set plot dimensions and parameters
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
xtext = ('Date and time')
ytext = ('Temperature, deg C')

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs
# --------------------------------------------------------------
# Import data and assign to arrays
data = readfiles(['waMVD116_14d.txt'],14,15,16) # Columns 14,15,16
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

# Draw and save plot
init_plot('Tensiometer Temperature at VH')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', label='3 110 cm')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_Tensiometer_Temp.png')

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
# Draw and save plot
init_plot('Tensiometer Temperature at LS-a')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', label='3 110 cm')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', alpha=0, label='4 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_Tensiometer_Temp.png')

# ------------------------
# Import data and assign to arrays
data = readfiles(['waWatertonB_14d.txt'],14,15,16) # columns 14,15,16
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensTemp_V_1 = np.array(data_1)[0][:,1]
corrTensTemp_V_2 = np.array(data_1)[0][:,2]
corrTensTemp_V_3 = np.array(data_1)[0][:,3]

corrTensTemp_kPa_1 = corrTensTemp_V_1 * tensMult + tensOffs
corrTensTemp_kPa_2 = corrTensTemp_V_2 * tensMult + tensOffs
corrTensTemp_kPa_3 = corrTensTemp_V_3 * tensMult + tensOffs
# Draw and save plot
init_plot('Tensiometer Temperature at LS-b')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='2 110 cm')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', alpha=0, label='3 170 cm ')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', label='4 177 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_Tensiometer_Temp.png')
