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

#def skip_first(seq,n):
#    for i, item in enumerate(seq):
#        if i >= n:
#            yield item
#g = open('soundTransit1_remote_rawMeasurements_15m.txt', 'w')
#with open('soundTransit1_remote_rawMeasurements_15m.dat', 'rb') as f:
#    csvreader = csv.reader(f)
#    for row in skip_first(csvreader,4):
#        for row in csv.reader(f,delimiter=',',skipinitialspace=True):
#            print >>g, "\t".join(row)
#g.close()

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

data = readfiles(['waMVD116_Lt.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_mvd = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
# airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

#def init_plot(title, yMin=-10, yMax=40):
def init_plot(title, yMin=-10, yMax=100):
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
ytext = ('Air Temperature, deg F')
#ytext = ('Air Temperature, deg C')

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

init_plot('Air Temperature at Marine View Dr. & 116 St. SW')

#plt.plot(column_0, airTemp_degC, linestyle='-', color='b', label='Air Temperature')
plt.plot(column_0_mvd, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MVD116_airTemp_lt.png')

# ------------------------

data = readfiles(['waMLP_Lt.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_mlp = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
#airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at Mukilteo Lighthouse Park')

#plt.plot(column_0, airTemp_degC, linestyle='-', color='b', label='Air Temperature')
plt.plot(column_0_mlp, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MLP_airTemp_lt.png')

# ------------------------

data = readfiles(['waMWWD_Lt.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_mwwd = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
#airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at Mukilteo Wastewater Plant')

#plt.plot(column_0, airTemp_degC, linestyle='-', color='b', label='Air Temperature')
plt.plot(column_0_mwwd, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MWWD_airTemp_lt.png')

# ------------------------

data = readfiles(['waWatertonA_Lt.txt'],4)
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_watA = np.array(data_1)[0][:,0]
airTempRaw = np.array(data_1)[0][:,1]

#Compute Air Temperature
# airTempRs_ohms = 23100*((airTempRaw/2500)/(1-(airTempRaw/2500))) # use for CR200 series
airTempRs_ohms = 23100*(airTempRaw/(1-airTempRaw)) # use for CR1000
airTemp_degC = -39.17*np.log(airTempRs_ohms) + 410.43
airTemp_degF = 9.*airTemp_degC/5. +32.

init_plot('Air Temperature at Waterton Circle Station A')

#plt.plot(column_0, airTemp_degC, linestyle='-', color='b', label='Air Temperature')
plt.plot(column_0_watA, airTemp_degF, linestyle='-', color='b', label='Air Temperature')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MWat_airTemp_lt.png')