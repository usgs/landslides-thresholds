REM Batch file to run python scripts for rainfall thresholds and forecast on Windows PC
REM Add paths to cygwin1.dll and python to path variable.
REM *****************##########################*****************************
REM Edit paths for system where the batch file will be running
REM *****************##########################*****************************
      @echo off
      setlocal
      path=C:\cygwin64\bin;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda\Scripts;C:\Users\USERNAME\Documents\LandslideThresholds\bin\unx;%PATH%
echo %date% > rain_log.txt

REM 
cd data\NWS
REM rm *.xml

REM Collect rainfall data and update threshold plots
python "../../src/pyth_scripts/NWS.py" >> ../../rain_log.txt
cp *.png "../../plots/"
cp ./data/ThCurrTabl.htm "../../plots/"

REM Annually on June 30 split data file and save old data to backup folder

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

REM obtain QPF data and plot forecast charts
cd "../Forecast"
python "../../src/pyth_scripts/Forecast.py"  >> ../../rain_log.txt
cp *.png "../../plots/"

      endlocal
exit
