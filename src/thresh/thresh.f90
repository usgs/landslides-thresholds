! PURPOSE:
!  Program to compute rainfall totals for analysis of cumulative 
!  precipitation and rainfall intensity-duration thresholds for landslide
!  occurrence.  Program uses input data files with fixed width fields for station
! number, date, time and rainfall increment.
!
! Originally written by Rex Baum, U.S. Geological Survey, 
!  January 3 & 4, 2002 with subsequent revisions through 2008.
! Updated and revised by Jacob Vigil and Rex Baum, 2013 & 2014.
! Additional revisions by Sarah Fischer and Rex Baum, summer 2015.
! Latest revisions by Rex Baum, November 2017.
! 		  
! VARIABLE NAMING CONVENTIONS
!	These conventions are consistent throughout all files related to 
!	program thresh. 
	! m   	reserved as a prefix as an abbreviation for "member". Used
	!	      for subroutine and function member variables with similar
	!	      purpose to formal arguments to subroutines and functions.
	! max 	reserved as a prefix for variables that serve as upper 
	!	      bounds on data.
	! num 	reserved as a prefix for variables that represent the length 
	!	      of a denumerable list.
	! s   	reserved as a prefix as an abbreviation for "station".
	! sys 	reserved as a prefix as an abbreviation for "system".
	! T   	reserved as a prefix for variables that measure intervals 
	!	      of time.
	! t   	reserved as a prefix for variables that represent instances 
	!	      in time.
		
	program thresh
	use external_files 	!contains read_init, read_thlast, read_station_file, read_interpolating_points
	use plotting 		   !contains gnp1, gnp2, dgrs
	use data_analysis 	!contains track_storm, track_intensity, count_events
	use tablhtm_colors	!contains tablhtm, read_colors
	implicit none
	integer,parameter :: double=kind(1d0)
	
! LOCAL VARIABLES {{{
		  
	integer,allocatable :: timestampMonth(:),da(:)
	integer,allocatable :: hr(:),precip(:),ctrHolder(:)
	integer,allocatable :: stationPtr(:),latestDay(:)
	integer,allocatable :: latestMonth(:),latestHour(:)
	integer,allocatable :: timestampYear(:),latestYear(:)
	integer,allocatable :: mins(:),latestMinute(:)
	integer,allocatable :: pt_recent_antecedent(:),ptid(:),ptia(:),ptira(:),ptawid(:)
	integer,allocatable :: tlenx(:),numTimestampsHolder(:)		  
		  
	integer :: numStations,maxLines,nlo20
	integer :: i,ctr,sysMonth,sysDay,sysHour
	integer :: imid,tptr,xptr,timezoneOffset,sysYear
	integer :: sysMinute,sysSeconds,lastDayOfMonth(12)
	integer :: midnightVal,sumTintensity
	integer :: maxDataGap,year 
	integer :: unitNumber(10),Trecent
	integer :: Tantecedent,rph,numNewLines,fmins
	integer :: ev_recent_antecedent,evid,evia,evira
	integer :: evawid,resetAntMonth,resetAntDay
	integer :: tRainfallBegan,tRainfallEnd
	integer :: TstormGap
	integer :: numPlotPoints,numPlotPoints2,numPlotPoints3
	integer :: AWICompOffset,intervals
	integer :: ctr_recent_antecedent,ctrid,ctria,cumAntecedentRainfallCtr,ctra
	integer :: ctri,AWIExceedCtr,AWIIntensCtr
	integer :: ctrira,diffPtrOffset
	integer :: ndiv,j


	character (len=255),allocatable:: dataLocation(:)
	character (len=50), allocatable:: stationLocation(:)
	character (len=20), allocatable:: datimb(:)
	character (len=17), allocatable:: datim(:)	
	character (len=8), allocatable:: stationNumber(:)
	character (len=6), allocatable :: colors(:)
	character (len=38), allocatable :: hexColors(:)

	character (len=255) :: outputFile,pathThlast
	character (len=255) :: outputFolder
	character (len=31) :: archiveFile='ThArchive'
	character (len=31) :: defaultOutputFile='ThCurr.txt'
	character (len=31) :: dgOutputfile='ThCTpairs.txt'
	character (len=31) :: updateFile='ThUpdate.txt'
	character (len=11) :: latestDate,revdate
	character (len=10) :: fdat,sysTime
	character (len=8) :: timeSeriesPlotFile='ThTSplothr.txt'
	character (len=8) :: sysDate,vrsn
	character (len=6) :: psn(2)
	character (len=6) :: timeSeriesExceedFile='ThTime.txt'
	character (len=5) :: latestTime
	character (len=4) :: plotFormat
	character (len=3) :: month(12)
	character (len=2) :: fcUnit,thresholdUnit, precipUnit
	character (len=1) :: pd,cm
	
	logical :: lgyr,stats,flagRealtime,powerSwitch,polySwitch,interSwitch,forecast,date_err
	Logical :: checkS, checkA

	real,allocatable :: threshIntensityDuration(:),threshAvgExceed(:)
	real,allocatable :: AWI(:),AWI_0(:),sAWI(:), xVals(:), yVals(:)
	real,allocatable :: sumTrecent(:),sumTantecedent(:)
	real,allocatable :: intensity(:),dur(:)
	real,allocatable :: runIntensity(:),deficit_recent_antecedent(:)
	real,allocatable :: sumRecent_s(:),sumAntecedent_s(:),intsys(:),durs(:)
	real,allocatable :: srunIntensity(:),deficit_recent_antecedent_s(:)
	real,allocatable :: sthreshIntensityDuration(:)
	real,allocatable :: sthreshAvgIntensity(:)
	real, allocatable:: div(:)
	
 	real :: slope,intercept,in2mm,id_index_factor
 	real :: powerCoeff,powerExp,runningIntens,drainConst,fieldCap,decayFactor
 	real :: AWIconversion,evapConsts(12),AWIThresh,seasonalAntThresh
 	real :: awimx,sumRecentmx,rntsymx
 	real :: polynomArr(6),upLim, lowLim, date_dif
        real :: minTStormGap,Tintensity,TavgIntensity 

	real (double),allocatable:: eachDate1904(:),last1904(:)
	real (double),allocatable:: newest1904(:)
	real (double),allocatable:: tstormBeg1904(:),tstormEnd1904(:)
	
	real (double):: trfbeg,trfend,dgap !}}}
	
