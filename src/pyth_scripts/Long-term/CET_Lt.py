#CET_Lt.py
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import csv
from numpy import ma
from matplotlib.dates import strpdate2num, num2date
from pandas import Series, to_datetime
import pandas as pd

def readfiles(file_list,c1):
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


data = readfiles(['waWat_DynCont_Lt.txt'],9) # 9
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
cetDistance_raw = np.array(data_1)[0][:,1]

#Const cet_mult = 0.6477' mm/mV
#Const cet_offs = -14
cetDistance_mult = 0.6477
cetDistance_Offs = -14

cetDistance_mm = cetDistance_raw*cetDistance_mult+cetDistance_Offs
#cetDistance_m = cetDistance_mm/1000.

def init_plot(title, yMin=-1, yMax=40):
    plt.figure(figsize=(12, 6)) # figsize=(24, 12)
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    #plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=5):
    plt.legend(bbox_to_anchor=(0, -.15, 1, -0.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-1.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Extensometer distance, mm')

# Set fontsize for plots

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Create series and resample to obtain daily rainfall amounts
tstamp = num2date(column_0, tz=None)
ts = Series(cetDistance_mm, index=tstamp)
ts_dist_mm = ts.resample('H', how='median')

init_plot('Extensometer Distance at ALS')

plt.plot(ts_dist_mm.index, ts_dist_mm.values, linestyle='-', color='b', label='CET 1')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MVWat_Dyn_cet_Lt.png')

