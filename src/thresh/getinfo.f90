! external_files module contains the subroutines read_init, read_thlast, 
! read_station_file. These subroutines are used for collecting data from
! external files.

module external_files
implicit none

contains
   ! PURPOSE:
   !	  The subroutine read_init reads user generated thresh_in.txt
   !	  and assigns the data within to program thresh variables.
   !	  The data is placed in a thresh log file as well.
   
      subroutine read_init(uout,numStations,maxLines,rph,Trecent,Tantecedent,&
	   Tintensity,minTStormGap,TavgIntensity,maxDataGap,numPlotPoints,&
	   numPlotPoints2,slope,intercept,powerCoeff,powerUnit,powerExp,&
	   powerSwitch,polynomArr,seasonalAntThresh,runningIntens,AWIThresh,&
	   fieldCap,fcUnit,drainConst,evapConst,resetAntMonth,resetAntDay,&
	   timezoneOffset,year,lgyr,midnightVal,plotFormat,stats,outputFolder,&
	   dataLocation,stationLocation,stationNumber,sysYear,upLim,lowLim,&
	   interSwitch,intervals,polySwitch) !{{{
	   use data_analysis !contains check_SAT, check_AWI, check_switches,
	                     !check_antMonth_antDay,set_power_limits,set_poly_limits
	                     !error1, and error2
	   implicit none
	                     		  
   ! FORMAL ARGUMENTS
	      character (len=*), allocatable,intent(out) :: dataLocation(:)
	      character (len=*), allocatable,intent(out) :: stationLocation(:)
	      character (len=*), allocatable,intent(out) :: stationNumber(:)
	      character (len=*),intent(out) :: outputFolder
	      character (len=*),intent(out) :: powerUnit,fcUnit
	      character (len=*),intent(out) :: plotFormat
	      real,intent(out)		:: slope,intercept,powerCoeff
	      real,intent(out)     :: polynomArr(6),runningIntens,AWIThresh
	      real,intent(out)		:: powerExp,fieldCap,drainConst,evapConst(12)
	      real,intent(out)		:: seasonalAntThresh,upLim,lowLim
	      integer,intent(in)	:: sysYear
	      integer,intent(out)  :: uout,numStations,maxLines,rph
	      integer,intent(out)	:: Trecent,Tantecedent,Tintensity
	      integer,intent(out) 	:: minTStormGap,TavgIntensity
	      integer,intent(out)  :: maxDataGap,numPlotPoints,numPlotPoints2
	      integer,intent(out)  :: resetAntMonth,resetAntDay
	      integer,intent(out)  :: timezoneOffset,year,midnightVal
	      integer,intent(out)	:: intervals
	      logical,intent(out)  :: powerSwitch,polySwitch,interSwitch
	      logical,intent(out)	:: lgyr,stats

   ! LOCAL VARIABLES
	      character(1) :: junk
	      character    :: tb = char(9)
	      character (len = 2)   :: SATunit
	      character (len = 8)   :: tempStatNum
	      character (len = 50)  :: tempStatLoc
	      character (len = 255) :: tempDataLoc
	      character (len = 260) :: command
	      integer   :: i, lineCtr, thresh_in=22, iostatus
	      logical   :: exists, checkS, checkA

   !------------------------------
   ! Opening thresh_in.txt file to read from
 	      open(thresh_in,file='thresh_in.txt',status='old',err=100)
	      lineCtr = 1
	      write(uout,*) '*-*-*-* Initialization Data *-*-*-*'   
	   
   ! Reading from thresh_in,
	   !Line 1 Number of gauging stations
	      read(thresh_in,*,err=115) junk, numStations
	      lineCtr = lineCtr + 1
	   !Line 2 Number of lines of data per file
	      read(thresh_in,*,err=115) junk, maxLines
	      lineCtr = lineCtr + 1
	   !Line 3 Readings per hour
	      read(thresh_in,*,err=115) junk, rph
	      lineCtr = lineCtr + 1
	   !Line 4 Hours of recent precip
	      read(thresh_in,*,err=115) junk, Trecent
	      lineCtr = lineCtr + 1
	   !Line 5 Hours of antecedent precip
	      read(thresh_in,*,err=115) junk, Tantecedent
	      lineCtr = lineCtr + 1
	   !Line 6 Number of hours for intensity. If 0, compute average intensity since
	   !beginning of storm
	      read(thresh_in,*,err=115) junk, Tintensity
	      lineCtr = lineCtr + 1
	   !Line 7 Minimum number of hours between storms
	      read(thresh_in,*,err=115) junk, minTstormGap
	      lineCtr = lineCtr + 1
	   !Line 8 Hours for running average intensity
	      read(thresh_in,*,err=115) junk, TavgIntensity
	      lineCtr = lineCtr + 1
	   !Line 9 Number of lines allowed for data gaps
	      read(thresh_in,*,err=115) junk, maxDataGap
	      lineCtr = lineCtr + 1
	   !Line 10 Time window, hours for time-series plots, negative or zero value
	   !suppresses output
	      read(thresh_in,*,err=115) junk, numPlotPoints
	      lineCtr = lineCtr + 1
	   !Line 11 Time window, hours for short-term time-series plots. Negative or
	   !zero value suppresses output
	      read(thresh_in,*,err=115) junk, numPlotPoints2
	      lineCtr = lineCtr + 1
	   !Line 12 Slope of recent/antecedent threshold
	      read(thresh_in,*,err=115) junk, slope
	      lineCtr = lineCtr + 1
	   !Line 13 Intercept of recent/antecedent threshold
	      read(thresh_in,*,err=115) junk, intercept
	      lineCtr = lineCtr + 1
	   !Line 14 Flag for whether or not power law definition is used
	      read(thresh_in,*,err=115) junk, powerSwitch
	      lineCtr = lineCtr + 1
	   !If power law is used, get necessary information
	   	if(powerSwitch) then !{{{
	   		!Line 15 Coefficient for power law
	   			read(thresh_in,*,err=115) junk, powerCoeff
	   			lineCtr = lineCtr + 1
	   		!Line 16 Exponent for power law
	   			read(thresh_in,*,err=115) junk, powerExp
	   			lineCtr = lineCtr + 1
	   		!Line 17 Interval for power law
	   			read(thresh_in,*,err=115) junk, lowLim, upLim
	   			lineCtr = lineCtr + 1 !}}}
	   	else !{{{
	   		!Lines 15, 16, 17 are all irrelevant. Information sent to junk
	   			read(thresh_in,*,err=115) junk
	   			read(thresh_in,*,err=115) junk
	   			read(thresh_in,*,err=115) junk
	   			powerCoeff = 0
	   			powerExp = 0
	   			lowLim = 0
	   			upLim = 0
	   			lineCtr = lineCtr + 3 !}}}
	   	end if 
	   !Line 18 Polynomial defined ID flag
	   	read(thresh_in,*,err=115) junk, polySwitch
	   	lineCtr = lineCtr + 1
	   !If polynomial is used, get necessary information
	   	if(polySwitch) then !{{{
	   		!Line 19 coefficents for polynomial
	   			read(thresh_in,*,err=115) junk, (polynomArr(i), i = 1,6)
	   			lineCtr = lineCtr + 1
	   		!Line 20 Interval for polynomial
	   			read(thresh_in,*,err=115) junk, lowLim, upLim
	   			lineCtr = lineCtr + 1 !}}}
	   	else !{{{
	   		!Lines 19, 20 are irrelevant. Information sent to junk
	   	   read(thresh_in,*,err=115) junk
	   	   read(thresh_in,*,err=115) junk
	   		polynomArr = 0
	   		lowLim = 0
	   		upLim = 0
	   		lineCtr = lineCtr + 2 !}}}
	   	end if
	   !line 21 Linear interpolation ID flag
	   	read(thresh_in,*,err=115) junk, interSwitch
	   	lineCtr = lineCtr + 1
	   !if linear interpolation is used, get necessary information
	   	if(interSwitch) then !{{{
	   	   !Line 22 number of linear intervals
	   		read(thresh_in,*,err=115) junk, intervals
	   		lineCtr = lineCtr + 1 !}}}
	   	else !{{{
	   		!Line 22 is irrelevant. Information sent to junk 
	   		read(thresh_in,*,err=115) junk
	   		intervals = 0
	   		lineCtr = lineCtr + 1 !}}}
	   	end if
	   !Line 23 Threshold Unit, historically and currently called powerUnit, for 
	   !the sake of not having to rewrite code. The author should make not of this.
	      read(thresh_in,*,err=115) junk, powerUnit
	   !Line 24 Day and month to start annual antecedent rainfall running
	   !total
	      read(thresh_in,*,err=115) junk, resetAntMonth, resetAntDay
	      lineCtr = lineCtr + 1
	   !Line 25 Seasonal antecedent threshold
	      read(thresh_in,*,err=115) junk, seasonalAntThresh, SATunit
	   !Line 26 Value of running average intensity threshold
	      read(thresh_in,*,err=115) junk, runningIntens
	      lineCtr = lineCtr + 1
	   !Line 27 Threshold value of antecedent water index
	      read(thresh_in,*,err=115) junk, AWIThresh
	      lineCtr = lineCtr + 1
	   !Line 28 Field capacity for antecedent water index
	      read(thresh_in,*,err=115) junk, fieldCap, fcUnit
	      lineCtr = lineCtr + 1
	   !Line 29 Drainage constant for antecedent water index
	      read(thresh_in,*,err=115) junk, drainConst
	      lineCtr = lineCtr + 1
	   !Line 30 Monthly evaporation constants for antecedent water index
	      read(thresh_in,*,err=115) junk, (evapConst(i), i = 1,12)
	      lineCtr = lineCtr + 1
	   !Line 31 Time-zone offset, hours
	      read(thresh_in,*,err=115) junk, timezoneOffset
	      lineCtr = lineCtr + 1
	   !Line 32 Year, if using archival data for one year
	      read(thresh_in,*,err=115) junk, year
	      lineCtr = lineCtr + 1
	   !Line 33 Midnight = 2400 or 0000?
	      read(thresh_in,*,err=115) junk, midnightVal
	      lineCtr = lineCtr + 1
	   !Line 34 Plot file format for analyzed conditions
	      read(thresh_in,*,err=115) junk, plotFormat
	      lineCtr = lineCtr + 1
	   !Line 35 Record statistics?
	      read(thresh_in,*,err=115) junk, stats
	      lineCtr = lineCtr + 1
	   !Line 36 Folder to store output
	      read(thresh_in,*,err=115) junk, outputFolder
	      lineCtr = lineCtr + 1
	   !Line 37 is irrelevant
	      read(thresh_in,*,err=115) junk
	      lineCtr = lineCtr + 1
	      
	   !Allocate space for the stationLocation, stationNumber, and
	   !dataLocation arays
	      allocate (dataLocation(numStations),stationLocation(numStations),&
	                stationNumber(numStations))
	   !Line 38+ Fill in dataLocation, stationLocation, stationNumber arrays
              i = 1
              read(thresh_in,*,err = 115,iostat=iostatus) &
              tempStatNum, tempStatLoc, tempDataLoc
              do while (iostatus == 0)
                 if(i>numStations) then ! an error can occur if more files than numStations! {{{
                    if(numStations <= 0) then 
                       write(*,*) 
                       write(*,*) 'Number of stations must be greater than zero.'
                       write(*,*) 'Edit thresh_in.txt and restart thresh.'
                       write(*,*) 'Press Enter key to exit program.'
                       read(*,*) 
                       write(uout,*) 'Thresh analyzes station info to compute '
                       write(uout,*) 'rainfall totals for analysis of cumulative '
                       write(uout,*) 'precipitation and rainfall intensity-duration '
                       write(uout,*) 'thresholds for landslide occurrence.'
                       write(uout,*) 'Program uses input data files from rain gauges.'
                       write(uout,*) 'Number of gauges must be greater than zero.'
                       stop                       
                    else
                       write(*,*) 'Number of input files exceeds number of stations'
                       write(*,*) 'Edit the initialization file to either &
                       &increase maximum number of stations on 1st line or'
                       write(*,*) 'delete file names beginning on line ', lineCtr
                       write(*,*) 'Press Enter key to exit program.'
                       read(*,*)
                       stop 
                    end if 
                 end if !}}}
                 ! Assign data to its proper index in its proper variable.
                 stationNumber(i) = tempStatNum
                 stationLocation(i) = tempStatLoc
                 dataLocation(i) = tempDataLoc
                 stationNumber(i)=adjustl(stationNumber(i))
                 
                 ! Get next values for assignment to arrays, assuming i <= numStations and not eof.
                 read(thresh_in,*,err=115,iostat=iostatus,end=120) &
                 tempStatNum, tempStatLoc, tempDataLoc 
                 i = i + 1
                 lineCtr = lineCtr + 1
              end do
              120 continue
              
              ! if-block to assure that i and numStations have the same value
              if(i < numStations) then
                 write(*,*) 'Number of expected stations exceeds number of input files.'
                 write(*,*) 'Edit the initialization file to either &
                 &decrease number of stations on the first line or'
                 write(*,*) 'add file names beginning on line ', lineCtr
                 write(*,*) 'Press Enter key to exit program.'
                 read(*,*) 
                 stop
              end if

              
   !------------------------------------------------------------------------------!           
   !---------------CHECKING FOR DIFFERENCES FROM EXPECTED DATA ENTRIES------------!
   !------------------------------------------------------------------------------!
   	
   		  
   	! maxLines should be greater than zero. Thresh will exit otherwise.
   		if(maxLines <= 0) call error1(uout,'Number_Of_Data_Lines','zero')
	      
	   !Readings per hour should be between 1 and 60, inclusive. Thresh will exit otherwise
	      if (rph < 1) then
	         write(*,*) 'Thresh cannot use data collected on'
	         write(*,*) 'intervals longer than one hour.'
	         write(*,*) 'Press Enter key to exit program.'
	         read(*,*)
	         write(uout,*) 'Thresh cannot use data collected on'
	         write(uout,*) 'intervals longer than one hour.'
	         write(uout,*) 'Program exited due to an incompatible value.'
	         stop
	      else if(rph > 60) then
	      	write(*,*) 'Thresh cannot use data collected on'
	      	write(*,*) 'intervals shorter than one minute.'
	      	write(*,*) 'Press Enter key to exit program.'
	      	read(*,*)
	      	write(uout,*) 'Thresh cannot use data collected on'
	      	write(uout,*) 'intervals shorter than one minute.'
	      	write(uout,*) 'Program exited due to an incompatible value.'
	      	stop
	      end if
	      	         
	   !minTstormGap should be greater than zero.
	      if(minTstormGap <= 0) call error1(uout,'Hours_Between_Storms','zero')
	   
		!maxDataGap should be at least 1   		
	      if(maxDataGap < 1) maxDataGap = 1
	      
	   !maxDataGap must hold enough values to allow computation of storm durations
	   !for plot file
	      if(maxDataGap < 2 * numPlotPoints * rph + 1 .and. numPlotPoints > 0)&
	        maxDataGap = 2 * numPlotPoints * rph + 1

	   !Adjust numPlotPoints if need be
	      if(numPlotPoints2 > numPlotPoints) numPlotPoints2 = numPlotPoints

	   !Ensuring slope and intercept aren't both zero. All rainfall would be considered
	   !exceeding the threshold at that point
	      if(slope == 0 .and. intercept == 0) then
	     	 	write(uout,*) 'Slope_3_day_15_day_Threshold or Intercept_3_day_15_day_Threshold&
	     		& must be nonzero.'
   			write(uout,*) 'Thresh exited due to an incompatible value.'
   			write(*,*) 'Slope_3_day_15_day_Threshold or Intercept_3_day_15_day_Threshold&
	     		& must be nonzero.'
   			write(*,*) 'Edit thresh_in.txt and restart thresh.'
   			write(*,*) 'Press Enter key to exit program.'
   			read(*,*)
   			stop	 
	      end if
	  
	   !Ensuring year has a meaningful value
	      if(year < 0) year = sysYear
	      if(year == 0) then
	      	year = sysYear
	         lgyr = .true.
	      end if
	      
	   !Ensuring that resetAntMonth and resetAntDay have meaningful values. Thresh
	   !will exit otherwise.
	   	call check_antMonth_antDay(uout,year,resetAntMonth,resetAntDay)
	   		  	      
	   !Setting proper value for midnightVal. Default is midnight = 0
	      if(midnightVal /= 1) midnightVal = 0
	   
	   !Ensuring the value of plotFormat is in agreement with the expected values.
	   	if(plotformat /= 'gnp2' .and. plotformat /= 'dgrs') then
	   		plotformat = 'gnp1'	  
	      end if
	   !Ensuring there aren't multiple ID thresholds turned on.
	      call check_switches(uout,powerSwitch,polySwitch,interSwitch)
	      
	   !Checks and calculations on upLim and lowLim for powerSwitch
	      if(powerSwitch) then
	      	call set_power_limits(uout,lowLim,upLim)
	      	if(powerCoeff == 0) then
	      	   write(*,*) "Power coefficient cannot equal zero. This would result"
	      	   write(*,*) "in division by 0 later in the program. Edit thresh_in.txt"
	      	   write(*,*) "such that power coefficient is nonzero."
	      	   write(*,*) 'Press Enter key to exit program.'
	      	   read(*,*)
	      	   write(uout,*) "Power coefficient cannot equal zero. This would result"
	      	   write(uout,*) "in division by 0 later in the program."
	      	   write(uout,*) "Thresh exited due to this error."
	      	   stop
	      	end if
	      else if(polySwitch) then
	         call set_poly_limits(uout,lowLim,upLim)
	      else if(interSwitch) then
	      	if(intervals == 0) then
	      		write(uout,*) "Linear interpolating intervals must be greater than &
	      		&0."
	      		write(uout,*) "Edit thresh_in.txt and ensure that &
	      		&Number_of_Interpolating_Intervals attribute is greater than zero"
	      		write(*,*) "Linear interpolating intervals must be greater than &
	      		&0."
	      		write(*,*) "Edit thresh_in.txt and ensure that &
	      		&Number_of_Interpolating_Intervals attribute is greater than zero"
	      		write(*,*) 'Press Enter key to exit program.'
	      		read(*,*)
	      		stop
	      	end if

	      end if
	      
	   !Verifying that fcUnit is implemented in thresh
	      if(fcUnit /= 'mt' .and. fcUnit /= 'ft') then 
	         write(*,*) "The field capacity unit must be either 'ft' or 'mt'."
	         write(*,*) "Edit thresh_in.txt to ensure this is so."
	         write(*,*) 'Press Enter key to exit program.'
	         read(*,*)
	         write(uout,*) "The field capacity unit must be either 'ft' or 'mt'."
	         write(uout,*) "edit thresh_in.txt to ensure this is so."
	         write(*,*) "Thresh exited due to this error."
	         stop
	      end if
	   
	   !Verifying outputFolder exists
	      inquire(file=outputFolder,exist=exists)
	      if(.not. exists) then
	      	 command = 'mkdir "'//trim(adjustl(outputFolder))//'"'
	      	 call SYSTEM(command)  
	      end if

   ! Write variable values to file uout
	      write(uout,"(A19,I2)")                  'Number of stations ',numStations
	      write(uout,"(A29,I6)")                  'Maximum number of data lines ',maxLines
	      write(uout,"(A,I2)")                    'Readings per  hour ',rph
	      write(uout,"(A,I3)")                    'Length of recent time ',Trecent
	      write(uout,"(A,I3)")                    'Length of antecedent time ',Tantecedent
	      write(uout,"(A,I2)")                    'Intensity hours ',Tintensity
	      write(uout,"(A,I2)")                    'Hours between storms ',minTStormGap
	      write(uout,"(A,I2)")                    'Running average intensity hours ',TAvgIntensity
	      write(uout,"(A,I4)")                    'Maximum gap in data lines ',maxDataGap
	      write(uout,"(A,I3)")                    'Plot lines for long plot ',numPlotPoints
	      write(uout,"(A,I3)")                    'Plot lines for short plot ',numPlotPoints2
	      write(uout,"(A39,F5.2)")                'Slope of recent time / antecedent time ',slope
	      write(uout,"(A,F5.3)")                  'Intercept of recent time / antecedent time ',intercept
	      write(uout,"(A,L3)")                    'Will the power function be used? ',powerSwitch
	      if(powerSwitch) then
	         write(uout,"(A,F5.3,A2)")            'Power function coefficient (with units) ',powerCoeff,powerUnit
	         write(uout,"(A,F5.2)")               'Power function exponent ',powerExp
	      else if(polySwitch) then
	         write(uout,"(A,6F5.3)")              'Coefficients for polynomial function ',(polynomArr(i), i = 1,6)
	      else if(interSwitch) then
	      	write(uout,"(A,I2)")                 'Number of linear interpolating intervals ',intervals
	      end if
	      write(uout,"(A,I2,'/',I2)")             'Month and day to reset AWI ',resetAntMonth,resetAntDay
	      write(uout,"(A,F5.3,A2)")               'Seasonal antecedent threshold ',seasonalAntThresh, SATunit
	      write(uout,"(A,F5.3)")                  'Running average intensity threshold ',runningIntens
	      write(uout,"(A,F5.3)")                  'AWI threshold ',AWIThresh
	      write(uout,"(A,F5.3,A2)")               'AWI field capacity (with units) ',fieldCap,fcUnit
	      write(uout,"(A,F5.3)")                  'AWI drainage constant ',drainConst
	      write(uout,"(A,11(F5.3,', '),F5.3)")    'Monthly Evaporation constants ',(evapConst(i), i = 1,12)
	      write(uout,"(A,I4)")                    'Time zone offset ',timezoneOffset
	      write(uout,"(A5,I4)")                   'Year ',year
	      write(uout,"(A,L3)")                    'Read year from data file? ',lgyr
	      write(uout,"(A,I4)")                    'Midnight hour is ',midnightVal
	      write(uout,"(A,A5)")                    'Plot format ',plotformat
	      write(uout,"(A,L3)")                    'Output statistics? ',stats
	      write(uout,"(A,A)")                     'Name of output folder ',outputfolder

	      write(uout,*)'Station number ','File location ','Station Location'
	      do i = 1,numStations
	         write(uout,*)adjustr(stationNumber(i)),'       ',&
	         trim(dataLocation(i)),'    ',stationLocation(i)
	      end do
	      
	      
	   ! Calculations concerning completeness of data
      	checkS = check_SAT(resetAntMonth,resetAntDay,seasonalAntThresh)
	      checkA = check_AWI(AWIThresh, fieldCap, drainConst, evapConst)

         if(checkS) then
            if(fcUnit == "in") then
               if(SATunit == "mt") then
                  seasonalAntThresh = seasonalAntThresh * 39.3701
                  SATunit = "in"
               end if
            else if(fcUnit == "mt") then
               if(SATunit == "in") then
                  seasonalAntThresh = seasonalAntThresh * 0.0254
                  SATunit = "mt"
               end if
            end if

            AWIThresh = seasonalAntThresh
            evapConst = 0
            fieldCap = 0
	            	            
            if(checkA) then
               write(uout,*)
               write(uout,*)'Data complete for both Seasonal Antecedent&
                            & Threshold calculations and Antecedent Water Index calculations.'
               write(uout,*)'By default, thresh performs Seasonal Antecedent&
                            & Threshold calculations.'
               write(uout,*)'To complete AWI calculations, either replace&
                            & the reset month and day with "0,0" or change the value of the'
               write(uout,*)'Seasonal Antecedent Threshold to 0.'
               write(uout,*)
            else
               write(uout,*)'Data for AWI computations are incomplete. Seasonal&
                            & Antecedent Threshold data are complete, and computations were&
                            & completed using those values.'
            end if
         else
            if(.not. checkA) then
               resetAntMonth = 1
               resetAntDay = 1
               seasonalAntThresh = 0
               fcUnit = 'in'

               write(uout,*)
               write(uout,*)'The data for Seasonal Antecedent Threshold&
                             & calculations and Antecedent Water Index calculations are incomplete.'
               write(uout,*)'Annual cumulative precipitation was computed instead.'
               write(uout,*)
               write(uout,*)'To perform SAT calculations, ensure that the&
                            & reset month and day have meaningful values and that SAT is&
                            & a positive real number.'
               write(uout,*)'To perform AWI calculations, ensure that&
                            & AWI Threshold, field capacity, drain constant, and monthly&
                            & evaporation constants are all positive real numbers.'
               write(uout,*)
            end if
         end if
	      
         write(uout,*) '*-*-*-* End of Initialization Data *-*-*-*'
         close(thresh_in)
         return

         100 write(uout,*) 'Error opening file thresh_in.txt'
             write(uout,*) 'Program exited'
             close(uout)
             write(*,*) 'Error opening file thresh_in.txt'
             write(*,*) 'Press Enter key to exit program'
             read(*,*)
             stop
	          
         115 write(uout,*) 'Error in thresh_in.txt at line ', lineCtr
             write(uout,*) 'Program exited'
             close(uout)
             write(*,*) 'Error in thresh_in.txt at line ', lineCtr
             write(*,*) 'Press Enter key to exit program.'
             read(*,*)
             stop
      end subroutine read_init
! END OF SUBROUTINE}}}
	
    ! PURPOSE:
    !	   Reads Thlast.txt. This file contains information about ending time
    !    and state at each station (rain gauge).
    !	  
      subroutine read_thlast(threshLog,outputFolder,stationNumber,numStations,&
	   lastStorm,tstormBeg,tstormEnd,AWI_0,timestampHldr)!{{{
	   implicit none
	   integer,parameter :: double=kind(1d0)
      ! FORMAL ARGUMENTS
    	   character (len=*), intent(in) :: outputFolder
    	   character (len=*), intent(in) :: stationNumber(numStations)
	      real(double), intent(out)     :: lastStorm(numStations),tstormBeg(numStations)
	      real(double), intent(out)     :: tstormEnd(numStations)
	      real, intent(out)             :: AWI_0(numStations)
	      integer, intent(out)          :: timestampHldr(numStations)
	      integer, intent(in)           :: numStations,threshLog
		   
      ! LOCAL VARIABLES
    	   character (len=255) :: pathThlast
    	   character (len=8)   :: mstationNumber, unused(numStations), temp
    	   real(double)        :: mlastStorm,mtstormEnd,mtstormBeg
    	   real                :: mAWI
    	   integer             :: i, j, k, timestamps, uin = 77, iostatus
    	   integer             :: unusedSize
    	   logical             :: match,exists, done
    	   
    !------------------------------
        ! Construct path for Thlast.txt, confirm its existence
    	   pathThlast = trim(outputFolder)//'Thlast.txt'
    	   inquire(file=pathThlast,exist=exists)
    	   
    	! If the file exists, read from it an assign variables values from the file
    	   if(exists) then
    	   	done = .false.
    	   	iostatus = 0
    	   	unusedSize = numStations
    	      unused = stationNumber
    	      open(uin,file=pathThlast,status='old',err=100)
    	      do i = 1, numStations
    	         match = .false.
    	         !if block ensures that we aren't trying to read from Thlast after encountering eof.
    	         if(iostatus == 0) then
    	            read(uin,*,err=105,iostat=iostatus) mstationNumber, mlastStorm,&
    	            mtstormBeg, mtstormEnd, mAWI, timestamps
    	            mstationNumber = trim(mstationNumber)
    	            do j = 1, numStations
    	               if(trim(stationNumber(j)) == mstationNumber) then
    	                  match = .true.
    	                  lastStorm(j) = mlastStorm
    	                  tstormBeg(j) = mtstormBeg
    	                  tstormEnd(j) = mtstormEnd
    	                  AWI_0 = mAWI
    	                  timestampHldr(j) = timestamps
    	                  !unused is a list of yet-to-be-associated stations.
    	                  !do loop looks for the station just read from Thlast.txt
    	                  !in order to remove it from the array.
    	                  do k = 1, unusedSize
    	                  	if(trim(unused(k)) == mstationNumber) then
    	                  	   temp = unused(k)
    	                  	   unused(k) = unused(unusedSize)
    	                  	   unused(unusedSize) = temp
    	                  		unusedSize = unusedSize - 1
    	                  		!stop trying fo find a match, return control flow to do j = 1... loop
    	                  		exit
    	                  	end if
    	                  end do
    	                  !stop trying to find a match, return control flow to if(iostatus...) loop
    	                  exit
    	               end if
    	            end do
    	         end if
    	         !Handle the condition where there is a station missing from the init file
    	         if (.not. match .and. .not. done) then
    	            done = .true.
    	            write(*,*) 'No match for station(s) ', (unused(k), k =1,unusedSize),'.'
    	            write(*,*) 'Calculations for the above will be run from beginning of data.'
    	            write(*,*)
    	            write(threshLog,*) 'No match for station(s) ', (unused(k), k =1,unusedSize),'.'
    	            write(threshLog,*) 'Calculations for the above will be run from beginning of data.'
    	            write(threshLog,*)
    	         end if
    	      end do
    	      close(uin)
    	   end if
    	   return
    	   
    	   100 write(*,*) 'Error opening file ', pathThlast, '.'
    	       write(*,*) 'Program exited.'
    	       write(threshLog,*) 'Error opening file ', pathThlast, '.'
    	       write(threshLog,*) 'Program exited.'
    	       write(*,*) 'Press Enter key to exit program.'
    	       read(*,*) 
    	       stop    	   
    	   105 write(*,*) 'Error reading file ', pathThlast, '.'
    	       write(*,*) 'Program exited'
    	       write(threshLog,*) 'Error reading file ', pathThlast, '.'
    	       write(threshLog,*) 'Program exited.'
    	       write(*,*) 'Press Enter key to exit program.'
    	       read(*,*) 
    	       stop
	end subroutine read_thlast
! END OF SUBROUTINE}}}
	
   ! PURPOSE:
   !	  Reads from each station's individual data file. Sets stationPtr(i) in
   !    thresh.
	subroutine read_station_file(file, dataLocation, rph, lgyr, maxLines,&
	fileName, tyear,month, day, hour, precip, ctr, sysYear, sysMonth,&
	sysDay, sysHour, sysMinute, stationPtr, year, minute, uout, ctrHolder,&
	sumTrecent, sumTantecedent, intensity, sum3s, sum15s, intsys, def315s,&
	sthreshIntensityDuration, sthreshAvgIntensity, latestMonth, latestDay,&
	latestHour, latestMinute)!{{{
	implicit none

	! FORMAL ARGUMENTS
	   character (len=*), intent(in) :: fileName, dataLocation
	   integer, intent(in)  :: rph, file, sysMonth, sysDay, sysHour, sysYear
	   integer, intent(in)  :: sysMinute, year, maxLines, uout
	   integer, intent(out) :: tyear(maxLines),month(maxLines),day(maxLines),hour(maxLines)
	   integer, intent(out) :: precip(maxLines),ctr,minute(maxLines),stationPtr
	   logical :: lgyr
	   ! Arguments associated only with error statement
	   real, intent(out)    :: sumTrecent(*), sumTantecedent(*),intensity(*)
	   real, intent(out)    :: sum3s, sum15s, intsys,def315s
	   real, intent(out)    :: sthreshIntensityDuration, sthreshAvgIntensity
	   integer, intent(out) :: ctrHolder, latestMonth, latestDay, latestHour
	   integer, intent(out) :: latestMinute

	! LOCAL VARIABLES
	   integer   :: st, i=1, difference
	
   !------------------------------
	   open (file,file=trim(dataLocation),status='old',err=150)

	   if(rph==1) then ! read hourly data
	      if(lgyr) then ! read file format that includes year data
	         do i=1,maxLines
	            read (file,'(i2,i4,3i2,i4)',err=140,end=120)&
	            st,tyear(i),month(i),day(i),hour(i),precip(i)
	            ctr=i
	            if(month(i)==sysMonth .and. day(i)==sysDay .and. hour(i)==sysHour) then
	               if (tyear(i)==sysYear) stationPtr=i
	            end if
	         end do
	         
	      else ! read file format that excludes year data
	         do i=1,maxLines
	            read (file,'(4i2,i4)',err=140,end=120) &
	            &st,month(i),day(i),hour(i),precip(i)
	            ctr=i
	            if(month(i)==sysMonth .and. day(i)==sysDay .and. hour(i)==sysHour) then
	               if(year==sysYear) stationPtr=i
	            end if
	         end do
	      end if
	      
	   else if (rph>1 .and. rph<=60) then ! read xx-minute data
	      if(lgyr) then ! read file format that includes year data
	         do i=1,maxLines
	            read (file,'(i2,i4,4i2,i4)',err=140,end=120) &
	            &st,tyear(i),month(i),day(i),hour(i),minute(i),precip(i)
	            ctr=i
	            if(month(i)==sysMonth .and. day(i)==sysDay .and. hour(i)==sysHour) then
	               difference=(sysMinute-minute(i))
	               if (tyear(i)==sysYear .and. difference<(60/rph) .and. &
	                   difference>=0) stationPtr=i
	            end if
	         end do
	         
	      else ! read file format that excludes year data
	         do i=1,maxLines
	            read (file,'(5i2,i4)',err=140,end=120) &
	            &st,month(i),day(i),hour(i),minute(i),precip(i)
	            ctr=i
	            if(month(i)==sysMonth .and. day(i)==sysDay .and. hour(i)==sysHour) then
	               difference=(sysMinute-minute(i))
	               if(year==sysYear .and. difference<(60/rph) &
	                  .and. difference>=0) stationPtr=i
	            end if
	         end do
	      end if
	   end if
           120 return

	   140 write(*,*) 'Error reading file ', fileName
  	       write(*,*) 'at line ', i
  	       write(*,*) 'Press Enter key to exit program.'
  	       read(*,*)
  	       write(uout,*) 'Error reading file ', fileName		
  	       write(uout,*) 'at line ', i
  	       close (uout)
  	       stop
  	   150 write (uout,*) 'Error opening file ', trim(dataLocation)
  	       write (*,*) 'Error opening file ', trim(dataLocation)
	       ctrHolder = 1
  	       sumTrecent(i) = -99.
	       sumTantecedent(i) = -99.
	       intensity(i) = -99.
	       sum3s = -99.
	       sum15s = -99.
	       intsys = -99.
	       def315s = -99.
	       sthreshIntensityDuration = -99.
	       sthreshAvgIntensity = -99.
	       latestMonth = -99
	       latestDay = -99
	       latestHour = -99
	       latestMinute = -99
  	end subroutine
 ! END OF SUBROUTINE}}}

   ! PURPOSE:
   !	  Reads interpolating_points.txt. This file contains duration and
   !	  cumulative precipitation pairs. The values from interpolating_points.txt
   !	  are stored in xVal, yVal.
   subroutine read_interpolating_points(xVal,yVal,intervals) !{{{
   implicit none
   
   ! FORMAL ARGUMENTS
   real 		:: xVal(*), yVal(*)
   integer 	:: intervals
   ! LOCAL VARIABLES
   character(len=23), parameter :: FILENAME="interpolatingPoints.txt"
   real 		:: m, b
   integer  :: unit=666, i

   !------------------------------

      open(unit,file=FILENAME,err=100,status="old")
      
      do i=1,intervals+1
         read(unit,*) xVal(i), yVal(i)
      end do
      !Extending lower bound.
	     	m = (yVal(2) - yVal(1)) / (xVal(2) - xVal(1))
	     	b = yVal(2) - m * xVal(2)
	     	xVal(2) = 0.85 * xVal(2)
	     	yVal(2) = m * xVal(2) + b
	   
	   !Extending upper bound.
	     	m = (yVal(intervals+1) - yVal(intervals)) / &
	     	    (xVal(intervals+1) - xVal(intervals))
	     	b = yval(intervals+1) - m * xVal(intervals+1)
	     	xVal(intervals+1) = 1.15 * xVal(intervals+1)
	     	yVal(intervals+1) = m* xVal(intervals+1) + b
      return
      
      100 write(*,*)"The file ", FILENAME, " could not be opened."
      	 write(*,*)"Ensure that the file exists in the same directory as"
      	 write(*,*)"Thresh."
      	 write(*,*)'Press Enter key to exit program.'
      	 read(*,*)
      	 stop
   end subroutine read_interpolating_points !}}}
 			
end module
