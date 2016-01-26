#Tensiometer_Press_Lt.py
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

def readfiles(file_list,c1,c2,c3):
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

data = readfiles(['waMVD116_Lt.txt'],11,12,13) #11,12,13
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_mvd = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]

tensMult = -0.1
tensOffs = 100

corrTensPres_kPa_1_mvd = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_mvd = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_mvd = corrTensPres_V_3 * tensMult + tensOffs


def init_plot(title, yMin=-90, yMax=25):
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
ytext = ('Pressure, kPa')

init_plot('Tensiometer Pressure at Marine View Drive & 116 St. SW')

plt.plot(column_0_mvd, corrTensPres_kPa_1_mvd, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0_mvd, corrTensPres_kPa_2_mvd, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0_mvd, corrTensPres_kPa_3_mvd, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MVD116_Tensiometer_Press_Lt.png')

# ------------------------

data = readfiles(['waWatertonA_Lt.txt'],12,13,14) #12,13,14
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_wca = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]

corrTensPres_kPa_1_wca = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_wca = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_wca = corrTensPres_V_3 * tensMult + tensOffs

init_plot('Tensiometer Pressure at Waterton Circle Station A')

plt.plot(column_0_wca, corrTensPres_kPa_1_wca, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0_wca, corrTensPres_kPa_2_wca, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0_wca, corrTensPres_kPa_3_wca, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MWatA_Tensiometer_Press_Lt.png')

# ------------------------

data = readfiles(['waWatertonB_Lt.txt'],11,12,13) #11,12,13
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0_wcb = np.array(data_1)[0][:,0]
corrTensPres_V_1 = np.array(data_1)[0][:,1]
corrTensPres_V_2 = np.array(data_1)[0][:,2]
corrTensPres_V_3 = np.array(data_1)[0][:,3]

corrTensPres_kPa_1_wcb = corrTensPres_V_1 * tensMult + tensOffs
corrTensPres_kPa_2_wcb = corrTensPres_V_2 * tensMult + tensOffs
corrTensPres_kPa_3_wcb = corrTensPres_V_3 * tensMult + tensOffs

init_plot('Tensiometer Pressure at Waterton Circle Station B')

plt.plot(column_0_wcb, corrTensPres_kPa_1_wcb, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0_wcb, corrTensPres_kPa_2_wcb, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0_wcb, corrTensPres_kPa_3_wcb, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

end_plot(name='MWatB_Tensiometer_Press_Lt.png')

def init_plot1(title, yMin=-90, yMax=25):
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext, fontsize=10)
    plt.ylabel(ytext, fontsize=10)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
#plt.xticks(np.arange(xMin,xMax+1))

def end_plot1(name=None, cols=5):
    plt.legend(loc=2, ncol=cols, fontsize=10, title='  Sensor Position & Depth, cm\nSCB         ALS-a         ALS-b')
    if name:
        plt.savefig(name, bbox_inches='tight')

try:
    init_plot1('Tensiometer Pressure at Mukilteo Stations')

    plt.plot(column_0_mvd, corrTensPres_kPa_1_mvd, linestyle='-', color='b', label='2 110')
    plt.plot(column_0_mvd, corrTensPres_kPa_2_mvd, linestyle='-', color='r', label='3 110')
    plt.plot(column_0_mvd, corrTensPres_kPa_3_mvd, linestyle='-', color='g', label='4 100')
    plt.plot(column_0_wca, corrTensPres_kPa_1_wca, linestyle='--', color='b', label='2 110')
    plt.plot(column_0_wca, corrTensPres_kPa_2_wca, linestyle='--', color='r', label='3 110')
    plt.plot(column_0_wca, corrTensPres_kPa_3_wca, linestyle='--', color='g', label='4 100')
    plt.plot(column_0_wcb, corrTensPres_kPa_1_wcb, linestyle='-.', color='b', label='2 110')
    plt.plot(column_0_wcb, corrTensPres_kPa_2_wcb, linestyle='-.', color='r', label='3 170')
    plt.plot(column_0_wcb, corrTensPres_kPa_3_wcb, linestyle='-.', color='g', label='4 177')

    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
    plt.gca().xaxis.set_minor_locator(mdates.DayLocator(interval=1))
    plt.gca().xaxis.set_major_locator(mdates.MonthLocator(interval=1))

    end_plot1(name='Muk_Tensiometer_Press_Lt.png', cols=3)
except:
    print('unable to print Muk_Tensiometer_Press_Lt.png')