# Add this path statement to shell scripts that call python:
PATH=~/anaconda/bin:$PATH


python <scriptname>.py


Note:  On 1/14/2016, I observed that the forecast plots for AWI and id_index do not match corresponding heights for AWI & threshold index on corresponding dates in the history only plots (NWS folder).  Differences between how plotting is coded between Forecast.py and NWS.py seem slight, but might explain the differences(?)  Forecast.py uses a slightly different approach, ignoring the markers tuple in order to use different colors to distinguish the forecast values from observed values, whereas NWS.py uses markers to make the plots.