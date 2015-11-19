import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
#from datetime import datetime
#import csv
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

# ------------------------
def readfiles1(file_list,c1):
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

data = readfiles1(['waWatertonA_14d.txt'],5)

column_0 = np.array(data)[0][:,0]
barometricPressure_raw = np.array(data)[0][:,1]

#Compute Barometric pressure
barometricPressure_kPa=(barometricPressure_raw*0.240+500)*0.1

#-------------------------

def readfiles(file_list,c1,c2,c3,c4):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.loadtxt(fname,
                               usecols=(0,c1,c2,c3,c4),
                               comments='#',    # skip comment lines
                               delimiter='\t',
                               converters = { 0 : strpdate2num('%Y-%m-%d %H:%M:%S') },
                               dtype=None))
    return data

data = readfiles(['waMVD116_14d.txt'],17,18,19,20) # 17,18,19,20
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
freq1 = np.array(data_1)[0][:,1]
thermRes1 = np.array(data_1)[0][:,2]
freq2 = np.array(data_1)[0][:,3]
thermRes2 = np.array(data_1)[0][:,4]
#freq1=float(freq1)
#freq2=float(freq2)

#'VW piezometer Serial numbers
#'VWP #1 = 83807
#'VWP #2 = 83808
#'VWP #1 Calibration Coefficients
C1_A = -0.000095792
C1_B = -0.0023260
C1_C = 828.53
tempCoeff1_m = 0.0380*6.89475729 #'Temp Coefficient, slope(m)
tempCoeff1_b = -0.762*6.89475729 #'Temp Coefficient, y-int(b)
tempOffset1 = 0.3 #'Offset Temp
tempCal1 = 20.2 #'Temp Calibrated
#'VWP #2 Calibration Coefficients
C2_A = -0.00010171
C2_B = 0.016517
C2_C = 772.93
tempCoeff2_m = 0.0208*6.89475729 #'Temp Coefficients
tempCoeff2_b = -0.414*6.89475729
tempOffset2 = 0.1 #'Offset Temp
tempCal2 = 20.2 #'Temp Calibrated

#    'Calculate thermistor temperature 'ThermTemp'
thermTemp1_degC =1/(1.4051E-3+2.369E-4*np.log(thermRes1)+1.019E-7*np.log(thermRes1)**3)
#thermTemp1_degC = (-23.50833439*((thermRes1/1000)**2)) + (227.625007*(thermRes1/1000))+(-341.217356417)
#    'Convert 'ThermTemp' to 'degC' and add 'TempOffset'
thermTemp1_degC = thermTemp1_degC-273.15+tempOffset1
#    'Calculate water level 'pHead' (kPa)
pHead1_kpa=(C1_A*freq1**2)+(C1_B*freq1)+(C1_C)
#        'Apply temperature corrections
pHead1_kpa = pHead1_kpa +((tempCal1-thermTemp1_degC)*tempCoeff1_m)+(tempCoeff1_b)
#     Apply barometric pressure correction, 1 standard atmosphere = 101.3 kPa
pHead1_kpa = pHead1_kpa - (barometricPressure_kPa -101.3)
#        'Convert 'pHead' from kpa to m, and shift by small offset
lvl1_m= pHead1_kpa*0.1019977334 + 0.1
#

#		'Calculate thermistor temperature 'ThermTemp'
thermTemp2_degC=1/(1.4051E-3+2.369E-4*np.log(thermRes2)+1.019E-7*np.log(thermRes2)**3)
#thermTemp2_degC = (-23.50833439*((thermRes2/1000)**2)) + (227.625007*(thermRes2/1000))+(-341.217356417)
#		'Convert 'ThermTemp' to 'degC' and add 'TempOffset'
thermTemp2_degC=thermTemp2_degC-273.15+tempOffset2
#		'Calculate water level 'pHead' (kPa)
pHead2_kpa =(C2_A*freq2**2)+(C2_B*freq2)+(C2_C)
#		'Apply temperature corrections
pHead2_kpa = pHead2_kpa +((tempCal2-thermTemp2_degC)*tempCoeff2_m)+(tempCoeff2_b)
#     Apply barometric pressure correction, 1 standard atmosphere = 101.3 kPa
pHead2_kpa = pHead2_kpa - (barometricPressure_kPa -101.3)
#		'Convert pressureKPA to m, and shift by small offset
lvl2_m = pHead2_kpa*0.1019977334 - 0.2

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

init_plot('Water Level at Marine View Drive & 116 St. SW')

plt.plot(column_0, lvl1_m, linestyle='-', color='b', label='Water Level 1')
plt.plot(column_0, lvl2_m, linestyle='-', color='r', label='Water Level 2')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MVD116_lvl.png')

# ------------------------

data = readfiles(['waWatertonA_14d.txt'],18,19,20,21) # 18,19,20,21
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
freq1 = np.array(data_1)[0][:,1]
thermRes1 = np.array(data_1)[0][:,2]
freq2 = np.array(data_1)[0][:,3]
thermRes2 = np.array(data_1)[0][:,4]

#VW Piezometer Calibration Coefficients

#'VWP #3 10-1786, site3-1 2850
C2_0 = 9.674485E2
C2_1 = -2.293154E-2
C2_2 = -1.132928E-1
C2_3 = -1.070764E-4
C2_4 = 1.155441E-4
C2_5 = -2.123954E-3
#
#'VWP #4 10-1784
C1_0 = 1.075071E3
C1_1 = -3.277043E-2
C1_2 =1.011760E-1
C1_3 =-1.149217E-4
C1_4 =1.661176E-4
C1_5 =-8.454856E-3