!------------------------------
	
! get system time and date
     	call date_and_time(sysDate,sysTime)
     	
! date of latest revision & version number (added 05/18/2006)	
     	revdate='27 Nov 2017'; vrsn=' 1.0.026'
     	
! extract system month, day, year, hour, minute, and second from "sysDate" and "sysTime"
  	sysMonth=imid(sysDate,5,6)
  	sysDay=imid(sysDate,7,8)
	sysYear=imid(sysDate,1,4)
  	sysHour=imid(sysTime,1,2)	
  	sysMinute=imid(sysTime,3,4)	
  	sysSeconds=imid(sysTime,5,6)

! initialize variables
	month=(/'Jan','Feb','Mar','Apr','May','Jun','Jul',&
        'Aug','Sep','Oct','Nov','Dec'/)
	psn=(/'append','rewind'/)
	midnightVal=0
	unitNumber=(/11,12,13,14,15,16,17,18,19,20/)
	lastDayOfMonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)
	lgyr=.false.;flagRealtime=.true.
	maxLines=366*24
	
	runningIntens=0.1
	
! pd is the pound (number) sign, cm is comma
	pd=char(35)
	cm=char(44)	
	call titl(sysTime,sysDate,vrsn,revdate) ! Print banner on terminal
	
! open log file and log current system time
	open (unitNumber(1),file='ThreshLog.txt',status='unknown',position='rewind')
      	write (unitNumber(1),*) sysTime(1:2),':',sysTime(3:4),':',&
	&sysTime(5:6),' ',sysDate(5:6),'/',sysDate(7:8),&
	&'/',sysDate(1:4)
	write(unitNumber(1),*) 'thresh version, ',vrsn,' ',revdate
	
! read initialization file & save copy to log file
	call read_init(unitNumber(1),numStations,maxLines,rph,Trecent,&
	Tantecedent,Tintensity,minTStormGap,TavgIntensity,maxDataGap,&
	numPlotPoints,numPlotPoints2,slope,intercept,powerCoeff,thresholdUnit,&
	powerExp,powerSwitch,polynomArr,seasonalAntThresh,runningIntens,&
	AWIThresh,fieldCap,fcUnit,drainConst,evapConsts,resetAntMonth,resetAntDay,&
	timezoneOffset,year,lgyr,midnightVal,plotFormat,stats,outputFolder,&
	dataLocation,stationLocation,stationNumber,sysYear,upLim,lowLim,&
	interSwitch,intervals,polySwitch,precipUnit,forecast,checkS,checkA)
	
! precipitation input data stored as hundredths of an inch
	select case (fcUnit)
  		case ('m'); AWIconversion=25.4/100000.
  	   	case ('in'); AWIconversion=1./100.
  	   	case default; AWIconversion=1.
	end select
	write(unitNumber(1),*) 'Conversion factor for AWI', AWIconversion
! unit conversion factor for plot files
 	select case (precipUnit)
  	   case ('mm'); in2mm=1.
  	   case default; in2mm=25.4
	end select
! unit Conversion factor for threshold index
        select case (precipUnit)
          case ('in');
  	select case (thresholdUnit)
  	   case ('mm'); id_index_factor=25.4
  	   case ('in'); id_index_factor=1.
  	   case default; id_index_factor=1.
	end select
          case ('mm');
  	select case (thresholdUnit)
  	   case ('mm'); id_index_factor=1.
  	   case ('in'); id_index_factor=1./25.4
  	   case default; id_index_factor=1.
	end select
        end select 
	write(unitNumber(1),*) 'Conversion factor for average intensity', in2mm
	
