#test_py
#For automated download of hourly observations from NWS website and computation of rainfall
# intensities and cumulative amounts for comparison to thresholds:
# By Rex L. Baum and Sarah J. Fischer, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
#
# Get libraries
import os
import sys
import time
import calendar
time_now=calendar.timegm(time.gmtime())
from xml.dom.minidom import parse
import pandas as pd
import time
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import glob
from matplotlib.ticker import MultipleLocator, FormatStrFormatter

sys_name = os.name
# Run thresh to compute Precipitation Thresholds
# If os.name returns "nt' then use a Windows-specific path name
if sys_name == 'nt':
    thresh_path=os.path.normpath('../../bin/thresh.exe')
else:
    thresh_path=os.path.normpath('../../bin/thresh')
print(thresh_path)
os.system(thresh_path)

# Plot Incremental Precipitation
# Function to compute threshold line
def Threshold(numbers): # Compute threshold line within defined limits
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        if 0.5<=x and x<=4.75:
            ret[0].append(x)
            ret[1].append(3.5 - (0.67*x))
    return ret

def Extrapolated_threshold(numbers): # Extrapolate beyond defined limits of threshold
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(3.5 - (0.67*x))
    return ret

def plot_threshold(): # Draw and label threshold line
    """ plot Threshold(Red) and
        Extrapolated_threshold(Black)"""
    x = np.arange(0,16,.5)
    slide= Threshold(x)
    plt.plot(slide[0], slide[1], 'r-',
             linewidth=2, label='Threshold, P3=3.5-0.67*P15')
    ex_slide = Extrapolated_threshold(x)
    plt.plot(ex_slide[0], ex_slide[1], 'k:')