#Compute Thermistor Temperature and Water Level
thermTemp1_degC = 1/(1.401E-3 + 2.377E-4*np.log(thermRes1) + 9.730E-8*np.log(thermRes1)**3)-273.15
lvl1_m = (C1_0 + (C1_1*freq1) + (C1_2*thermTemp1_degC) + (C1_3*(freq1**2)) + (C1_4*freq1*thermTemp1_degC) + (C1_5*(thermTemp1_degC**2))) * 0.70432

thermTemp2_degC = 1/(1.401E-3 + 2.377E-4*np.log(thermRes2) + 9.730E-8*np.log(thermRes2)**3)-273.15
lvl2_m = (C2_0 + (C2_1*freq2) + (C2_2*thermTemp2_degC) + (C2_3*(freq2**2)) + (C2_4*freq2*thermTemp2_degC) + (C2_5*(thermTemp2_degC**2))) * 0.70432

#     Apply barometric pressure correction, 1 standard atmosphere = 101.3 kPa
lvl1_m = lvl1_m - (barometricPressure_kPa -101.3)/6.895
lvl2_m = lvl2_m - (barometricPressure_kPa -101.3)/6.895

#'Convert water level from PSI to meters and shift by small offset.
lvl1_m = lvl1_m*0.1019977334 - 1.1
lvl2_m = lvl2_m*0.1019977334 + 1.5

init_plot('Water Level at Waterton Circle Station A')

plt.plot(column_0, lvl1_m, linestyle='-', color='b', label='Water Level 4')
plt.plot(column_0, lvl2_m, linestyle='-', color='r', label='Water Level 3')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatA_lvl.png')

# ------------------------

data = readfiles(['waWatertonB_14d.txt'],17,18,19,20) # 17,18,19,20
data_1 = ma.fix_invalid(data, fill_value = 'nan')

column_0 = np.array(data_1)[0][:,0]
freq1 = np.array(data_1)[0][:,1]
thermRes1 = np.array(data_1)[0][:,2]
freq2 = np.array(data_1)[0][:,3]
thermRes2 = np.array(data_1)[0][:,4]

#
#'VW piezometer Serial numbers
#'VWP #5 = 2850
#'VWP #6 = 2851
#'VWP #5 Calibration Coefficients
C1_A = 0.000057403
C1_B = -0.0099641
C1_C = -124.16
tempCoeff1_m = -0.0044*6.89475729 #Temp Coefficient, slope(m)
tempCoeff1_b = 0*6.89475729 #Temp Coefficient, y-int(b)
tempOffset1 = -1.6 #Offset Temp
tempCal1 = 23.5 #Temp Calibrated
#'VWP #6 Calibration Coefficients
C2_A = 0.000053431
C2_B = -0.0025086
C2_C = -137.43
tempCoeff2_m = -0.0020*6.89475729 #Temp Coefficients
tempCoeff2_b = 0*6.89475729
tempOffset2 = -1.4 #Offset Temp
tempCal2 = 23.5 #Temp Calibrated
#
#    'Calculate thermistor temperature 'ThermTemp'
thermTemp1_degC = (-23.50833439*((thermRes1/1000)**2)) + (227.625007*(thermRes1/1000))+(-341.217356417)
#    'Convert 'ThermTemp' to 'degC' and add 'TempOffset'
thermTemp1_degC = thermTemp1_degC+tempOffset1
#    'Calculate water level 'pHead' (kPa)
pHead1_kpa=(C1_A*freq1**2)+(C1_B*freq1)+(C1_C)
#        'Apply temperature corrections
pHead1_kpa = pHead1_kpa +((tempCal1-thermTemp1_degC)*tempCoeff1_m)+(tempCoeff1_b)
#     Apply barometric pressure correction, 1 standard atmosphere = 101.3 kPa
pHead1_kpa = pHead1_kpa - (barometricPressure_kPa -101.3)
#        'Convert 'pHead' from kpa to m, and shift by small offset
lvl1_m= pHead1_kpa*0.1019977334
#
#    'Calculate thermistor temperature 'ThermTemp'
thermTemp2_degC = (-23.50833439*((thermRes2/1000)**2)) + (227.625007*(thermRes2/1000))+(-341.217356417)
#    'Convert 'ThermTemp' to 'degC' and add 'TempOffset'
thermTemp2_degC=thermTemp2_degC+tempOffset2
#    'Calculate water level 'pHead' (kPa)
pHead2_kpa =(C2_A*freq2**2)+(C2_B*freq2)+(C2_C)
#    'Apply temperature corrections
pHead2_kpa = pHead2_kpa +((tempCal2-thermTemp2_degC)*tempCoeff2_m)+(tempCoeff2_b)
#     Apply barometric pressure correction, 1 standard atmosphere = 101.3 kPa
pHead2_kpa = pHead2_kpa - (barometricPressure_kPa -101.3)
#    'Convert pressureKPA to m, and shift by small offset
lvl2_m = pHead2_kpa*0.1019977334
#

init_plot('Water Level at Waterton Circle Station B')

plt.plot(column_0, lvl1_m, linestyle='-', color='b', label='Water Level 5')
plt.plot(column_0, lvl2_m, linestyle='-', color='r', label='Water Level 6')

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

end_plot(name='MWatB_lvl.png')

