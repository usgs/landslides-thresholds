README
======

Description
-----------

The precipitation tracking program, *thresh*, is a Fortran program designed for computing various measures of precipitation for comparison against established or trial thresholds for landslide occurrence. The program computes cumulative precipitation and precipitation intensity and duration and compares them to thresholds to identify periods of threshold exceedance for use in landslide early warning.  This command-line program is used in conjunction with Python scripts and shell scripts to prepare input files and visualize results.

### Purpose and limitations ###

The computer program, *thresh*, along with its accompanying utility programs and scripts, has two purposes:  (1) the automated tracking of precipitation conditions, including forecasts, relative to empirical thresholds for landslide occurrence, and (2) analyzing precipitation for multi-year-long periods of record to compare historical threshold exceedance with dates of historical landslides.  The program has been used to track rainfall conditions relative to landslide thresholds for the Seattle area (http://landslides.usgs.gov/monitoring/seattle/) on a nearly continuous basis since about January 2006.  The program was also used to analyze performance of rainfall thresholds for Seattle against historical records (Chleborad and others, 2006; 2008) and more recently for the Mukilteo and Everett area of Washington State (Scheevel and others, 2017).  We have made improvements to the program and written documentation to prepare it for public release in support of our recent cooperation with Sound Transit to improve precipitation thresholds for the rail corridor near Mukilteo and Everett, Washington and to incorporate rainfall forecasts into precipitation tracking to enhance early warning for landslides.

The program is written in a modular format for flexibility and expandability. The current version was designed for a few specific types of precipitation thresholds which include most types of thresholds that have been published for areas of the U.S.  These include intensity-duration thresholds, cumulative recent-and-antecedent precipitation thresholds, and intensity thresholds based on a constant duration (running-average intensity thresholds and peak-intensity thresholds).  Seasonal antecedent precipitation totals and the antecedent water index are both supported for use in areas where antecedent precipitation is known to affect validity of intensity-duration thresholds. 

An instance of *thresh* and related programs is limited to a specific geographic area for which thresholds can be defined.  Operation is easily scaled to broader areas by running additional instances using threshold parameters and related input data customized  for each additional locality or region of interest.

### Typical Workflow ###

For automated tracking of precipitation relative to thresholds, the workflow has been automated using shell scripts and Python scripts.  The basic steps are (1) collect the latest precipitation data either from the National Weather Service or other weather stations, (2) reformat the data using either the utility program, *nwsfmt*, or a Python script (for data in XML format), (3) compute current conditions relative to the thresholds using the program *thresh*, (4) plot the results using Python scripts and  the Python library *matplotlib*.  This process can be repeated on a regular cycle as a Windows Scheduled Task or *cron* job (on Linux/Unix).  Information about threshold parameters specific to a group of weather stations is stored in the initialization file for the program *thresh*, *thresh_in.txt*.

The workflow for analyzing long-term precipitation data is similar to that for threshold tracking, except that it has not been automated: (1) collect and compile available precipitation records for the area and time period of interest, (2) reformat the data to make them readable and usable by the program thresh, (3) compute the history of threshold exceedance and exceedance statistics using the program thresh, (4, optional) analyze threshold performance according to Receiver Operating Characteristics methods using the utility program *tsthresh*, (5) visualize the results using a third-party plotting package or python scripts (not included)

### What's included ###

This distribution includes source code files for the program *thresh* and two companion utility programs, *nwsfmt*, and *tsthresh*, as well as supporting shell scripts and Python scripts.  It also includes sample data in the data folder and sample initialization files in the main folder.  Empty folders for executable binaries, *bin*, are also included in the top-level directory.  Although the scripts have been written to use relative paths as much as possible, certain paths in the shell scripts and python scripts will need to be localized for a particular installation.  These include primarily the urls or paths for raw data from individual weather stations.  Also threshold parameters in *thresh_in.txt* and in the Python plotting routines will need to be localized for your installation.

A complete user guide for the program thresh is available as a USGS Techniques and Methods chapter, Baum and others (in prep) online at https://doi.org/[insertProductDOIhere].

### User Interface ###

The program *thresh* and its companion utility programs, *nwsfmt*, and *tsthresh*, run from the command line and have limited user interaction.  Each program uses an initialization file that contains basic data needed to run the program as well as the path names of other input files.  The Python scripts are likewise designed to run from the command line.  Shell scripts (or Windows batch files) control and integrate the operation of programs in this package with Unix or Linux commands on the system to automate the process of tracking rainfall thresholds.  

### Latest version (Summer 2017) ###

This release, 1.0.0a, is based on code that has been in use at the U.S. Geological Survey since 2006.  We began work to modernize the Fortran code in 2013.  Subsequently, in 2015, we began developing the python scripts used in processing files and plotting results.  

### Testing ###

Throughout its development, the code has passed through various kinds of testing to verify that it reproduces results of the basic formulas for rainfall thresholds (Chleborad and others, 2006, 2008; Baum and Godt, 2010) and correctly tracks precipitation sums and intensities in relation to the thresholds.  As noted in previous sections, we have used the code in research and operations and run checks to confirm that the results were computed correctly.  

Windows Batch Files
-------------------

This directory contains four Windows(R) batch files, *data.bat*, *rain.bat*, startData.bat, and *test.bat*.  Corresponding shell scripts for Linux and Unix are found in the *src* directory.  Edit the batch files to change *username* in each instance of  *C:\Users\username\...* to the appropriate username for your system.  This appears in the statement `path = ...` near the beginning of each batch file.

References cited
----------------

*   Baum, R. L. and Godt, J. W., 2010, Early warning of rainfall-induced shallow landslides and debris flows in the USA: Landslides, v. 7 no. 3, p. 259-272. doi: 10.1007/s10346-009-0177-0

*   Baum, R.L., Fischer, S.J., Vigil, J.C., in prep., Thresh -- Software for tracking rainfall thresholds for landslide occurrence: U.S. Geological Survey Techniques and Methods, TM14-?? online at https://doi.org/[insertProductDOIhere] https://doi.org/10.3133/tm14

*   Chleborad, A.F., Baum, R.L., and Godt, J.W., 2008, A prototype system for forecasting landslides in the Seattle, Washington, Area, in Baum, R.L., Godt, J.W., and Highland, L.M., eds., Engineering geology and landslides of the Seattle, Washington, area: Geological Society of America Reviews in Engineering Geology v. XX, p. 103-120, doi: 10.1130/2008.4020(06).

*   Chleborad, A.F., Baum, R.L., and Godt, J.W., 2006, Rainfall thresholds for forecasting landslides in the Seattle, Washington, Area—Exceedance and Probability: U.S. Geological Survey Open-File Report 2006-1064, online at http://pubs.usgs.gov/of/2006/1064.

*   Scheevel, C.R., Baum, R.L., Mirus, B.B., and Smith, J.B., 2017, Precipitation thresholds for landslide occurrence near Seattle, Mukilteo, and Everett, Washington: U.S. Geological Survey Open-File Report 2017–1039, 51 p., https://doi.org/10.3133/ofr20171039.
