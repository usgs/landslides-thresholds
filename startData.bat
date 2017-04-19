REM BAtch file to copy and reformat data from remote stations in Mukilteo
REM Add paths to cygwin1.dll, unix text filters, and pyton to path variable.
REM *****************##########################*****************************
REM Edit paths for system where the batch file will be running
REM *****************##########################*****************************
      @echo off
      setlocal
      path=C:\cygwin64\bin;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda\Scripts;C:\Users\USERNAME\Documents\LandslideThresholds\bin\unx;%PATH%
echo %date% > start_data_log.txt

cd data\RALHS
rm Data\*.txt

REM Export all data to text files and reformat for plotting:

cat C:\Campbellsci\LoggerNet\waMLP_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMLP_14d.txt
cat C:\Campbellsci\LoggerNet\waMVD116_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMVD116_14d.txt
cat C:\Campbellsci\LoggerNet\waWatertonA_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonA_14d.txt
cat C:\Campbellsci\LoggerNet\waWatertonB_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonB_14d.txt
cat C:\Campbellsci\LoggerNet\waMWWD_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMWWD_14d.txt

rm temp.txt

REM Generate rainfall files, Note different columns used for rainfall counts 

gawk -F"\t" "{print $1,\"\t\",$4}" waMLP_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}" > waMLP_rain.txt
gawk -F"\t" "{print $1,\"\t\",$6}" waMVD116_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waMVD116_rain.txt
gawk -F"\t" "{print $1,\"\t\",$7}" waWatertonA_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waWatertonA_rain.txt
gawk -F"\t" "{print $1,\"\t\",$4}" waMWWD_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waMWWD_rain.txt

REM Run rainfall threshold routines
python "../../src/pyth_scripts/RALHS.py"

REM Skip plotting routines

     endlocal