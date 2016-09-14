#!/bin/sh
# Shell Script to copy and reformat data from remote stations in Mukilteo
# Add paths to python to path variable.
# *****************##########################*****************************
# Edit paths for system where the script will be running
# *****************##########################*****************************
# 
# Output of "echo" statements saved to daily log file each time cron runs this script
echo ""
echo "#####"
echo "$0 starting `date`"
# add Anaconda to search path on Linux servers:
PATH=/usr/local/anaconda/bin:/usr/local/anaconda/pkgs:$PATH
cd ~/LandslideThresholds # location on typical Linux server 
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
date > ./data_log.txt  # data_log.txt saves screen output of most recent run of data.sh
# On Linux, LoggerNet stores incoming data at /var/opt/Campbellsci/LoggerNet/Data
cd data/RALHS

# Export last 14 days to text files and reformat for plotting:
echo "Extracting recent data from loggernet files"
tail -1344 /var/opt/CampbellSci/LoggerNet/waMLP_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMLP_14d.txt
tail -1344 /var/opt/CampbellSci/LoggerNet/waMVD116_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMVD116_14d.txt
tail -1344 /var/opt/CampbellSci/LoggerNet/waWatertonA_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonA_14d.txt
tail -1344 /var/opt/CampbellSci/LoggerNet/waWatertonB_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonB_14d.txt
tail -1344 /var/opt/CampbellSci/LoggerNet/waMWWD_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMWWD_14d.txt

rm temp.txt

# Generate rainfall files in format readable by thresh, Note different columns used for rainfall counts 
echo "processing rainfall data"
awk -F"\t" '{print $1,"\t",$4}' waMLP_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}' > waMLP_rain.txt
awk -F"\t" '{print $1,"\t",$6}' waMVD116_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waMVD116_rain.txt
awk -F"\t" '{print $1,"\t",$7}' waWatertonA_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waWatertonA_rain.txt
awk -F"\t" '{print $1,"\t",$4}' waMWWD_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waMWWD_rain.txt

# Run rainfall threshold routines
python "../../src/pyth_scripts/RALHS.py" >> ../../data_log.txt

# Run plotting routines
python "../../src/pyth_scripts/airTemp.py"
python "../../src/pyth_scripts/barom.py"
python "../../src/pyth_scripts/battery.py"
python "../../src/pyth_scripts/lvl_m.py"
python "../../src/pyth_scripts/rain_in_day.py"
python "../../src/pyth_scripts/Tensiometer_Press.py"
python "../../src/pyth_scripts/Tensiometer_Temp_F.py"
python "../../src/pyth_scripts/VWC.py"

# Copy all plots to local plots folder
cp *.png ../../plots/
# Copy plots to folder for web server
cp Muk_*.png ~/xfer_to_web/
#
# Make backup folder for year and copy annual data file to backup folder (Added 07/01/2016, RLB)
read day mon dat tim yr zon < date.txt
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
      if [ "$linct" -gt 2000 ]
      then
        tail -n 1920 $DataFile > temp1.txt
        mv $DataFile backup/$yr
        mv temp1.txt $DataFile
      fi
    done < sta2.txt
  fi
fi
#

echo "$0 finished `date`"
echo "#####"
echo ""
exit
