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
date > ./data_log.txt  # data_log.txt saves screen output of most recent run of data.sh
# On Linux, LoggerNet stores incoming data at /var/opt/Campbellsci/LoggerNet/Data
cd data/RALHS
rm data/*.txt

# Export raw data to text files and reformat for plotting:
echo "Extracting all data from loggernet files"
cat /var/opt/CampbellSci/LoggerNet/waMLP_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMLP_14d.txt
cat /var/opt/CampbellSci/LoggerNet/waMVD116_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMVD116_14d.txt
cat /var/opt/CampbellSci/LoggerNet/waWatertonA_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonA_14d.txt
cat /var/opt/CampbellSci/LoggerNet/waWatertonB_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonB_14d.txt
cat /var/opt/CampbellSci/LoggerNet/waMWWD_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMWWD_14d.txt

rm temp.txt

# Generate rainfall files in format readable by thresh, Note different columns used for rainfall counts 
echo "reformatting rainfall data"
awk -F"\t" '{print $1,"\t",$4}' waMLP_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}' > waMLP_rain.txt
awk -F"\t" '{print $1,"\t",$6}' waMVD116_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waMVD116_rain.txt
awk -F"\t" '{print $1,"\t",$7}' waWatertonA_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waWatertonA_rain.txt
awk -F"\t" '{print $1,"\t",$4}' waMWWD_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | awk -F"\t" '{$7=$7/100; print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$7}'  > waMWWD_rain.txt

# Run rainfall threshold routines
python "../../src/pyth_scripts/RALHS.py" >> ../../data_log.txt

#

echo "$0 finished `date`"
echo "#####"
echo ""
exit
