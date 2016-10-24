# rain_in_day.py plots daily and hourly rainfall for staions in Mukilteo, WA
# By Rex L. Baum and Sarah J. Fischer, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import csv
from matplotlib.dates import strpdate2num, num2date
from pandas import Series, to_datetime
import pandas as pd

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Define functions for reading and plotting data
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

def make_plot(title, x1, y1, x2, y2, name=None, cols=5, yMin=0, yMax=0.5, y2Max=3.0):
    fig, host = plt.subplots(figsize=(12, 6))
    par1 = host.twinx()
    host.set_title(title + disclamers, fontsize=11)
    host.set_xlabel(xtext)
    host.set_ylabel(ytext)
    par1.set_ylabel(y2text)
    host.set_ylim(yMin,yMax)
    par1.set_ylim(yMin,y2Max)
    host.grid()
    p1, = host.plot(x1, y1, linestyle='-', color='b', label='15-minute')
    p2, = par1.plot(x2, y2, 'bo', alpha = 0.5, label='Daily')

    host.xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
    host.xaxis.set_major_locator(mdates.HourLocator())
    host.xaxis.set_minor_locator(mdates.HourLocator(interval=6))
    host.xaxis.set_major_locator(mdates.DayLocator(interval=1))
    lines = [p1, p2]

    host.legend(lines, [l.get_label() for l in lines], bbox_to_anchor=(0, -.15, 1, -0.5), loc=8, ncol=cols, fontsize=10, mode="expand", borderaxespad=-1.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')


disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('15-minute rainfall, inches')
y2text = ('Daily rainfall, inches')

# Process data for Marine View Drive (Stable Coastal Bluff site)
data = readfiles(['waMVD116_14d.txt'],5)

column_0_mvd = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]

# Compute Rainfall
rain_in_mvd = rain_tipCount * 0.01
# Create series and resample to obtain daily rainfall amounts
tstamp = num2date(column_0_mvd, tz=None)
ts = Series(rain_in_mvd, index=tstamp)
daily_in_mvd = ts.resample('d', how='sum')

make_plot('Rainfall at Marine View Dr. & 116 St. SW', column_0_mvd, rain_in_mvd, daily_in_mvd.index, daily_in_mvd.values, name='MVD116_rain_in_day.png')
#
## ------------------------
# Process data for Mukilteo Lighthouse Park
#
data = readfiles(['waMLP_14d.txt'],3)
#
column_0_mlp = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]
#
# Compute Rainfall
rain_in_mlp = rain_tipCount * 0.01
# Create series and resample to obtain daily rainfall amounts
tstamp = num2date(column_0_mlp, tz=None)
ts = Series(rain_in_mlp, index=tstamp)
daily_in_mlp = ts.resample('d', how='sum')
#
make_plot('Rainfall at Mukilteo Lighthouse Park', column_0_mlp, rain_in_mlp, daily_in_mlp.index, daily_in_mlp.values, name='MLP_rain_in_day.png')
#
## ------------------------
# Process data for Mukilteo Wastewater Plant
#
data = readfiles(['waMWWD_14d.txt'],3)
#
column_0_mwwd = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]
#
# Compute Rainfall
rain_in_mwwd = rain_tipCount * 0.01
# Create series and resample to obtain daily rainfall amounts
tstamp = num2date(column_0_mwwd, tz=None)
ts = Series(rain_in_mwwd, index=tstamp)
daily_in_mwwd = ts.resample('d', how='sum')
#
make_plot('Rainfall at Mukilteo Wastewater Plant', column_0_mwwd, rain_in_mwwd, daily_in_mwwd.index, daily_in_mwwd.values, name='MWWD_rain_in_day.png')
#
## ------------------------
# Process data for Waterton Circle (Active Landslide Area)
#
data = readfiles(['waWatertonA_14d.txt'],6)
#
column_0_wca = np.array(data)[0][:,0]
rain_tipCount = np.array(data)[0][:,1]
#
# Compute Rainfall
rain_in_wca = rain_tipCount * 0.01
# Create series and resample to obtain daily rainfall amounts
tstamp = num2date(column_0_wca, tz=None)
ts = Series(rain_in_wca, index=tstamp)
daily_in_wca = ts.resample('d', how='sum')
#
make_plot('Rainfall at Waterton Circle Station A', column_0_wca, rain_in_wca, daily_in_wca.index, daily_in_wca.values, name='MWatA_rain_in_day.png')
#
def make_plot1(title, x1a, y1a, x1b, y1b, x1c, y1c, x1d, y1d, x2a, y2a, x2b, y2b, x2c, y2c, x2d, y2d, name=None, cols=4, yMin=0, yMax=0.5, y2Max=3.0):
    fig, host = plt.subplots(figsize=(12, 6))
    par1 = host.twinx()
    host.set_title(title + disclamers, fontsize=11)
    host.set_xlabel(xtext, fontsize=11)
    host.set_ylabel(ytext, fontsize=11)
    par1.set_ylabel(y2text, fontsize=11)
    host.set_ylim(yMin,yMax)
    par1.set_ylim(yMin,y2Max)
    host.grid()
    p1a, = host.plot(x1a, y1a, linestyle='-', color='b', alpha=0.75, label='SCB 15-minute')
    p1b, = host.plot(x1b, y1b, linestyle='-', color='r', alpha=0.75, label='M1 15-minute')
    p1c, = host.plot(x1c, y1c, linestyle='-', color='g', alpha=0.75, label='M2 15-minute')
    p1d, = host.plot(x1d, y1d, linestyle='-', color='orange', alpha=0.75, label='ALS 15-minute')
    p2a, = par1.plot(x2a, y2a, 'bo', alpha = 0.5, label='SCB Daily')
    p2b, = par1.plot(x2b, y2b, 'ro', alpha = 0.5, label='M1 Daily')
    p2c, = par1.plot(x2c, y2c, 'go', alpha = 0.5, label='M2 Daily')
    p2d, = par1.plot(x2d, y2d, linestyle='', marker='o', color='orange', alpha = 0.5, label='ALS Daily')
    
    host.xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
    host.xaxis.set_major_locator(mdates.HourLocator())
    host.xaxis.set_minor_locator(mdates.HourLocator(interval=6))
    host.xaxis.set_major_locator(mdates.DayLocator(interval=1))
    lines = [p1a, p1b, p1c, p1d, p2a, p2b, p2c, p2d]
    
    host.legend(lines, [l.get_label() for l in lines], loc=2, ncol=cols, fontsize=10, scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')
#
## Set fontsize for plot
#
font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}
#
matplotlib.rc('font', **font)  # pass in the font dict as kwargs
#
make_plot1('Rainfall at Mukilteo Stations', column_0_mvd, rain_in_mvd, column_0_mlp, rain_in_mlp, column_0_mwwd, rain_in_mwwd, column_0_wca, rain_in_wca, daily_in_mvd.index, daily_in_mvd.values, daily_in_mlp.index, daily_in_mlp.values, daily_in_mwwd.index, daily_in_mwwd.values, daily_in_wca.index, daily_in_wca.values, name='Muk_rain_in_day.png')
#
#
