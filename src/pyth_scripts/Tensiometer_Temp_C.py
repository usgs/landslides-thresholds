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

def init_plot(title, yMin=-10, yMax=40):
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
ytext = ('Temperature, deg C')

data = readfiles(['waMVD116_14d.txt'],14,15,16) #,14,15,16
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

init_plot('Tensiometer Temperature at Marine View Drive & 116 St. SW')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_Tensiometer_Temp.png')

# ------------------------

data = readfiles(['waWatertonA_14d.txt'],15,16,17) #,14,15,16
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

init_plot('Tensiometer Temperature at Waterton Circle Station A')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_Tensiometer_Temp.png')

# ------------------------

data = readfiles(['waWatertonB_14d.txt'],14,15,16) #,14,15,16
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
corrTensTemp_V_1 = np.array(data_1)[0][:,1]
corrTensTemp_V_2 = np.array(data_1)[0][:,2]
corrTensTemp_V_3 = np.array(data_1)[0][:,3]

corrTensTemp_kPa_1 = corrTensTemp_V_1 * tensMult + tensOffs
corrTensTemp_kPa_2 = corrTensTemp_V_2 * tensMult + tensOffs
corrTensTemp_kPa_3 = corrTensTemp_V_3 * tensMult + tensOffs

init_plot('Tensiometer Temperature at Waterton Circle Station B')

plt.plot(column_0, corrTensTemp_kPa_1, linestyle='-', color='b', label='Tensiometer 1')
plt.plot(column_0, corrTensTemp_kPa_2, linestyle='-', color='r', label='Tensiometer 2')
plt.plot(column_0, corrTensTemp_kPa_3, linestyle='-', color='g', label='Tensiometer 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_Tensiometer_Temp.png')
