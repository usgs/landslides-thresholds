#!/bin/sh
# Shell Script to run python scripts for rainfall thresholds and forecast on Linux or MacOSX
# Add paths to python to shell's search path variable.
# *****************##########################*****************************
# Edit paths for system where the script will be running
# *****************##########################*****************************
PATH=/usr/local/anaconda/bin:/usr/local/anaconda/pkgs:$PATH
#Search paths on Linux server with Anaconda installed in /usr/local 
# PATH=~/anaconda/bin:$PATH  # search path on Mac OSX with Anaconda in local user directory 
cd ~/LandslideThresholds # location on typical Linux server
#cd ~/Documents/LandslideThresholds # location on typical Mac OSX user account
#
# Check for existence of folders for graphics storage
if [ -d plots ]
   then :
else
   mkdir plots
fi
# 
if [ -d ~/xfer_to_web ]
   then :
else
   mkdir ~/xfer_to_web
fi
# 
# Output of "echo" statements saved to daily log file each time cron runs this script
echo ""
echo "#####"
echo "$0 starting `date`"
date > ./rain_log.txt  
# rain_log.txt saves screen output of most recent run of rain.sh
cd data/NWS

echo "running NWS.py"
python "../../src/pyth_scripts/NWS.py" >> ../../rain_log.txt
# Copy all plots to local plots folder
cp *.png ../../plots/
cp ./data/ThCurrTabl.htm ../../plots/
# Copy plots to folder for web server
cp *.png ~/xfer_to_web/
cp ./data/ThCurrTabl.htm ~/xfer_to_web/ThCurrTabl.htm

# Make backup folder for year and copy annual data file to backup folder (Added 07/01/2016, RLB)
read day mon dat tim yr < date.txt
    if [ -d backup ]
    then :
    else
      mkdir backup
    fi
#
if [ "$dat" -eq "01" ] ; then
  if [ "$mon" = "Jul" ] ; then
    if [ -d backup/$yr ]
    then :
    else
      mkdir backup/$yr
    fi
    while read DataFile
    do
      grep -c [0-9] $DataFile > lines.txt
      read linct < lines.txt 
      if [ "$linct" -gt 500 ]
      then
        tail -n 480 $DataFile > temp1.txt
        mv $DataFile backup/$yr
        mv temp1.txt $DataFile
      fi
    done < sta2.txt
  fi
fi
#

cd "../Forecast"
echo "running Forecast.py"
python "../../src/pyth_scripts/Forecast.py"  >> ../../rain_log.txt
cp *.png ../../plots/
# Copy plots to folder for web server
cp forecast.png ~/xfer_to_web/
#
echo "$0 finished `date`"
echo "#####"
echo ""
exit
