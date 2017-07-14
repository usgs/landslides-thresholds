# RALHS.py calls the fortran programs nwsfmt and thresh to compute conditions relative to 
# rainfall thresholds for Seattle, WA, and then plots the results for 
# the Remote Automated Landslide Hydrologic Stations (RALHS).
# By Sarah J. Fischer and Rex L. Baum, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
#
# Get libraries
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import csv
import numpy as np
from numpy import ma
import datetime
import time
import os
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import glob
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
import datetime as dt
import matplotlib.dates as mdates

# Set date.txt
g = open('date.txt','w')
print >>g, time.strftime("%c %Z")
g.close()

# Run nwsfmt to Format Data files from the RALHS Stations
sys_name = os.name
if sys_name == 'nt':
    nwsfmt_path=os.path.normpath('../../bin/nwsfmt.exe')
else:
    nwsfmt_path=os.path.normpath('../../bin/nwsfmt')
print(nwsfmt_path)
os.system(nwsfmt_path)

# Run thresh to compute Precipitation Thresholds
# If os.name returns "nt' then use a Windows-specific path name
if sys_name == 'nt':
    thresh_path=os.path.normpath('../../bin/thresh.exe')
else:
    thresh_path=os.path.normpath('../../bin/thresh')
print(thresh_path)
os.system(thresh_path)

# Plot Incremental Precipitation
# Recent and antecedent precipitation threshold
def Threshold(numbers,ra_x_min,ra_x_max,ra_intercept,ra_slope): # Compute threshold line within defined limits
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        if ra_x_min<=x and x<=ra_x_max:
            ret[0].append(x)
            ret[1].append(ra_intercept - (ra_slope*x))
    return ret

def Extrapolated_threshold(numbers,ra_intercept,ra_slope): # Extrapolate beyond defined limits of threshold
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(ra_intercept - (ra_slope*x))
    return ret

def plot_threshold(): # Draw and label threshold line
    """ plot Threshold(-) and
        Extrapolated_threshold(:)"""
    x = np.arange(0,16,.5)
    slide = Threshold(x,ra_x_min,ra_x_max,ra_intercept,ra_slope)
    plt.plot(slide[0], slide[1], 'r-',
             linewidth=2, label=ra_label)
    ex_slide = Extrapolated_threshold(x,ra_intercept,ra_slope)
    plt.plot(ex_slide[0], ex_slide[1], 'r:')
#     hi_prob = Threshold(x,hip_ra_x_min,hip_ra_x_max,hip_ra_intercept,hip_ra_slope)
#     plt.plot(hi_prob[0], hi_prob[1], 'm-',
#              linewidth=2, label=hip_ra_label)
#     ex_hi_prob = Extrapolated_threshold(x,hip_ra_intercept,hip_ra_slope)
#     plt.plot(ex_hi_prob[0], ex_hi_prob[1], 'm:')
   
# Set Threshold parameters
ra_x_min = 0.5
ra_x_max = 4.75
ra_intercept = 3.5
ra_slope = 0.67
ra_label = 'Threshold, P3=3.5-0.67*P15'

# hip_ra_x_min = 1.0
# hip_ra_x_max = 7.5
# hip_ra_intercept = 3.35
# hip_ra_slope = 0.18
# hip_ra_label = 'High likelihood, P3=3.35-0.18*P15'

def readfiles(file_list): # Read values from table of current conditions
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

def init_plot(title, xMin=0, xMax=15, yMin=0, yMax=8): # Set plot dimensions and parameters
    """ Init plot """
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers + date_text, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=3): # Draw legend and set output
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=0.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to cumulative precipitation threshold'
              ' for the occurrence of landslide'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('P15: 15-day cumulative precipitation prior to 3-day'
         'precipitation, in inches')
ytext = 'P3: 3-day cumulative precipitation, in inches'

# get date of latest data
fin = open('data/ThUpdate.txt', 'rt')
date_text = fin.read()
fin.close()

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('p', 'b', 'VH'),
            '02':('D', 'm', 'LS'),
            '03':('*', 'c', 'M1'),
            '04':('^', 'r', 'M2')
            }

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Draw plot of recent and antecedent precipitation threshold
init_plot('Current conditions in Mukilteo, Washington,')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i, d in enumerate(data): # Scatter plot of current conditions
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label=markers[str(d[1])][2], s=150)

plot_threshold()

end_plot(name='Muk_cmtr.png')

# ------------------------

#Plot Precipitation History for 3-Day/Prior 15-Day Threshold
init_plot('360-hour precipitation history in Mukilteo, Washington')

data01 = readfiles(['data/ThTSplot360hour01.txt'])
for d in data01: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Mukilteo, VH, history')