! if using linearly interpolated defined threshold, perform relevant tasks.
	if(interSwitch) then
	   allocate(xVals(intervals + 1), yVals(intervals + 1))
	   call read_interpolating_points(xVals,yVals,intervals,stats,unitNumber(1))
	   lowLim = xVals(1)
	   upLim = xVals(intervals+1)
	end if

! Output mode-cancel output of files used in continuous operations when analyzing statistics
        if(stats) flagRealtime=.false.
	
! allocate and initialize arrays 
	allocate (timestampMonth(maxLines),da(maxLines),hr(maxLines),precip(maxLines))
	allocate (eachDate1904(maxLines),last1904(numStations),newest1904(numStations))
	allocate (latestDay(numStations),latestMonth(numStations),latestHour(numStations))
	allocate (stationPtr(numStations),ctrHolder(numStations))
	allocate (sumTrecent(maxLines),sumTantecedent(maxLines),deficit_recent_antecedent(maxLines))
	allocate (intensity(maxLines),runIntensity(maxLines))
	allocate (threshIntensityDuration(maxLines),threshAvgExceed(maxLines))
	allocate (dur(maxLines))
	allocate (tstormBeg1904(numStations),tstormEnd1904(numStations))
	allocate (sumRecent_s(numStations),sumAntecedent_s(numStations))
	allocate (intsys(numStations),durs(numStations),srunIntensity(numStations))
	allocate (deficit_recent_antecedent_s(numStations),sthreshIntensityDuration(numStations),sthreshAvgIntensity(numStations))
	allocate (timestampYear(maxLines),latestYear(numStations),datim(numStations),datimb(numStations))
	allocate (AWI(maxLines),AWI_0(numStations),tlenx(numStations),numTimestampsHolder(numStations))
	allocate (sAWI(numStations))
 	allocate (mins(maxLines),latestMinute(numStations)) ! assumes that hourly data are summed on the hour
 	! next line assumes that threshold exceedences will occur less than 20% of time
 	nlo20=maxLines/5
 	allocate (pt_recent_antecedent(maxLines),ptid(nlo20),ptia(nlo20),ptira(nlo20),ptawid(nlo20))
	sumRecent_s = 0.
	sumAntecedent_s = 0.
	intsys = 0.
	srunIntensity = 0.
	durs = 0.
	newest1904 = 0.d0
	stationPtr = 0 !  pointer array
	ctrHolder = maxDataGap
	dgap = minTStormGap / 24.d0
	latestMinute = 0
	pt_recent_antecedent = 0; ptid = 0; ptia = 0; ptira = 0; ptawid = 0
	last1904 = 0.
	tstormBeg1904 = 0.
	tstormEnd1904 = 0.
	AWI_0 = 0.
	numTimestampsHolder = 0
	
! Call subroutine read_thlast to read Thlast.txt to set starting times based on previous data. 
	call read_thlast(unitNumber(1),outputFolder,stationNumber,numStations,&
	last1904,tstormBeg1904,tstormEnd1904,AWI_0,numTimestampsHolder,stats)
 	
! if data files list precipitation at the end of each hour, 1-24 convert current
! hour to 24 for time between midnight and 1:00 a.m. for matching most recent
! data to current hour
	if(sysHour==0 .and. midnightVal==1) then
      call ihr24(sysMonth,sysDay,sysYear,sysHour)
   end if
	
! adjust system time to agree with time zone of server where data originates
	sysHour=sysHour+timezoneOffset
	
! check for leap year and adjust number of days in February 
	if (mod(year,4)==0 .and. mod(year,100) /= 0 .or. mod(year,400) == 0)&
	lastDayOfMonth(2)=29
	
! correct date if offset straddles midnight
	if(sysHour>24) then
	   sysHour=sysHour-24
	   if(sysHour==24 .and. midnightVal/=1) sysHour=sysHour-1
	   sysDay=sysDay+1
	   if(sysDay>=lastDayOfMonth(sysMonth)) then
	      sysDay=sysDay-lastDayOfMonth(sysMonth)
	      sysMonth=sysMonth+1
 	      if(sysMonth>12) sysMonth=sysMonth-12
	   end if  
	end if

	if(sysHour<0) then
	   sysHour=sysHour+24
	   sysDay=sysDay-1
	   if(sysDay<=0) then
	      sysDay=lastDayOfMonth(sysMonth-1)
	      sysMonth=sysMonth-1
	      if(sysMonth<1) sysMonth=sysMonth+12
	   end if  
	end if