def readfiles(file_list): # Read values from table of current conditions
    """ read <TAB> delimited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',    # skip comment lines
                                  delimiter='\t',
                                  dtype ="|S", autostrip=True).T)
    return data

def init_plot(title, xMin=0, xMax=15, yMin=0, yMax=8): # Set plot parameters
    """ Init plot """
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers + date_text, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=3): # Set legend parameters and output target
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=0.,  scatterpoints=1)
    if name:
    	plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to cumulative precipitation threshold'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('P15: 15-day cumulative precipitation prior to 3-day '
         'precipitation, inches')
ytext = 'P3: 3-day cumulative precipitation, inches'
              
# get date of latest data
fin = open('data/ThUpdate.txt', 'rt')
date_text = fin.read()
fin.close()              

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('v', 'b', 'Seattle/Boeing Field'),
            '02':('s', 'm', 'Everett/Paine Field'),
            '03':('h', 'c', 'Seattle-Tacoma Airport'),
            '04':('o', 'r', 'Tacoma Narrows')
            }

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# draw plot of current conditions for recent and antecedent precipitation threshold at all stations
init_plot('Current conditions near Seattle, Washington,')
data = readfiles(glob.glob('data/ThSta*.txt'))

for i, d in enumerate(data): # assign markers and generate scatter plot 
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label=markers[str(d[1])][2], s=150)

plot_threshold()

end_plot(name='cmtrsea.png')

#Plot Precipitation History for Recent-Antecedent Threshold at Boeing field 
init_plot('360-hour precipitation history near Seattle, Washington')

#set output 'boeing.png'
data01 = readfiles(['data/ThTSplot360hour01.txt'])
for d in data01:
    plt.plot(d[2], d[3], label='Seattle, Boeing Field, history')

data = readfiles(['data/ThSta01.txt'])
for d in data:
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='boeing.png', cols=3)

#Plot Precipitation History for Recent-Antecedent Threshold at SeaTac
init_plot('360-hour precipitation history near Seattle, Washington')

#set output 'seatac.png'
data03 = readfiles(['data/ThTSplot360hour03.txt'])
for d in data03:
    plt.plot(d[2], d[3], label='Seattle-Tacoma Airport, history')

data = readfiles(['data/ThSta03.txt'])
for d in data:
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='seatac.png', cols=3)

# Plot Precipitation history for Recent-Antecedent Threshold at Everett
init_plot('360-hour precipitation history in Everett, Washington')

#set output 'paine.png'
data02 = readfiles(['data/ThTSplot360hour02.txt'])
for d in data02:
    plt.plot(d[2], d[3], label='Everett, Paine Field, history')

data = readfiles(['data/ThSta02.txt'])
for d in data:
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='paine.png', cols=3)

# Plot Precipitation history for Recent-Antecedent Threshold at Tacoma Narrows
init_plot('360-hour precipitation history in Tacoma, Washington')

#set output 'tacoma.png'
data04 = readfiles(['data/ThTSplot360hour04.txt'])
for d in data04:
    plt.plot(d[2], d[3], label='Tacoma Narrows, history')

data = readfiles(['data/ThSta04.txt'])
for d in data:
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='tacoma.png', cols=3)

#Plot Precipitation Intensity and Duration
def intensdur(numbers):
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        if 14<=x and x<=66:
            ret[0].append(x)
            ret[1].append(3.257*(x**(-1.13)))
    return ret

def Extrapolated_intensdur(numbers):
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(3.257*(x**(-1.13)))
    return ret

def plot_intensdur():
    """ plot intensdur(Red) and
        Extrapolated_intensdur(Black)"""
    x = np.arange(1,70,.5)
    slide= intensdur(x)
    plt.plot(slide[0], slide[1], 'r-',
             linewidth=2, label='I=3.257D^(-1.13)')
    ex_slide = Extrapolated_intensdur(x)
    plt.plot(ex_slide[0], ex_slide[1], 'k:')

def readfiles(file_list):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',    # skip comment lines
                                  delimiter='\t',
                                  dtype ="|S", autostrip=True).T)
    return data

def init_plot(title, xMin=0, xMax=70, yMin=0.0, yMax=0.6):
    """ Init plot """
    plt.figure(figsize=(12, 6)) 
    plt.title(title + disclamers + date_text, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=3):
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=0.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to precipitation intensity and duration threshold'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('D: Rainfall duration, hours')
ytext = ('I: Average intensity, in/hr')


""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('v', 'b', 'Seattle/Boeing Field'),
            '02':('s', 'm', 'Everett/Paine Field'),
            '03':('h', 'c', 'Seattle-Tacoma Airport'),
            '04':('o', 'r', 'Tacoma Narrows')
            }

init_plot('Current conditions near Seattle, Washington,')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i, d in enumerate(data):
    plt.scatter(d[6], d[4],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label=markers[str(d[1])][2], s=150) 


majorLocator = MultipleLocator(10)
majorFormatter = FormatStrFormatter('%d')
minorLocator = MultipleLocator(2)

plot_intensdur()

plt.gca().xaxis.set_major_locator(majorLocator)
plt.gca().xaxis.set_major_formatter(majorFormatter)
# for the minor ticks, use no labels; default NullFormatter
plt.gca().xaxis.set_minor_locator(minorLocator)

end_plot(name='idtrsea.png')

#Plot Antecedent Water Index
def AWI(numbers):
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(0.02)
    return ret

def plot_AWI():
    """ plot Threshold(Red) and
        Extrapolated_intensdur(Black)"""
    slide= AWI(x)
    plt.plot(slide[0], slide[1], 'k-',
             linewidth=2, label='Wet Antecedent Conditions: AWI=0.02')

def readfiles(file_list):
    """ read <TAB> delemited files as strings
        ignoring '# Comment' lines """
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',    # skip comment lines
                                  delimiter='\t',
                                  dtype ="|S", autostrip=True).T)
    return data

def init_plot(title, yMin=-0.2, yMax=.1):
    """ Init plot """
    plt.figure(figsize=(12, 6)) 
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=3):
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to the Antecedent Water Index'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Antecedent Water Index, m')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'Seattle/Boeing Field'),
           ('m-', 'Everett/Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows')
           ]

init_plot('360-hour Precipitation History in Seattle, Washington, & vicinity,')
import datetime as dt

import matplotlib.dates as mdates

data_list = [data01, data02, data03, data04]
for i in range(4):
    for d in data_list[i]:
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_AWI()

end_plot(name='awi.png')

init_plot('360-hour Precipitation History at Everett Paine Field, KPAE,')
i = 1
for d in data_list[i]:
    x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
    plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_AWI()

end_plot(name='awi_KPAE.png')

def ID(numbers):
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(1.0)
    return ret

def plot_ID():
    """ plot Threshold(Red) and
        Extrapolated_intensdur(Black)"""
    slide= ID(x)
    plt.plot(slide[0], slide[1], 'k-',
             linewidth=2, label='Intensity-duration Threshold')

def init_plot(title, yMin=0., yMax=2.):
    """ Init plot """
    plt.figure(figsize=(12, 6)) 
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()

disclamers = ('\n with respect to the Intensity-Duration Index'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date & Time')
ytext = ('Intensity-Duration Index, m')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'Seattle/Boeing Field'),
           ('m-', 'Everett/Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows')
           ]

init_plot('360-hour Intensity-Duration History in Seattle, Washington, & vicinity,')


for i in range(4):
    for d in data_list[i]:
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_ID()

end_plot(name='id_index.png')

init_plot('360-hour Intensity-Duration History at Everett Paine Field, KPAE,')

i = 1
for d in data_list[i]:
    x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
    plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_ID()

end_plot(name='id_index_KPAE.png')
