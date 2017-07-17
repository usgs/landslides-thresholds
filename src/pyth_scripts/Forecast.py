# Forecast.py downloads point forecast data from the National Weather Service and combines
# the 24-hour precipitation forecast with recent observations to project conditions relative
# to the rainfall thresholds for Seattle, WA, and plots the results.
#
# Get libraries
import requests
import datetime as dt
import xmltodict
from collections import OrderedDict
import os
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import glob

def get_forecast(stationName,stationNum,url): # Procedure to obtain NWS forecast data and export to text file
	try:
		r = requests.get(url)
	except:
		print('Unable to download forecast for ', stationName)
	with open('station' + stationNum +'.txt','wb') as outfile:
		result = xmltodict.parse(r.text)
		pop = result['dwml']['data']['parameters']['probability-of-precipitation']['value']
		hqpf = result['dwml']['data']['parameters']['hourly-qpf']['value']
		d = result['dwml']['data']['time-layout']['start-valid-time']
		date3 = []
		for dte in d:
			date = dt.datetime.strptime(dte.rsplit("-",1)[0],"%Y-%m-%dT%H:%M:%S")
			date2 = '{:%Y-%m-%d %H:%M:%S}'.format(date)
			date3.append(date2)
		pop24 = pop[0:24]
		hqpf24 = hqpf[0:24]
		date24 = date3[0:24]
		while OrderedDict([(u'xsi:nil', u'true')]) in hqpf: hqpf.remove(OrderedDict([(u'xsi:nil', u'true')]))
		while OrderedDict([(u'xsi:nil', u'true')]) in pop: hqpf.remove(OrderedDict([(u'xsi:nil', u'true')]))
		for a,b,c in zip(date24,pop24,hqpf24):
			print >>outfile, '\t'.join([a,b,c])

# Obtain probability of precipitation (POP) and hourly Quantitative Precipitation Forecast (QPF)
url = 'http://forecast.weather.gov/MapClick.php?lat=47.6062&lon=-122.3321&FcstType=digitalDWML'
get_forecast('KBFI','01',url)
url='http://forecast.weather.gov/MapClick.php?lat=47.9445&lon=-122.3046&FcstType=digitalDWML'
get_forecast('KPAE','02',url)
url='http://forecast.weather.gov/MapClick.php?lat=47.449&lon=-122.3093&FcstType=digitalDWML'
get_forecast('KSEA','03',url)
url='http://forecast.weather.gov/MapClick.php?lat=47.2529&lon=-122.4443&FcstType=digitalDWML'
get_forecast('KTIW','04',url)

# Time series plot of POP
def readfiles(file_list): # Import data from list of input files
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',
                                  delimiter='\t',
                                  dtype="|S",autostrip=True).T)
    return data

