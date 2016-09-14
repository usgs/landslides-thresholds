# VWC.py plots volumeteric water content measured by EC-5 probes at hillside stations in Mukilteo, WA
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

def readfiles(file_list,c1,c2,c3,c4,c5):
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,c1,c2,c3,c4,c5),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data


data = readfiles(['waMVD116_14d.txt'],6,7,8,9,10) # Columns 6,7,8,9,10
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
vwcRaw_1 = np.array(data_1)[0][:,1]
vwcRaw_2 = np.array(data_1)[0][:,2]
vwcRaw_3 = np.array(data_1)[0][:,3]
vwcRaw_4 = np.array(data_1)[0][:,4]
vwcRaw_5 = np.array(data_1)[0][:,5]

vwcMult = 2.975
vwxOffs = -0.4

vwcEng_1_mvd = vwcRaw_1 * vwcMult + vwxOffs
vwcEng_2_mvd = vwcRaw_2 * vwcMult + vwxOffs
vwcEng_3_mvd = vwcRaw_3 * vwcMult + vwxOffs
vwcEng_4_mvd = vwcRaw_4 * vwcMult + vwxOffs
vwcEng_5_mvd = vwcRaw_5 * vwcMult + vwxOffs

def init_plot(title, yMin=0, yMax=0.6):
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
ytext = ('Volumetric Water content')

# Set fontsize for plots

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

init_plot('Volumetric Water Content at Marine View Drive & 116 St. SW')

plt.plot(column_0, vwcEng_1_mvd, linestyle='-', color='b', label='1 110 cm')
plt.plot(column_0, vwcEng_2_mvd, linestyle='-', color='r', label='2 110 cm')
plt.plot(column_0, vwcEng_3_mvd, linestyle='-', color='g', label='3 100 cm')
plt.plot(column_0, vwcEng_4_mvd, linestyle='-', color='c', label='4 130 cm')
plt.plot(column_0, vwcEng_5_mvd, linestyle='-', color='m', label='5 100 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_VWC.png')

# ------------------------

data = readfiles(['waWatertonA_14d.txt'],7,8,9,10,11) # Columns 7,8,9,10,11
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
vwcRaw_1 = np.array(data_1)[0][:,1]
vwcRaw_2 = np.array(data_1)[0][:,2]
vwcRaw_3 = np.array(data_1)[0][:,3]
vwcRaw_4 = np.array(data_1)[0][:,4]
vwcRaw_5 = np.array(data_1)[0][:,5]

vwcEng_1_watA = vwcRaw_1 * vwcMult + vwxOffs
vwcEng_2_watA = vwcRaw_2 * vwcMult + vwxOffs
vwcEng_3_watA = vwcRaw_3 * vwcMult + vwxOffs
vwcEng_4_watA = vwcRaw_4 * vwcMult + vwxOffs
vwcEng_5_watA = vwcRaw_5 * vwcMult + vwxOffs

init_plot('Volumetric Water Content at Waterton Circle Station A')

plt.plot(column_0, vwcEng_1_watA, linestyle='-', color='b', label='1 20 cm')
plt.plot(column_0, vwcEng_2_watA, linestyle='-', color='r', alpha=0, label='2 20 cm')
plt.plot(column_0, vwcEng_3_watA, linestyle='-', color='g', alpha=0, label='3 80 cm')
plt.plot(column_0, vwcEng_4_watA, linestyle='-', color='c', label='4 80 cm')
plt.plot(column_0, vwcEng_5_watA, linestyle='-', color='m', label='5 85 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_VWC.png')

# ------------------------

data = readfiles(['waWatertonB_14d.txt'],6,7,8,9,10) # Columns 6,7,8,9,10
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
vwcRaw_1 = np.array(data_1)[0][:,1]
vwcRaw_2 = np.array(data_1)[0][:,2]
vwcRaw_3 = np.array(data_1)[0][:,3]
vwcRaw_4 = np.array(data_1)[0][:,4]
vwcRaw_5 = np.array(data_1)[0][:,5]

vwcEng_1_watB = vwcRaw_1 * vwcMult + vwxOffs
vwcEng_2_watB = vwcRaw_2 * vwcMult + vwxOffs
vwcEng_3_watB = vwcRaw_3 * vwcMult + vwxOffs
vwcEng_4_watB = vwcRaw_4 * vwcMult + vwxOffs
vwcEng_5_watB = vwcRaw_5 * vwcMult + vwxOffs

init_plot('Volumetric Water Content at Waterton Circle Station B')

plt.plot(column_0, vwcEng_1_watB, linestyle='-', color='b', label='1 100 cm')
plt.plot(column_0, vwcEng_2_watB, linestyle='-', color='r', alpha=0, label='2 20 cm')
plt.plot(column_0, vwcEng_3_watB, linestyle='-', color='g', alpha=0, label='3 115 cm')
plt.plot(column_0, vwcEng_4_watB, linestyle='-', color='c', label='4 115 cm')
plt.plot(column_0, vwcEng_5_watB, linestyle='-', color='m', label='5 120 cm')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_VWC.png')

#
def init_plot_all(title, yMin=0, yMax=0.6):
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext, fontsize=11)
    plt.ylabel(ytext, fontsize=11)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=5):
    plt.legend(loc=2, ncol=cols, fontsize=10, title='  Sensor Position & Depth, cm\nSCB         ALS-a         ALS-b')
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Volumetric Water content')

# Plot graph of volumetric water content

init_plot_all('Volumetric Water Content at Mukilteo Stations')

# Use alpha=0 to hide lines of sensors that are malfunctioning or have been removed
plt.plot(column_0, vwcEng_1_mvd, linestyle='-', color='b', label='1 110')
plt.plot(column_0, vwcEng_2_mvd, linestyle='-', color='r', label='2 110')
plt.plot(column_0, vwcEng_3_mvd, linestyle='-', color='g', label='3 100')
plt.plot(column_0, vwcEng_4_mvd, linestyle='-', color='c', label='4 130')
plt.plot(column_0, vwcEng_5_mvd, linestyle='-', color='m', label='5 100')
plt.plot(column_0, vwcEng_1_watA, linestyle='--', color='b', label='1 20')
plt.plot(column_0, vwcEng_2_watA, linestyle='--', color='r', alpha=0, label='2 20')
plt.plot(column_0, vwcEng_3_watA, linestyle='--', color='g', alpha=0, label='3 80')
plt.plot(column_0, vwcEng_4_watA, linestyle='--', color='c', label='4 80')
plt.plot(column_0, vwcEng_5_watA, linestyle='--', color='m', label='5 95')
plt.plot(column_0, vwcEng_1_watB, linestyle='-.', color='b', label='1 100')
plt.plot(column_0, vwcEng_2_watB, linestyle='-.', color='r', alpha=0, label='2 20')
plt.plot(column_0, vwcEng_3_watB, linestyle='-.', color='g', alpha=0, label='3 115')
plt.plot(column_0, vwcEng_4_watB, linestyle='-.', color='c', label='4 115')
plt.plot(column_0, vwcEng_5_watB, linestyle='-.', color='m', label='5 120')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='Muk_VWC.png', cols=3)