data = readfiles(['data/ThSta01.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of current conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='MVD116_CT_hist.png', cols=3)

# ------------------------

init_plot('360-hour precipitation history in Mukilteo, Washington')

data02 = readfiles(['data/ThTSplot360hour02.txt'])
for d in data02: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Mukilteo, LS, history')

data = readfiles(['data/ThSta02.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of current conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='MWatA_CT_hist.png', cols=3)

# ------------------------

init_plot('360-hour precipitation history in Mukilteo, Washington')

data03 = readfiles(['data/ThTSplot360hour03.txt'])
for d in data03: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='M1, history')

data = readfiles(['data/ThSta03.txt'])
for d in data: # Trace 15-day history of conditions relative to threshold
    plt.scatter(d[2], d[3], # Scatter plot of current conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='MLP_CT_hist.png', cols=3)

# ------------------------

init_plot('360-hour precipitation history in Mukilteo, Washington')

data04 = readfiles(['data/ThTSplot360hour04.txt'])
for d in data04: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='M2, history')

data = readfiles(['data/ThSta04.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of current conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='MWWD_CT_hist.png', cols=3)

#Plot Precipitation Intensity and Duration
def intensdur(numbers,dur_min,dur_max,coeff,expon): # Compute values of I-D threshold curve within defined limits
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        if dur_min<=x and x<=dur_max:
            ret[0].append(x)
            ret[1].append(coeff*(x**(expon)))
    return ret

def Extrapolated_intensdur(numbers,coeff,expon): # Compute values of I-D threshold curve beyond defined limits
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(coeff*(x**(expon)))
    return ret

def plot_intensdur(): # Draw threshold curve
    """ plot intensdur(solid) and
        Extrapolated_intensdur(dotted)"""
    x = np.arange(1,70,.5)
#     slide= intensdur(x,dur_min,dur_max,coeff,expon)
#     plt.plot(slide[0], slide[1], 'm-',
#              linewidth=2, label=id_label)
#     ex_slide = Extrapolated_intensdur(x,coeff,expon)
#     plt.plot(ex_slide[0], ex_slide[1], 'm:')
    g_slide= intensdur(x,godt_dur_min,godt_dur_max,godt_coeff,godt_expon)
    plt.plot(g_slide[0], g_slide[1], 'r-',
             linewidth=2, label=godt_id_label)
    ex_g_slide = Extrapolated_intensdur(x,godt_coeff,godt_expon)
    plt.plot(ex_g_slide[0], ex_g_slide[1], 'r:')

# Set Threshold parameters
# dur_min = 12.
# dur_max = 60.
# coeff = 0.193
# expon = -0.34
# id_label = 'I=0.193*D^(-0.34)'

godt_dur_min = 14.
godt_dur_max = 66.
godt_coeff = 3.257
godt_expon = -1.13
godt_id_label = 'I=3.257*D^(-1.13)'

def readfiles(file_list): # Import data from a list of input files
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

def init_plot(title, xMin=0, xMax=70, yMin=0.0, yMax=0.6): #Set plot dimensions and paramters
    """ Init plot """
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers + date_text, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=3): # Set legend and output
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=0.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to precipitation intensity and duration threshold'
              ' for the occurrence of landslide'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('D: Rainfall duration, in hours')
ytext = ('I: Average intensity, in inches per hour')


""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('p', 'b', 'VH'),
            '02':('D', 'm', 'LS'),
            '03':('*', 'c', 'M1'),
            '04':('^', 'r', 'M2')
            }

# Make plots of I-D threshold conditions
init_plot('Current conditions in Mukilteo, Washington,')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i, d in enumerate(data): # Scatter plot of current conditions relative to threshold
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

end_plot(name='Muk_idtr.png')

# Plot Antecedent Water Index
def AWI(numbers): # Define threshold value
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(0.02)
    return ret

def plot_AWI(): # Draw threshold line
    """ plot Threshold(Black)"""
    slide= AWI(x)
    plt.plot(slide[0], slide[1], 'k-',
             linewidth=2, label='Wet Antecedent Conditions: AWI=0.02')

def readfiles(file_list): # Import data from text files
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

def init_plot(title, yMin=-0.2, yMax=.1): # Set plot parameters and dimensions
    """ Init plot """
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=3): # Set legend and output
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to the Antecedent Water Index'
              ' for the occurrence of landslide'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )

xtext = ('Date and time')
ytext = ('Antecedent Water Index, in meters')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'VH'),
           ('m-', 'LS'),
           ('c-', 'M1'),
           ('r-', 'M2')
           ]

# Make plots of AWI
init_plot('360-hour Precipitation History in Mukilteo, Washington, and Vicinity,')

data_list = [data01, data02, data03, data04]
for i in range(4):
    for d in data_list[i]: # Draw time-series plots of AWI at all stations
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_AWI()

end_plot(name='Muk_awi.png')

# Plot Time Series I-D Threshold index for each station
def ID(numbers): # Define threshold for ID-threshold index plot (threshold index = 1.0)
    """ list of lists [[x's], [y's]]"""
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(1.0)
    return ret

def plot_ID(): # Draw and label threshold index
    """ plot Threshold(Black)"""
    slide= ID(x)
    plt.plot(slide[0], slide[1], 'k-',
             linewidth=2, label='I-D Threshold, ' + godt_id_label)

def init_plot(title, yMin=0., yMax=2.): # Set plot parameters and dimensions
    """ Init plot """
    plt.figure(figsize=(12, 6))
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin,yMax)
    plt.grid()

disclamers = ('\n with respect to the Intensity-Duration Index'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date and time')
ytext = ('Intensity-Duration Index')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'VH'),
           ('m-', 'LS'),
           ('c-', 'M1'),
           ('r-', 'M2')
           ]

init_plot('360-hour Intensity-Duration History in Mukilteo, Washington')

for i in range(4): # draw time series of threshold index values, all stations
    for d in data_list[i]:
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_ID()

end_plot(name='Muk_id_index.png')