def init_plot(title, yMin=0, yMax=100): # Set plot parameters and dimensions
    plt.figure(figsize=(12,6)) 
    plt.title(title + disclaimers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None,cols=5): # Set plot legend and output
    plt.legend(bbox_to_anchor=(0,-.15, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2., scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclaimers = ('\nUSGS PROVISIONAL DATA'
               '\nSUBJECT TO REVISION'
               )
xtext = ('Date and time')
ytext = ('Probability of Precipitation')

""" Marker Dictionary Station : (MarkerStyle, Color, Title)"""
markers = [('b-', 'Seattle, Boeing Field'),
           ('m-', 'Everett, Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows Airport')
           ]
# Set fontsize for plot

font = {'family' : 'monospace',
    'weight' : 'normal',
        'size'   : '10'}

matplotlib.rc('font', **font)  # pass in the font dict as kwargs

# Plot 24-hour probability of precipitation (POP) forecast
init_plot('Probability of Precipitation near Seattle, Washington,')
data = readfiles(glob.glob('station*.txt'))

for i, d in enumerate(data): # Draw time-series plot of POP for all stations
    print d[1][0], markers[i][0],markers[i][1]
    x = [dt.datetime.strptime(date,'%Y-%m-%d %H:%M:%S') for date in d[0]]
    plt.plot(x, d[1], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_major_locator(mdates.HourLocator(interval=4))

end_plot(name='pop.png')

# Move Observed data from NWS to Forecasting
import shutil
#KBFI:
shutil.copy2('../../data/NWS/KBFI_t.txt','../../data/Forecast/KBFI_t.txt')
#KPAE
shutil.copy2('../../data/NWS/KPAE_t.txt','../../data/Forecast/KPAE_t.txt')
#KSEA
shutil.copy2('../../data/NWS/KSEA_t.txt','../../data/Forecast/KSEA_t.txt')
#KTIW
shutil.copy2('../../data/NWS/KTIW_t.txt','../../data/Forecast/KTIW_t.txt')

#Combine 'hourly-qpf' with rainfall data obtained from NWS
import csv
from itertools import izip

def data_merge(stationName, stationNum, station): # Import and reformat QPF data and timestamps
	with open('station' + stationNum + '.txt', 'rb') as infile, open(stationName + '_f.txt', 'wb') as outfile:
		inr = csv.reader(infile,delimiter='\t')
		for row in inr:
			d = dt.datetime.strptime(row[0],'%Y-%m-%d %H:%M:%S')
			p = int(100*float(row[2]))
			nr = "{:02d}{:%Y%m%d%H}{:04d}\n".format(station,d,p)
			outfile.write(nr)

	filenames = [stationName + '_t.txt', stationName + '_f.txt']
	with open(stationName + '_ft.txt', 'wb') as outfile:# Append QPF data onto recent rainfall data and save to file.
		for fname in filenames:
			with open(fname) as infile:
				for line in infile:
					outfile.write(line)

data_merge('KBFI', '01', 1)
data_merge('KPAE', '02', 2)
data_merge('KSEA', '03', 3)
data_merge('KTIW', '04', 4)

#Run thresh to compute Precipitation Thresholds
# If os.name returns "nt' then use a Windows-specific path name
sys_name = os.name
if sys_name == 'nt':
    thresh_path=os.path.normpath('../../bin/thresh.exe')
else:
    thresh_path=os.path.normpath('../../bin/thresh')
print(thresh_path)
os.system(thresh_path)

# Plot Incremental Precipitation and Forecasted Precipitation
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
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',
                                  delimiter='\t',
                                  dtype="|S", autostrip=True).T)
    return data

def init_plot(title, xMin=0, xMax=15, yMin=0, yMax=8): # Set plot dimensions and parameters
    plt.figure(figsize=(12,6)) 
    plt.title(title + disclaimers + date_text, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.xlim(xMin,xMax)
    plt.ylim(yMin,yMax)
    plt.grid()
    plt.xticks(np.arange(xMin,xMax+1))

def end_plot(name=None, cols=5): # Draw legend and set output
    plt.legend(bbox_to_anchor=(0, -.28,1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2., scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclaimers = ('\n with respect to cumulative precipitation threshold'
               ' for the occurence of landslides'
               '\nUSGS PROVISIONAL DATA'
               '\nSUBJECT TO REVISION'
               '\n'
               )
xtext = ('P15: 15-day cumulative precipitation prior to 3-day '
         'precipitation, in inches')
ytext = ('P3: 3-day cumulative precipitation, in inches')

# get date of latest data
upd_path = os.path.normpath('../NWS/data/ThUpdate.txt')
fin = open(upd_path, 'rt')
date_text = fin.read()
fin.close()              

markers = { '01':('v', 'b', 'Seattle, Boeing Field, current conditions'),
            '02':('s', 'm', 'Everett, Paine Field, current conditions'),
            '03':('h', 'c', 'Seattle-Tacoma Airport, current conditions'),
            '04':('o', 'r', 'Tacoma Narrows Airport, current conditions')
            }
markers1 = {'01':('v', 'b', 'Seattle, Boeing Field, 24-hour-forecast'),
            '02':('s', 'm', 'Everett, Paine Field, 24-hour-forecast'),
            '03':('h', 'c', 'Seattle-Tacoma Airport, 24-hour-forecast'),
            '04':('o', 'r', 'Tacoma Narrows Airport, 24-hour-forecast')
            }


# Draw plot of recent anad antecedent precipitation threshold
init_plot('Current and Forecasted conditions near Seattle, Washington,')

os.chdir('../../data/NWS')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i,d in enumerate(data):
    plt.scatter(d[2],d[3], # Scatter plot of current conditions (from NWS folder)
                marker=markers[str(d[1])][0],
                c=markers[str(d[1])][1],
                label=markers[str(d[1])][2], s=150)

os.chdir('../../data/Forecast')

data = readfiles(glob.glob('data/ThSta*.txt'))
for i,d in enumerate(data):
    plt.scatter(d[2],d[3], # Scatter plot of 24-hour forecast conditions (from Forecast folder)
                marker=markers1[str(d[1])][0],
                c=markers1[str(d[1])][1],
                label=markers1[str(d[1])][2], alpha = 0.3, s=150)


plot_threshold()
end_plot(name='forecast.png', cols=2)

#Plot Time Series Precipitation for each station
def readfiles(file_list): # Import data from list of text input files
    data = []
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',
                                  delimiter='\t',
                                  dtype="|S", autostrip=True).T)
    return data

def init_plot(title, yMin=0, yMax=1.25): # Set plot parameters and dimensions
    plt.figure(figsize=(12,6)) 
    plt.title(title + disclaimers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin,yMax)
    plt.grid()

def end_plot(name=None, cols=5): # Set plot legend and output
    plt.legend(bbox_to_anchor=(0, -.15, 1, -.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2., scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclaimers =('\nUSGS PROVISIONAL DATA'
              '\nSUBJECT TO REVISION'
              )
xtext = ('Date and time')
ytext = ('Hourly Precipitation, in')

markers = [('b-', 'Seattle, Boeing Field'),
           ('m-', 'Everett, Paine Field'),
           ('c-', 'Seattle-Tacoma Airport'),
           ('r-', 'Tacoma Narrows Airport')
           ]

data01 = readfiles(['data/ThTSplot360hour01.txt'])
data02 = readfiles(['data/ThTSplot360hour02.txt'])
data03 = readfiles(['data/ThTSplot360hour03.txt'])
data04 = readfiles(['data/ThTSplot360hour04.txt'])
data_list = [data01, data02, data03, data04]

#KBFI
init_plot('Time-Series Plot for Precipitation for Seattle, Boeing Field')
i=0
for d in data_list[i]: # Draw time-series plot of observed and forecasted precipitation
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[1], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='boeing_f.png')

#KPAE
init_plot('Time-Series Plot for Precipitation for Everett, Paine Field')
i=1
for d in data_list[i]: # Draw time-series plot of observed and forecasted precipitation
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[1], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='paine_f.png')

#KSEA
init_plot('Time-Series Plot for Precipitation for Seattle-Tacoma Airport')
i=2
for d in data_list[i]: # Draw time-series plot of observed and forecasted precipitation
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[1], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='seatac_f.png')

#KTIW
init_plot('Time-Series Plot for Precipitation for Tacoma Narrows Airport')
i=3
for d in data_list[i]: # Draw time-series plot of observed and forecasted precipitation
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[1], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='tacoma_f.png')

