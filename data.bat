REM BAtch file to copy and reformat data from remote stations in Mukilteo
REM Add paths to cygwin1.dll, unix text filters, and pyton to path variable.
REM *****************##########################*****************************
REM Edit paths for system where the batch file will be running
REM *****************##########################*****************************
      @echo off
      setlocal
      path=C:\cygwin64\bin;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda\Scripts;C:\Users\USERNAME\Documents\LandslideThresholds\bin\unx;%PATH%
echo %date% > data_log.txt

REM C:\Campbellsci\LoggerNet

cd ./data/RALHS

REM Export last 14 days to text files and reformat for plotting:

tail -1344 C:\Campbellsci\LoggerNet\waMLP_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMLP_14d.txt
tail -1344 C:\Campbellsci\LoggerNet\waMVD116_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMVD116_14d.txt
tail -1344 C:\Campbellsci\LoggerNet\waWatertonA_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonA_14d.txt
tail -1344 C:\Campbellsci\LoggerNet\waWatertonB_rawMeasurements_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waWatertonB_14d.txt
tail -1344 C:\Campbellsci\LoggerNet\waMWWD_rawData_15m.dat > temp.txt
grep -v [a-z] temp.txt | grep [0-9] | tr -d "[\042]" | tr -s "[\054]" "[\011]" > waMWWD_14d.txt

rm temp.txt

REM Generate rainfall files, Note different columns used for rainfall counts 

gawk -F"\t" "{print $1,\"\t\",$4}" waMLP_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}" > waMLP_rain.txt
gawk -F"\t" "{print $1,\"\t\",$6}" waMVD116_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waMVD116_rain.txt
gawk -F"\t" "{print $1,\"\t\",$7}" waWatertonA_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waWatertonA_rain.txt
gawk -F"\t" "{print $1,\"\t\",$4}" waMWWD_14d.txt | sed "s/-/:/g" | tr -s "[\072]" "[\011]" | tr -s "[\040]" "[\011]" | gawk -F"\t" "{$7=$7/100; print $1,\"\t\",$2,\"\t\",$3,\"\t\",$4,\"\t\",$5,\"\t\",$7}"  > waMWWD_rain.txt

REM Run rainfall threshold routines
python "../../src/pyth_scripts/RALHS.py"

REM Annually on June 30 split rainfall data files and save old data to backup folder

set dd=%date:~7,2%
set yy=%date:~10,4%
set mm=%date:~4,2%

if %dd%==30 (
  if %mm%==06 (
    mkdir backup\\%yy%
REM Split input files for thresh.exe
    for /f "tokens=1" %%f in (sta2.txt) do (
      grep -c [0-9] %%f > lines.txt
REM Extract last (most recent) 480 lines of data from files, archive old data
      for /F "tokens=1" %%i in (lines.txt) do (
        if /I %%i GEQ 500 tail -n 480 %%f > temp1.txt
        mv %%f backup\\%yy% 
        mv temp1.txt %%f        
      )
    )
  )
)


REM Run plotting routines
python "../../src/pyth_scripts/airTemp.py"
python "../../src/pyth_scripts/barom.py"
python "../../src/pyth_scripts/battery.py"
python "../../src/pyth_scripts/lvl_m.py"
REM python "../../src/pyth_scripts/rain_mm.py"
python "../../src/pyth_scripts/rain_in.py"
python "../../src/pyth_scripts/Tensiometer_Press.py"
REM python "../../src/pyth_scripts/Tensiometer_Temp_C.py"
python "../../src/pyth_scripts/Tensiometer_Temp_F.py"
python "../../src/pyth_scripts/VWC.py"

cp *.png ../../plots/

     endlocal