! read data files and compute precipitation totals, intensity, & duration
                date_err=.false. ! used to control operations when non-sequential input data are found.
	do i=1,numStations !{{{
	   if (trim(stationNumber(i))=='0') cycle
	   ctr=0  ! initialize counters
	   ctr_recent_antecedent=0; cumAntecedentRainfallCtr=0; ctrid=0; ctrira=0
	   ctria=0; ctra=0; ctri=0; AWIExceedCtr=0; AWIIntensCtr=0
	   precip=0 ! initialize 1-d arrays
	   threshIntensityDuration = 0.

	   threshAvgExceed=0. ! replace intensity antecedent with running average intensity
	   deficit_recent_antecedent=-1.-intercept
	   sumTrecent=0.
	   sumTantecedent=0.
	   intensity=0.
	   runIntensity=0.
	   dur=0.
	   AWI=0.;awimx=0.
	   timestampYear=year 
	   
! assume that for midnight=0 that rainfall is through the end of the listed hour
	   if (rph==1 .and. midnightVal==0) then
	      mins=59
	   else
	      mins=0
	   end if
! Read individual station files in dataLocation(i) and find the most recent
! data collected.	
	   call read_station_file(unitNumber(3),dataLocation(i), rph, lgyr,&
	   maxLines,dataLocation(i), timestampYear, timestampMonth, da, hr,&
	   precip, ctr,sysYear, sysMonth, sysDay, sysHour, sysMinute,&
	   stationPtr(i), year, mins, unitNumber(1),ctrHolder(i),sumTrecent,&
	   sumTantecedent, intensity, sumRecent_s(i), sumAntecedent_s(i), intsys(i),&
	   deficit_recent_antecedent_s(i),sthreshIntensityDuration(i), sthreshAvgIntensity(i),&
	   latestMonth(i), latestDay(i), latestHour(i), latestMinute(i),forecast,stats)  
	

! set pointer to end of file if no times match the current system time	
	   if(stationPtr(i)==0) stationPtr(i)=ctr
	   
! get date and time of latest data in file	
	   if(stationPtr(i)==0) then
	      latestMonth(i)=-99; latestDay(i)=-99
	      latestHour(i)=-99; latestYear(i)=-99; latestMinute(i)=-99
  	      close (unitNumber(3))
  	      write(*,*) 'Closing file ', trim(dataLocation(i))
  	      write(unitNumber(1),*) 'Closing file ', trim(dataLocation(i))
  	      write(*,*) 'final date unknown'
  	      write(unitNumber(1),*)  'final date unknown'
	      cycle
	   else
	      latestMonth(i)=timestampMonth(stationPtr(i)); latestDay(i)=da(stationPtr(i))
	      latestHour(i)=hr(stationPtr(i)); latestYear(i)=timestampYear(stationPtr(i))
  	      write(*,*) i,'final date', latestMonth(i),'/',latestDay(i),'/',latestYear(i)
  	      write(unitNumber(1),*)  i,'final date', latestMonth(i),'/',latestDay(i),'/',latestYear(i)
	      latestMinute(i)=mins(stationPtr(i))
	   end if
	   
  	   close (unitNumber(3))
	   call s1904t(eachDate1904,timestampYear,timestampMonth,da,hr,mins,ctr,maxLines) 
	   newest1904(i)=eachDate1904(stationPtr(i))

!  check to confirm that data are in order, added 8-9 Nov 2016
! Enabled only in statistics mode.  Checks all input files before exiting.
                   if(stats) then
                       do j=1, stationPtr(i)-1
                          date_dif=eachDate1904(j+1)-eachDate1904(j)
                          if(date_dif<0.) then
                             write(*,*) 'Date anomaly in file --> ',trim(dataLocation(i)),' <-- near line ',j
                             write(*,*) '### Check input file for data that are out of order! ####'
                             write(unitNumber(1),*) 'Date anomaly in file --> ',trim(dataLocation(i)),' <-- near line ',j
                             write(unitNumber(1),*) '### Check input file for data that are out of order! ####'
                             date_err=.true.
                          end if
                       end do
                       if (date_err .and. i>=numStations) then
                          write(unitNumber(1),*) 'Program thresh exited.  Non-sequential input data detected'
                          close(unitNumber(1))
                          stop 'Program thresh exiting!! Check and correct input file before proceeding.'
                       else if (date_err .and. i<numStations) then
                          cycle
                       end if
                   end if
!	   
 	   numNewLines=int(rph*24*(newest1904(i)-last1904(i)))
 	   
 	   if(numNewLines>=ctr) ctrHolder(i)=ctr
	   if(numNewLines>0 .and. numNewLines<ctr) then 
	      ctrHolder(i)=numNewLines
	   end if
	   
	   if(numNewLines==0) ctrHolder(i)=1
	   if(numNewLines<0) then ! blank lines at end of input file cause errors
	      write (*,*) i,'station ', stationNumber(i),':'
	      write (*,*) 'End date earlier than start date--check input file for blank lines'
	      write (unitNumber(1),*) i,'station ', stationNumber(i),':'
	      write (unitNumber(1),*) 'End date earlier than start date--check input file for blank lines'
	      cycle
	   end if
	   write (*,*) i,'Processing station ', stationNumber(i)
	   if(tstormBeg1904(i)==0.) then
	      tRainfallBegan=1
	      if(midnightVal==0) then
	         tstormBeg1904(i)=eachDate1904(1)  
	      else
	         tstormBeg1904(i)=eachDate1904(1)-1.d0/(float(rph)*24.d0)  
	      end if
	   end if
	   
	   if(tstormEnd1904(i)==0.) then
	      if(midnightVal==0) then
	         tstormEnd1904(i)=eachDate1904(1) 
	      else 
	         tstormEnd1904(i)=eachDate1904(1)-1.d0/(float(rph)*24.d0) 
	      end if
	   end if
	   
	   write(*,*) 'Starting times:',tstormBeg1904(i),tstormEnd1904(i)
 	 
	   tlenx(i)=ctrHolder(i)
	   AWICompOffset=numTimestampsHolder(i)+numNewLines !added 01/07/2008
	   if(AWICompOffset<1 .or. AWICompOffset>stationPtr(i))then
	     AWICompOffset=stationPtr(i)
	   end if
	   if(tlenx(i)<2*numPlotPoints*rph .and. numPlotPoints>0) then ! tlenx shorter than 2 x moving window for plotting
	      if((1+stationPtr(i)-2*numPlotPoints*rph)>0) then ! longer history than 2 x moving window for plotting
	      	 tlenx(i)=2*numPlotPoints*rph	
	      else
	         tlenx(i)=stationPtr(i) 	! set beginning at beginning of data if shorter
	      end if                    	! than 2 x plotting window
	   end if
	   if(eachDate1904(1+stationPtr(i)-tlenx(i))<tstormBeg1904(i)) then 
	      tstormBeg1904(i)=0.d0	! zero the storm beginning and ending 
	      tstormEnd1904(i)=0.d0	! times if later than beginning of data 
	   end if
	 
!	 AWI(stationPtr(i)-tlenx)=AWI_0(i)-fieldCap  ! incorrect, offsets time Jan 2008
!	 AWI(stationPtr(i)-AWICompOffset)=AWI_0(i)-fieldCap 
	
	 ! if block added 4/14/2013 to prevent segmentation faults at previous line, RLB
      if(stationPtr(i) - AWICompOffset == 0) then 
         diffPtrOffset = 1		! At beginning of rainfall data file
      else
     	   diffPtrOffset = stationPtr(i) -AWICompOffset
      end if
         AWI(diffPtrOffset) = AWI_0(i) - fieldCap
         
	   decayFactor=exp(-drainConst*1./float(rph))
	   
	   call track_storm(diffPtrOffset,stationPtr(i),precip,resetAntMonth,&
	   resetAntDay,AWI,AWIconversion,evapConsts,timestampMonth,decayFactor,&
	   drainConst,fieldCap,da,hr,TavgIntensity,rph,runIntensity,sumTintensity,&
	   minTStormGap,TstormGap,tRainfallBegan,trfbeg,eachDate1904,tstormBeg1904(i),&
	   tRainfallEnd,trfend,tstormEnd1904(i),dgap,xptr,intensity,dur,numStations,&
	   maxLines,Tintensity,precipUnit)

	   ! compute intensity & duration at beginning of record
	   if(precip(1)>0 .and. last1904(i)==0.d0) then 
	      dur(1)=1.d0/(float(rph))
	      intensity(1)=float(precip(1))/(dur(1)*100.d0)
	   end if
	   
	   ! step through computations for each file	   
	   call track_intensity(stationPtr(i),maxLines,tlenx(i),sumTintensity,&
	   sumTrecent,sumTantecedent,tptr,Trecent,rph,xptr,precip,Tintensity,&
	   TavgIntensity,Tantecedent,cumAntecedentRainfallCtr,intensity,runIntensity,&
	   runningIntens,ctri,ctra,intercept,slope,deficit_recent_antecedent,ctr_recent_antecedent,&
	   pt_recent_antecedent,ctrira,ptira,awimx,AWI,AWIExceedCtr,powerSwitch,polySwitch,&
	   interSwitch,intervals,xVals,yVals,threshIntensityDuration,in2mm,&
	   powerCoeff,dur,powerExp,polynomArr,ctrid,ptid,AWIThresh,AWIIntensCtr,&
	   ptawid,threshAvgExceed,ctria,nlo20,ptia,id_index_factor)

	   write (unitNumber(1),*) i, ' Completed station ', stationNumber(i) 
	   
! Count "events" -- Continuous periods of threshold exceedence 
	   if(stats) then	!{{{
	      call count_events(ev_recent_antecedent,ctr_recent_antecedent,pt_recent_antecedent,rph,minTStormGap)
	      call count_events(evid,ctrid,ptid,rph,minTStormGap)
	      call count_events(evia,ctria,ptia,rph,minTStormGap)
	      call count_events(evira,ctrira,ptira,rph,minTStormGap)
	      call count_events(evawid,AWIIntensCtr,ptawid,rph,minTStormGap)
	      sumRecentmx=maxval(sumTrecent)/float(Trecent*rph) ! Added maxima 1 Aug 2006
	      rntsymx=maxval(runIntensity)
 	      write (unitNumber(1),*) '--------------- Threshhold statistics ---------------' 
 	      write (unitNumber(1),*) 'Threshold hours                   Total    Exceedance'	 
 	      write (unitNumber(1),*) 'Recent/antecedent                 ',cumAntecedentRainfallCtr, ctr_recent_antecedent	 
 	      write (unitNumber(1),*) 'Recent/antecedent & ',TavgIntensity,'-h intensity',cumAntecedentRainfallCtr, ctrira	 
 	      write (unitNumber(1),*) 'Intensity-duration           ',ctri, ctrid	 
 	      write (unitNumber(1),*) 'Maximum intensity, ',sumRecentmx,', ',Trecent,'-hour duration (Trecent)' 
 	      write (unitNumber(1),*) 'Maximum intensity, ',rntsymx,', ',TavgIntensity,'-hour duration (TavgIntensity)' 
 	      write (unitNumber(1),*) 'Antecedent water index       ','-- ',AWIExceedCtr
 	      write (unitNumber(1),*) 'Antecedent water index & intensity-duration ',AWIIntensCtr
 	      write (unitNumber(1),*) TavgIntensity,'-h intensity        ',ctra, ctria
 	      write (unitNumber(1),*) '** Number of continuous periods above threshold **' 
 	      write (unitNumber(1),*) Trecent,'-h/',Tantecedent,'-h                             ',ev_recent_antecedent	 
 	      write (unitNumber(1),*) 'Intensity-duration                       ',evid	 
 	      write (unitNumber(1),*) 'Intensity-duration & antecedent water    ',evawid	 
 	      write (unitNumber(1),*) TavgIntensity,'-h intensity                    ',evia
 	      write (unitNumber(1),*) Trecent,'-h/',Tantecedent,'-h & ',TavgIntensity,'-h intensity  ',evira
 	      write (unitNumber(1),*) '' 
 	      write (unitNumber(1),*) 'Max. antecedent water index ',awimx
 	      write (unitNumber(1),*) '--------------- ********************* ---------------' 
 	      write (unitNumber(1),*) '' 
 	   end if	!}}} 
 	   
! set latestTime and fdat for latest time at last1904 station in the list 
	   fmins=mins(tptr)
	   
! assume that for midnight=0 that rainfall is through the end of the listed hour
	   write(latestTime,'(i2.2,a1,i2.2)') hr(tptr),':',fmins
	   write(fdat,'(i2.2,a1,i2.2,a1,i4)') &
           timestampMonth(tptr),'/',da(tptr),'/',timestampYear(tptr)
	   write(latestDate,'(i2.2,1x,a3,1x,i4)') &
           da(tptr),month(timestampMonth(tptr)),timestampYear(tptr)
           
! copy current values from 1-d time-series arrays to 1-d station series array for plotter output 	  
	   sumRecent_s(i)=sumTrecent(stationPtr(i))
	   sumAntecedent_s(i)=sumTantecedent(stationPtr(i))
	   intsys(i)=intensity(stationPtr(i))
	   durs(i)=dur(stationPtr(i))
	   srunIntensity(i)=runIntensity(stationPtr(i))
	   deficit_recent_antecedent_s(i)=deficit_recent_antecedent(stationPtr(i))
	   sthreshIntensityDuration(i)=threshIntensityDuration(stationPtr(i))
	   AWI_0(i)=AWI(1 + stationPtr(i)-tlenx(i))+fieldCap !Corrected 6/18/2013
	   sthreshAvgIntensity(i)=threshAvgExceed(stationPtr(i))
	   sAWI(i)=AWI(stationPtr(i))
	   
	   if(latestMonth(i)==-99) then
	      write(datim(i),*) '--------'
	      write(datimb(i),*) '----','<br>','----'
	   else
	      write(datim(i),'(i2.2,a1,i2.2,1x,i2.2,1x,a3,1x,i4)') &
	      latestHour(i),':',latestMinute(i),latestDay(i),month(latestMonth(i)),latestYear(i)
	      write(datimb(i),'(i2.2,a1,i2.2,a4,i2.2,1x,a3,1x,i4)') &
	      latestHour(i),':',latestMinute(i),'<br>',latestDay(i),month(latestMonth(i)),latestYear(i)
	   end if
!if (stationPtr(i)-numPlotPoints*rph <= 0) numPlotPoints = stationPtr(i)/rph
! Create or update time-series plot file for each station

 	   if(stationPtr(i)>=numPlotPoints*rph .and. numPlotPoints>0) then
 	      call gnpts(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),numPlotPoints,stationPtr(i),timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,AWI,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesPlotFile,stationLocation(i),in2mm,rph,&
 	      TavgIntensity,Tantecedent,Trecent,precipUnit,checkS,checkA,stats)
	   else if (stationPtr(i)>=numPlotPoints2*rph .and. numPlotPoints>0) then
	   	  numPlotPoints3=stationPtr(i)/rph   ! replaced ctrHolder(i) with numPlotPoints3 7/29/2015, RLB
 	      call gnpts(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),numPlotPoints3,stationPtr(i),timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,AWI,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesPlotFile,stationLocation(i),in2mm,rph,&
 	      TavgIntensity,Tantecedent,Trecent,precipUnit,checkS,checkA,stats)
	   end if
	   
! Create or update short-term time-series plot file for each station	
 	   if(flagRealtime) then
 	      if(stationPtr(i)>=numPlotPoints2*rph .and. numPlotPoints2>0) then
 	         call gnpts(unitNumber(1),unitNumber(5),maxLines,&
 	         stationNumber(i),numPlotPoints2,stationPtr(i),timestampYear,&
 	         timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	         dur,precip,runIntensity,AWI,deficit_recent_antecedent,&
 	         threshIntensityDuration,threshAvgExceed,outputFolder,timeSeriesPlotFile,&
                 stationLocation(i),in2mm,rph,TavgIntensity,Tantecedent,Trecent,precipUnit,&
                 checkS,checkA,stats)
 	      end if
	   end if
	   
! Create or update time-series archive file for each station	 
 	   if (abs(newest1904(i)-last1904(i))<(0.1/(24.*rph))) cycle 
 	  if(forecast .eqv. .FALSE.) then
 	   if(stationPtr(i)>0) then 
! 	        numPlotPoints3=stationPtr(i)/rph
 	      call arcsav(unitNumber(1),unitNumber(5),&
 	      maxLines,stationNumber(i),ctrHolder(i),&	! replaced ctrHolder(i) with numPlotPoints3 8/4/2015, RLB, undo 6Nov2015
 	      stationPtr(i),timestampYear,timestampMonth,da,hr,mins,&
 	      sumTantecedent,sumTrecent,intensity,dur,precip,&
 	      runIntensity,AWI,outputFolder,archiveFile,stationLocation(i),&
 	      TavgIntensity,Tantecedent,Trecent,precipUnit,checkS,checkA,stats)
 	   end if
 	  end if
 	   
! Create time series listings of threshold exceedance values
	  if(stats) then	  
 	     call gnpts1(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),ctr_recent_antecedent,timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesExceedFile,stationLocation(i),in2mm,&
 	      rph,pt_recent_antecedent,maxLines,'ExRA_',AWI,minTStormGap,TavgIntensity,&
 	      Tantecedent,Trecent,lowLim,upLim,precipUnit,checkS,checkA)
 	     call gnpts1(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),ctrid,timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesExceedFile,stationLocation(i),in2mm,&
 	      rph,ptid,nlo20,'ExID_',AWI,minTStormGap,TavgIntensity,&
 	      Tantecedent,Trecent,lowLim,upLim,precipUnit,checkS,checkA)
 	     call gnpts1(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),AWIIntensCtr,timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesExceedFile,stationLocation(i),in2mm,&
 	      rph,ptawid,nlo20,'ExIDA',AWI,minTStormGap,TavgIntensity,&
 	      Tantecedent,Trecent,lowLim,upLim,precipUnit,checkS,checkA)
 	     call gnpts1(unitNumber(1),unitNumber(5),maxLines,&
 	      stationNumber(i),ctrira,timestampYear,&
 	      timestampMonth,da,hr,mins,sumTantecedent,sumTrecent,intensity,&
 	      dur,precip,runIntensity,deficit_recent_antecedent,threshIntensityDuration,&
 	      threshAvgExceed,outputFolder,timeSeriesExceedFile,stationLocation(i),in2mm,&
 	      rph,ptira,nlo20,'ExIRA',AWI,minTStormGap,TavgIntensity,&
 	      Tantecedent,Trecent,lowLim,upLim,precipUnit,checkS,checkA)
 	     call tindm(unitNumber(1),unitNumber(5),unitNumber(10),maxLines,&
 	      stationNumber(i),stationPtr(i),timestampYear,timestampMonth,&
 	      da,hr,sumTantecedent,sumTrecent,intensity,dur,&
 	      deficit_recent_antecedent,threshIntensityDuration,outputFolder,timeSeriesExceedFile,&
 	      stationLocation(i),in2mm,'Max',AWI,runIntensity,TavgIntensity,runningIntens,&
 	      Tantecedent,Trecent,precipUnit,checkS,checkA)
	  end if
	end do !}}}

	! use plotFormat to choose output format for plotting 
	if(flagRealtime) then
	   ! plot file for current conditions relative to thresholds
	   if(plotFormat=='gnp1') call gnp1(numStations,outputFolder,&
	      unitNumber(1),defaultOutputFile,unitNumber(6),latestTime,fdat,&
	      stationNumber,sumAntecedent_s,sumRecent_s,intsys,durs,srunIntensity,in2mm,&
	      Tintensity,TavgIntensity,precipUnit) 
	   if(plotFormat=='gnp2') call gnp2(numStations,outputFolder,&
	      unitNumber(1),unitNumber(6),latestTime,fdat,stationNumber,sumAntecedent_s,&
	      sumRecent_s,intsys,durs,srunIntensity,in2mm,Tintensity,TavgIntensity,&
	      Tantecedent,Trecent,precipUnit)
	   if(plotFormat=='dgrs') call dgrs(numStations,outputFolder,&
	      unitNumber(1),dgOutputfile,unitNumber(6),stationNumber,sumAntecedent_s,&
	      sumRecent_s,Trecent,precipUnit)
  
