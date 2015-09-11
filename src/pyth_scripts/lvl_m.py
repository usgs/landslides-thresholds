import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import csv
from numpy import ma
from matplotlib.dates import strpdate2num

def skip_first(seq,n):
    for i, item in enumerate(seq):
        if i >= n:
            yield item
g = open('soundTransit1_remote_rawMeasurements_15m.txt', 'w')
with open('soundTransit1_remote_rawMeasurements_15m.dat', 'rb') as f:
    csvreader = csv.reader(f)
    for row in skip_first(csvreader,4):
        for row in csv.reader(f,delimiter=',',skipinitialspace=True):
            print >>g, "\t".join(row)
g.close()

def readfiles(file_list):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,17,18,19,20),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data

data = readfiles(['soundTransit1_remote_rawMeasurements_15m.txt'])
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
freq1 = np.array(data_1)[0][:,1]
thermRes1 = np.array(data_1)[0][:,2]
freq2 = np.array(data_1)[0][:,3]
thermRes2 = np.array(data_1)[0][:,4]

#VW Piezometer Calibration Coefficients
C1_0 = 0.00000001
C1_1 = 0.00000001
C1_2 = 0.00000001
C1_3 = 0.00000001
C1_4 = 0.00000001
C1_5 = 0.00000001

#Compute Thermistor Temperature and Water Level
thermTemp1_degC = 1/(1.401E-3 + 2.377E-4*np.log(thermRes1) + 9.730E-8*np.log(thermRes1)**3)-273.15
lvl1_m = (C1_0 + (C1_1*freq1) + (C1_2*thermTemp1_degC) + (C1_3*(freq1**2)) + (C1_4*freq1*thermTemp1_degC) + (C1_5*(thermTemp1_degC**2))) * 0.70432

thermTemp2_degC = 1/(1.401E-3 + 2.377E-4*np.log(thermRes2) + 9.730E-8*np.log(thermRes2)**3)-273.15
lvl2_m = (C1_0 + (C1_1*freq2) + (C1_2*thermTemp2_degC) + (C1_3*(freq2**2)) + (C1_4*freq2*thermTemp2_degC) + (C1_5*(thermTemp2_degC**2))) * 0.70432

def init_plot(title, yMin=0, yMax=3):
    plt.figure(figsize=(24, 12))
    plt.title(title + disclamers)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    #plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=5):
    plt.legend(bbox_to_anchor=(0, -.1, 1, -0.5), loc=8, ncol=cols,
               mode="expand", borderaxespad=-1.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Water Level, m')

init_plot('Water Level')

plt.plot(column_0, lvl1_m, linestyle='-', color='b', label='Water Level 1')
plt.plot(column_0, lvl2_m, linestyle='-', color='r', label='Water Level 2')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='py_lvl.png')

