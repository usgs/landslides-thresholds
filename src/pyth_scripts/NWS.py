#NWS_py
#For automated download of hourly observations from NWS website and computation of rainfall
# intensities and cumulative amounts for comparison to thresholds for Seattle Washington:
# By Sarah J. Fischer and Rex L. Baum, USGS 2015-2016
# Developed for Python 2.7, and requires compatible versions of numpy, pandas, and matplotlib.
# This script contains parameters specific to a particular problem. 
# It can be used as a template for other sites.
# This script also requires Cygwin for Windows installations.
#
# Get libraries
import os
import sys
import time
import calendar
from xml.dom.minidom import parse
import pandas as pd
import time
import datetime as dt
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import glob
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
import matplotlib.dates as mdates

time_now=calendar.timegm(time.gmtime())
# Define functions to download weather data for different operating systems
# Function for use on Linux and MacOSX
#
def get_weather_xml(stationName):
    file_stat = os.path.exists(stationName+'.xml')
    user_agent = ' -A "Mozilla/4.0" '
    url = 'http://www.wrh.noaa.gov/mesowest/getobextXml.php'
    values1 = ' -c - -js -d sid=' + stationName
    values2 = ' -c - -js -d sid=' + stationName + ' -d num=' + '24'
    values3 = ' -c - -js -d sid=' + stationName + ' -d num=' + '168'
    values4 = ' -c - -js -d sid=' + stationName + ' -d num=' + '500'
    outfil = ' -o ' + stationName + '.xml'
    if file_stat:
        fin = open(stationName+'_ut.txt', 'rt')
        try:
            time_then = fin.readline()
            time_dif = time_now - int(time_then)
        except:
            time_dif = 604801
            print('Error reading '+ stationName + '_ut.txt or converting ', time_then ,' to integer')
        if time_dif < 10800: # 3 hours
            try:
                curl_cmd = 'curl' + values1 + outfil + user_agent + url
                print(curl_cmd)
                os.system(curl_cmd)
            except:
                print('* Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        elif time_dif < 86400: # 24 hours
            try:
                curl_cmd = 'curl' + values2 + outfil + user_agent + url
                print(curl_cmd)
                os.system(curl_cmd)
            except:
                print('** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        elif time_dif < 604800: # 1 week
            try:
                curl_cmd = 'curl' + values3 + outfil + user_agent + url
                print(curl_cmd)
                os.system(curl_cmd)
            except:
                print('** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        else:
            try:
                curl_cmd = 'curl' + values4 + outfil + user_agent + url
                print(curl_cmd)
                os.system(curl_cmd)
            except:
                print('*** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
    else:
        try:
            curl_cmd = 'curl' + values4 + outfil + user_agent + url
            print(curl_cmd)
            os.system(curl_cmd)
        except:
            print('**** Could not download ' + stationName + '.xml')

# Function for use on 64-bit Windows with cygwin installed
#
def cyg_get_weather_xml(stationName):
    file_stat = os.path.exists(stationName+'.xml')
    user_options = ' --no-cookies '
    url = '"http://www.wrh.noaa.gov/mesowest/getobextXml.php'
    values1 = '?sid=' + stationName + '"'
    values2 = '?sid=' + stationName + '&num=' + '24"'
    values3 = '?sid=' + stationName + '&num=' + '168"'
    values4 = '?sid=' + stationName + '&num=' + '500"'
    outfil = ' -O ' + stationName + '.xml '
    if file_stat:
        fin = open(stationName+'_ut.txt', 'rt')
        try:
            time_then = fin.readline()
            time_dif = time_now - int(time_then)
        except:
            time_dif = 604801
            print('Error reading '+ stationName + '_ut.txt or converting ', time_then ,' to integer')
        if time_dif < 10800: # 3 hours
            try:
                wget_cmd = 'C:\\cygwin64\\bin\\wget.exe ' + outfil + url + values1
                print(wget_cmd)
                os.system(wget_cmd)
            except:
                print('* Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        elif time_dif < 86400: # 24 hours
            try:
                wget_cmd = 'C:\\cygwin64\\bin\\wget.exe ' + outfil + url + values2
                print(wget_cmd)
                os.system(wget_cmd)
            except:
                print('** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        elif time_dif < 604800: # 1 week
            try:
                wget_cmd = 'C:\\cygwin64\\bin\\wget.exe ' + outfil + url + values3
                print(wget_cmd)
                os.system(wget_cmd)
            except:
                print('*** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
        else:
            try:
                wget_cmd = 'C:\\cygwin64\\bin\\wget.exe ' + outfil + url + values4
                print(wget_cmd)
                os.system(wget_cmd)
            except:
                print('**** Could not download ' + stationName + '.xml')
                print('time_dif = ', time_dif)
    else:
        try:
            wget_cmd = 'C:\\cygwin64\\bin\\wget.exe ' + outfil + url + values4
            print(wget_cmd)
            os.system(wget_cmd)
        except:
            print('***** Could not download ' + stationName + '.xml')

# .............................................................................
# Download recent weather data
sys_name = os.name
if sys_name == 'nt':
	if cyg_get_weather_xml('KBFI') > 0 :
		KBFI_stat = False
	else:
		KBFI_stat = True
	if cyg_get_weather_xml('KPAE') > 0:
		KPAE_stat = False
	else:
		KPAE_stat = True
	if cyg_get_weather_xml('KSEA') > 0:
		KSEA_stat = False
	else:
		KSEA_stat = True
	if cyg_get_weather_xml('KTIW') > 0:
		KTIW_stat = False
	else:
		KTIW_stat = True
else:
	if get_weather_xml('KBFI') > 0 :
		KBFI_stat = False
	else:
		KBFI_stat = True
	if get_weather_xml('KPAE') > 0:
		KPAE_stat = False
	else:
		KPAE_stat = True
	if get_weather_xml('KSEA') > 0:
		KSEA_stat = False
	else:
		KSEA_stat = True
	if get_weather_xml('KTIW') > 0:
		KTIW_stat = False
	else:
		KTIW_stat = True


#Filter XML Tags and Unneeded Data, Save Results to .txt File

# Function to extract rainfall data from XML files and save in a format usable by the program thresh. 
# Generalized and error handlers added 19 Feb 2016, RLB
def read_station_data(stationName):
    try:
        xml = parse(stationName + '.xml')
        try:
            percp = 0
            for station in xml.getElementsByTagName('station'):
                for ob in station.getElementsByTagName('ob'):
                    # Convert time string to time_struct (ignoring last 4 chars ' PDT' before 2/8/2016)
                    percp = False
                    ob_utime = ob.getAttribute('utime')
                    utimes.append(ob_utime)
                    #        ob_time = time.strptime(ob.getAttribute('time')[:-4],'%d %b %I:%M %p') # Used before 2/5/2016 when NWS changed format of its XML files and removed the Time zone
                    ob_time = time.strptime(ob.getAttribute('time')[:],'%d %b %I:%M %p') # Revised 2/8/2015, RLB
                    if ob_time.tm_min == 53:
                        for variable in ob.getElementsByTagName('variable'):
                            if variable.getAttribute('var') == 'PCP1H':
                                percp = True
                                # UnIndent if you want all variables
                                if variable.getAttribute('value') == 'T':
                                    data.append([ob_time.tm_mday,
                                                 ob_time.tm_hour,
                                                 ob_time.tm_min,
                                                 0])
                                elif float(variable.getAttribute('value')) >= 0:
                                    data.append([ob_time.tm_mday,
                                                 ob_time.tm_hour,
                                                 ob_time.tm_min,
                                                 variable.getAttribute('value')])
                        if not percp:
                            # If PCP1H wasn't found add as 0
                            data.append([ob_time.tm_mday,
                                         ob_time.tm_hour,
                                         ob_time.tm_min,
                                         0])
        
            with open(stationName + '.txt', 'w') as file:
                file.writelines('\t'.join(map(str,i)) + '\n' for i in data)
            with open(stationName + '_ut.txt', 'w') as file1:
                file1.writelines(max(utimes))
            max_times.append(max(utimes))
        except:
            print('Check for format error in extracting data from xml')
    except:
        print('File ' + stationName +'.xml empty')

#KBFI, parse data if file download successful (KBFI_stat = True)
data = []
utimes = []
max_times = []
if KBFI_stat:
    read_station_data('KBFI')
else:
    print('Skipping file KBFI.xml')

#KPAE, parse data if file download successful (KBFI_stat = True)
data = []
utimes = []
if KPAE_stat:
    read_station_data('KPAE')
else:
    print('Skipping file KPAE.xml')

#KSEA, parse data if file download successful (KBFI_stat = True)
data = []
utimes = []
if KSEA_stat:
    read_station_data('KSEA')
else:
    print('Skipping file KSEA.xml')

#KTIW, parse data if file download successful (KBFI_stat = True)
data = []
utimes = []
if KTIW_stat:
    read_station_data('KTIW')
else:
    print('Skipping file KTIW.xml')

try:
    latest_time = float(max(max_times))
except:
    print('max_times is empty')
    sys.exit('Exiting program <NWS.py> due to no new data')

date_str = time.strftime("%a %b %d %X %Y", time.gmtime(latest_time))
with open('date.txt', 'w') as file:
    file.writelines(date_str)

#Run nwsfmt to format data files from Weather.gov
sys_name = os.name
if sys_name == 'nt':
    nwsfmt_path=os.path.normpath('../../bin/nwsfmt.exe')
else:
    nwsfmt_path=os.path.normpath('../../bin/nwsfmt')
print(nwsfmt_path)
os.system(nwsfmt_path)

#Run thresh to compute precipitation thresholds
# If os.name returns "nt' then use a Windows-specific path name
if sys_name == 'nt':
    thresh_path=os.path.normpath('../../bin/thresh.exe')
else:
    thresh_path=os.path.normpath('../../bin/thresh')
print(thresh_path)
os.system(thresh_path)

#Plot Incremental Precipitation

# Functions for plotting Recent and Antecedent precipitation threshold
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

def plot_threshold():  # Draw and label threshold line
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
   
# Set threshold parameters
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

def readfiles(file_list):  # Read values from table of current conditions
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
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('P15: 15-day cumulative precipitation prior to 3-day '
         'precipitation, in inches')
ytext = 'P3: 3-day cumulative precipitation, in inches'
              
# get date of latest data
fin = open('data/ThUpdate.txt', 'rt')
date_text = fin.read()
fin.close()              

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('v', 'b', 'Seattle, Boeing Field'),
            '02':('s', 'm', 'Everett, Paine Field'),
            '03':('h', 'c', 'Seattle-Tacoma Airport'),
            '04':('o', 'r', 'Tacoma Narrows Airport')
            }

# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Draw plot of recent anad antecedent precipitation threshold
init_plot('Current conditions near Seattle, Washington,')
data = readfiles(glob.glob('data/ThSta*.txt'))

for i, d in enumerate(data): # Scatter plot of current conditions
    plt.scatter(d[2], d[3],
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label=markers[str(d[1])][2], s=150)

plot_threshold()

end_plot(name='cmtrsea.png')

#Plot Precipitation Histories for 3-Day/Prior 15-Day Threshold
init_plot('360-hour precipitation history near Seattle, Washington,')

#set output 'boeing.png'
data01 = readfiles(['data/ThTSplot360hour01.txt'])
for d in data01: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Seattle, Boeing Field, history')

data = readfiles(['data/ThSta01.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of latest conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='boeing.png', cols=3)

init_plot('360-hour precipitation history near Seattle, Washington,')

#set output 'seatac.png'
data03 = readfiles(['data/ThTSplot360hour03.txt'])
for d in data03: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Seattle-Tacoma Airport, history')

data = readfiles(['data/ThSta03.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of latest conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='seatac.png', cols=3)

init_plot('360-hour precipitation history in Everett, Washington,')

#set output 'paine.png'
data02 = readfiles(['data/ThTSplot360hour02.txt'])
for d in data02: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Everett, Paine Field, history')

data = readfiles(['data/ThSta02.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of latest conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='paine.png', cols=3)

init_plot('360-hour precipitation history in Tacoma, Washington,')

#set output 'tacoma.png'
data04 = readfiles(['data/ThTSplot360hour04.txt'])
for d in data04: # Trace 15-day history of conditions relative to threshold
    plt.plot(d[2], d[3], label='Tacoma Narrows Airport, history')

data = readfiles(['data/ThSta04.txt'])
for d in data:
    plt.scatter(d[2], d[3], # Scatter plot of latest conditions
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label='Current', s=150)

plot_threshold()

end_plot(name='tacoma.png', cols=3)

#Plot Precipitation Intensity and duration
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

# Set threshold parameters
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
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              '\n'
              )
xtext = ('D: Rainfall duration, in hours')
ytext = ('I: Average intensity, in inches per hour')


""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = { '01':('v', 'b', 'Seattle, Boeing Field'),
            '02':('s', 'm', 'Everett, Paine Field'),
            '03':('h', 'c', 'Seattle-Tacoma Airport'),
            '04':('o', 'r', 'Tacoma Narrows Airport')
            }

# Make plots of I-D threshold conditions
init_plot('Current conditions near Seattle, Washington,')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i, d in enumerate(data):
    plt.scatter(d[6], d[4], # Scatter plot of current conditions relative to threshold
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

#Plot Antecedent water index
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
             linewidth=2, label='Wet antecedent conditions: AWI=0.02')

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
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=3): # Set legend and output
    """ Finalize plot"""
    plt.legend(bbox_to_anchor=(0, -.2, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2.,  scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclamers = ('\n with respect to the Antecedent water index'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date and time')
ytext = ('Antecedent water index, in meters')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'Seattle, Boeing Field'),
           ('m-', 'Everett, Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows Airport')
           ]

# Make plots of AWI
init_plot('360-hour Precipitation History near Seattle, Washington,')

data_list = [data01, data02, data03, data04]
for i in range(4):
    for d in data_list[i]: # Draw time-series plots of AWI at all stations
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_AWI()

end_plot(name='awi.png')

init_plot('360-hour Precipitation History at Everett, Paine Field, KPAE,')
i = 1
for d in data_list[i]: # Draw time-series plots of AWI at one station
    x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
    plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_AWI()

end_plot(name='awi_KPAE.png')

# Plot Time Series I-D threshold index for each station
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
             linewidth=2, label='I-D threshold, ' + godt_id_label)

def init_plot(title, yMin=0., yMax=2.): # Set plot parameters and dimensions
    """ Init plot """
    plt.figure(figsize=(12, 6)) 
    plt.title(title + disclamers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    #plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()

disclamers = ('\n with respect to the Intensity-duration index'
              ' for the occurrence of landslides'
              '\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date and time')
ytext = ('Intensity-duration index')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [ ('b-', 'Seattle, Boeing Field'),
           ('m-', 'Everett, Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows Airport')
           ]

init_plot('360-hour Intensity-duration History near Seattle, Washington,')


for i in range(4):
    for d in data_list[i]: # draw time series of threshold index values, all stations
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_ID()

end_plot(name='id_index.png')

init_plot('360-hour Intensity-duration History at Everett, Paine Field, KPAE,')

i = 1
for d in data_list[i]: # draw time series of threshold index values, one station
    x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
    plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))

plot_ID()

end_plot(name='id_index_KPAE.png')