! the next files and formatted text, are created no matter what
! output format is selected for plotting
	   call alert(numStations,outputFolder,unitNumber(1),&
	   unitNumber(8),datim,stationNumber,deficit_recent_antecedent_s,&
	   sthreshIntensityDuration,runningIntens,sthreshAvgIntensity,&
	   srunIntensity,in2mm,durs,TavgIntensity,sAWI,AWIThresh,fieldCap,&
           checkS,checkA)
	   call alerthtm(numStations,outputFolder,unitNumber(1),&
	   unitNumber(8),datimb,stationNumber,deficit_recent_antecedent_s,&
	   sthreshIntensityDuration,sthreshAvgIntensity,runningIntens,&
	   srunIntensity,in2mm,durs,stationLocation,TavgIntensity,sAWI,&
           AWIThresh,fieldCap,checkS,checkA)
	 if(forecast .eqv. .FALSE.) then
 	   call tabl(unitNumber(4),unitNumber(1),outputFolder,&
 	   numStations,stationNumber,datim,durs,sumAntecedent_s,&
 	   sumRecent_s,intsys,Tantecedent,Trecent,precipUnit)
	   call read_colors(hexColors,colors,div,ndiv,unitNumber(1))
 	   call tablhtm(unitNumber(4),unitNumber(1),outputFolder,&
 	   numStations,stationNumber,datimb,durs,sthreshIntensityDuration,&
 	   sumAntecedent_s,sumRecent_s,intsys,srunIntensity,stationLocation,&
 	   Tantecedent,Trecent,hexColors,colors,div,ndiv,precipUnit)
 	 end if
	end if
	
	outputFile=trim(outputFolder)//trim(updateFile)
	open(unitNumber(9),file=outputFile,status='unknown',position='rewind',err=125)
	write(unitNumber(9),'(a18)',advance='no') 'Data last updated:'
	write(unitNumber(9),'(1x,a11,a1,1x,a5,a1)') latestDate,',',latestTime,'.'
	close(unitNumber(9))