#Plot AWI history and forecast
def AWI(numbers): # Define threshold value
    ret = [[], []]
    for x in numbers:
        ret[0].append(x)
        ret[1].append(0.02)
    return ret

def plot_AWI(): # Draw threshold line
    slide = AWI(x)
    plt.plot(slide[0], slide[1], 'k-',
             linewidth=2, label='Wet Antecedent Conditions: AWI=0.02')

def readfiles(file_list):# Import data from text files
    data=[]
    for fname in file_list:
        data.append(
                    np.genfromtxt(fname,
                                  comments='#',
                                  delimiter='\t',
                                  dtype = "|S", autostrip=True).T)
    return data

def init_plot(title, yMin=-0.2, yMax=.1): # Set plot parameters and dimensions
    plt.figure(figsize=(12,6)) 
    plt.title(title + disclaimers, fontsize=11)
    plt.xlabel(xtext)
    plt.ylabel(ytext)
    plt.ylim(yMin, yMax)
    plt.grid()

def end_plot(name=None, cols=3): # Set legend and output
    plt.legend(bbox_to_anchor=(0,-.2,1,-.5), loc=8, ncol=cols, fontsize=10,
               mode="expand", borderaxespad=-2., scatterpoints=1)
    if name:
        plt.savefig(name, bbox_inches='tight')

disclaimers = ('\n with respect to the Antecedent Water Index'
               ' for the occurrence of landslides'
               '\nUSGS PROVISIONAL DATA'
               '\nSUBJECT TO REVISION'
               )
xtext = ('Date and time')
ytest = ('Antecedent Water Index, in meters')

# Make plots of AWI
init_plot('360-hour Precipitation History and Forecast near Seattle, Washington,')

for i in range(4):
    for d in data_list[i]: # Draw time-series plots of AWI at all stations
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plot_AWI()
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='awi_f.png')

init_plot('360-hour Precipitation History and Forecast at Everett, Paine Field, KPAE,')

#KPAE
i=1
for d in data_list[i]: # Draw time-series plots of AWI at one station
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[13], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plot_AWI()
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade area of forecast
end_plot(name='awi_f_KPAE.png')

# Plot Time Series I-D Threshold index for each station
godt_id_label = 'I=3.257*D^(-1.13)'

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

init_plot('360-hour Intensity-Duration History and Forecast near Seattle, Washington,,')

for i in range(4): # draw time series of threshold index values, all stations
    for d in data_list[i]:
        x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
        plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade forecast area
plot_ID()
end_plot(name='id_index_f.png')

init_plot('360-hour Intensity-Duration History and Forecast at Everett, Paine Field, KPAE,')

#KPAE
i=1
for d in data_list[i]: # draw time series of threshold index values, all stations
	x = [dt.datetime.strptime(date,'%H:%M %m/%d/%Y') for date in d[0]]
	plt.plot(x, d[11], markers[i][0], label=markers[i][1])

plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.gca().xaxis.set_minor_locator(mdates.HourLocator(interval=6))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
plt.axvspan(x[336],x[359],facecolor='yellow', alpha=0.5, label = 'Forecast') # Shade forecast area
plot_ID()
end_plot(name='id_index_f_KPAE.png')
