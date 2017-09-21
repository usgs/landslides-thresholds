ReadMe!
=======

This folder contains a subset of data available from Smith and others (2017a, 2017b) to demonstrate tracking of precipitation thresholds and plotting of instrumental data for landslide monitoring stations.  Note that data in this distribution are formatted differently than in the file *20150711_20160809.csv* provided by Smith and others (2017b).  Differences include (1) timestamp format and time zone, (2) separation of data by monitoring station into separate files, (3) measurements for most sensors are provided as raw voltages, rather than engineering units.  These differences are for convenience in using the software in this distribution.  The raw measurements contained in the files in this directory are the same ones used to produce the engineering units in *20150711_20160809.csv* of Smith and others, 2017.  Please note the following: 

* The timestamps used in the files in this directory are in a human-readable format (YYYY-MM-DD HH:MM:SS) and local time, whereas the timestamps used by Smith and others (2017b) are in a date serial number format beginning at January 1, 0000, and Coordinated Universal Time (UTC). 
* Some of the Python scripts in this distribution create plots in different engineering units than those used by Smith and others (2017b).  
* In addition, the Python script *lvl_m.py* applies a zero offset correction to some of the computed water levels. 

References cited
-----------------

Smith, J.B., Baum, R.L., Mirus, B.B., Michel, A.R., and Stark, B., 2017a, Results of hydrologic monitoring on landslide-prone coastal bluffs near Mukilteo, Washington: U.S. Geological Survey Open-File Report 2017–1095, 48 p., https://doi.org/10.3133/ofr20171095.

Smith, J.B., Baum, R.L., Mirus, B.B., Michel, A.R., and Stark, Ben, 2017b, Results of Hydrologic Monitoring on Landslide-prone Coastal Bluffs near Mukilteo, Washington: U.S. Geological Survey data release, https://doi.org/10.5066/F7NZ85WX.