! Write "Thlast.txt" file, compare new and old end values and update as needed
	pathThlast=trim(outputFolder)//'Thlast.txt'
	open(unitNumber(7),file=pathThlast,status='unknown',position='rewind',err=130)
	do i=1,numStations
	   if(newest1904(i)>last1904(i)) last1904(i)=newest1904(i)
	   write (unitNumber(7),*) stationNumber(i),cm,last1904(i),cm,&
	   tstormBeg1904(i),cm,tstormEnd1904(i),cm,AWI_0(i),cm,tlenx(i)
	end do
	
	close(unitNumber(7))
	write(unitNumber(1),*) 'Thresh completed normally'
	write(*,*) 'Thresh completed normally'
     	call date_and_time(sysDate,sysTime)
      	write (unitNumber(1),*) sysTime(1:2),':',sysTime(3:4),':',&
	&sysTime(5:6),' ',sysDate(5:6),'/',sysDate(7:8),&
	&'/',sysDate(1:4),' ',pd
	close (unitNumber(1))
	stop
	
! Error handling for read statements
        125 write(unitNumber(1),*) 'Error opening file ',trim(outputFile)	
            write(unitNumber(1),*) 'Program exited due to this error.'	
  	    close (unitNumber(1))
  	    if(stats)then
               write(*,*) 'Error opening file ',trim(outputFile)
  	       write(*,*) 'Press Enter key to exit program.'
  	       read(*,*)
  	    end if
	    stop
        130 write(unitNumber(1),*) 'Error opening file ',trim(pathThlast)
            write(unitNumber(1),*) 'Program exited due to this error.'	
  	    close (unitNumber(1))
  	    if(stats)then
               write(*,*) 'Error opening file ',trim(pathThlast)
   	       write(*,*) 'Press Enter key to exit program.'
  	       read(*,*)
  	    end if
	    stop

	end program thresh
