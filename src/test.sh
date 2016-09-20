#!/bin/sh
# Shell Script to run python script for testing rainfall thresholds on Linux or MacOSX
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
date > ./test_log.txt  
# rain_log.txt saves screen output of most recent run of rain.sh
cd data/test/
python "../../src/pyth_scripts/test.py" >> ../../test_log.txt
#
exit
