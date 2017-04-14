REM Batch file to run python scripts for rainfall thresholds and forecast on Windows PC
REM Add paths to cygwin1.dll and python to path variable.
REM *****************##########################*****************************
REM Edit paths for system where the batch file will be running
REM *****************##########################*****************************
      @echo off
      setlocal
      path=C:\cygwin64\bin;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda;C:\Users\USERNAME\AppData\Local\Continuum\Anaconda\Scripts;C:\Users\USERNAME\Documents\LandslideThresholds\bin\unx;%PATH%
echo %date% > test_log.txt
REM 
cd data\test
python "../../src/pyth_scripts/NWS_test.py" 
      endlocal
exit
