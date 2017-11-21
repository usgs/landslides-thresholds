! PURPOSE:
!	  writes rainfall threshold parameters to individual time-series plot file per station
!
!

	subroutine gnpts(ulog,uout,n,stationNumber,ctrHolder,&
	stationPtr,year,month,day,hour,minute,sumTantecedent,&
	sumTrecent,intensity,duration,precip,runningIntens,AWI,deficit,&
	intensityDuration,avgIntensity,outputFolder,timeSeriesPlotFile,&
	stationLocation,in2mm,rph,TavgIntensity,Tantecedent,Trecent,precipUnit,&
        checkS,checkA,stats)
	implicit none
	
! FORMAL ARGUMENTS
	character, intent(in) :: outputFolder*(*),timeSeriesPlotFile*(*),stationNumber*(*)
	character, intent(in) :: stationLocation*(*)
	character, intent(in) :: precipUnit*(*)
	real, intent(in)      :: sumTantecedent(n),sumTrecent(n),intensity(n),in2mm
	real, intent(in)      :: duration(n),runningIntens(n),AWI(n)
	real, intent(in)      :: deficit(n),intensityDuration(n),avgIntensity(n)
	real, intent(in)      :: TavgIntensity
	integer, intent(in)   :: n,year(n)
	integer, intent(in)   :: month(n),day(n),hour(n),minute(n),precip(n)
	integer, intent(in)   :: uout,ulog,ctrHolder,stationPtr
	integer, intent(in)   :: rph,Tantecedent,Trecent
        logical, intent(in)   :: checkS,checkA,stats
	
! LOCAL VARIABLES
	character (len=255) :: outputFile
	character (len=11)  :: mhour
	character (len=10)  :: date,msumTantecedent,msumTrecent,mintensity
	character (len=10)  :: mduration,mrunningIntens,mprecip,mdeficit
	character (len=10)  :: mavgIntensity,mintensityDuration,mAWI
	character (len=10)  :: logRunIntensity,logStormIntensity 
	character (len=8)   :: TavgIntensityF 
	character (len=5)   :: time 
	character (len=3)   :: AntecedentHeader
	character           :: pd = char(35),tb = char(9)
	real                :: floatPrecip 
	integer             :: j
	
!------------------------------	

! Set text for heading of Antecedent precipitation column
  	if(checkS) then
  	   AntecedentHeader='SAP' !Seasonal Antecedent Precipitation
        else if (checkA) then
           AntecedentHeader='AWI' !Antecedent Wetness Index
        else
           AntecedentHeader='CAP' !Cumulative Annual Precipitation
        end if

   write(TavgIntensityF,'(F8.3)') TavgIntensity
   TavgIntensityF=adjustl(TavgIntensityF)
   
   ! Writing data values to variables for use in constructing outputFile
   write(mhour,'(i7,a4)') ctrHolder,'hour'
  	
  	! Constructing outputFile
   outputFile=trim(stationNumber)//'.txt'
  	outputFile=trim(outputFolder)//trim(timeSeriesPlotFile)//trim(adjustl(mhour))//outputFile
  	
	open(uout,file=outputFile,status='unknown',position='rewind',err=125)
	
   ! Write heading if writing a new file (position=rewind); skip if appending to an old one.     
	write(uout,*) pd,' Time-Series Plot File for Rainfall Thresholds'
	write(uout,*) pd,' Station ',trim(stationNumber),': ', trim(stationLocation),&
          &' Precipitation units: ', precipUnit
	write(uout,*) pd,' Time and date',tb,&
	              'Hourly precip.',tb,&
	              Tantecedent,'-h precip.',tb,&
	              Trecent,'-h precip.',tb,&
	              'Intensity',tb,&
	              'Log10(Intensity)',tb,&
	              'Duration',tb,&
	              'Log10('//trim(TavgIntensityF)//'-h intensity)',tb,&
	              trim(TavgIntensityF)//'-h intensity',tb,&
	              'RA Index',tb,&
	              'ID Index',tb,&
	              trim(TavgIntensityF),'-h intensity index',tb,&
	              AntecedentHeader
	  
	do j=(1+stationPtr-ctrHolder*rph),stationPtr
	   write(time,'(i2.2,a1,i2.2)') hour(j),':',minute(j)
	   write(date,'(i2.2,a1,i2.2,a1,i4)')month(j),'/',day(j),'/',year(j)
	   
		if (precipUnit == 'mm') then
			floatPrecip = float(precip(j))/10.
		else if (precipUnit == 'in') then
			floatPrecip = float(precip(j))/100.
		end if
	  
!  Write data to text strings and trim blank spaces to reduce file size      
	   write(mprecip,             '(f10.2)')     floatPrecip
	   write(msumTantecedent,     '(f10.2)')     sumTantecedent(j)
	   write(msumTrecent,         '(f10.2)')     sumTrecent(j)
	   write(mintensity,          '(f10.3)')     intensity(j)
	   if(intensity(j)<=0.) then
	      write(logStormIntensity,   '(f10.3)')     -99.
	   else 
	      write(logStormIntensity,   '(f10.3)')     log10(intensity(j))
	   end if	   
	   write(mduration,           '(f10.2)')     duration(j)
	   if(runningIntens(j)<=0) then
	      write(mrunningIntens,   '(f10.3)')     runningIntens(j)
	      write(logRunIntensity,  '(f10.3)')     -99.
	   else
	      write(mrunningIntens,   '(f10.3)')     runningIntens(j) 
	      write(logRunIntensity,  '(f10.3)')     log10(runningIntens(j))
	   end if
	   write(mdeficit,            '(f10.3)')     deficit(j)
	   write(mintensityDuration,  '(f10.3)')     intensityDuration(j)
	   write(mavgIntensity,       '(f10.3)')     avgIntensity(j)
	   write(mAWI,                '(f10.3)')     AWI(j)
	  
	   msumTantecedent      = trim(adjustl(msumTantecedent))
	   msumTrecent          = trim(adjustl(msumTrecent))
	   mintensity           = trim(adjustl(mintensity))
	   logRunIntensity      = trim(adjustl(logRunIntensity))
	   logStormIntensity    = trim(adjustl(logStormIntensity))
	   mduration            = trim(adjustl(mduration))
	   mrunningIntens       = trim(adjustl(mrunningIntens))
	   mprecip              = trim(adjustl(mprecip))
	   mdeficit             = trim(adjustl(mdeficit))
	   mavgIntensity        = trim(adjustl(mavgIntensity))
	   mintensityDuration   = trim(adjustl(mintensityDuration))
	   mAWI                 = trim(adjustl(mAWI))
	  
	   write(uout,*)time,' ',date,tb,&
                   mprecip,tb,&
                   msumTantecedent,tb,&
                   msumTrecent,tb,&
                   mintensity,tb,&
                   logStormIntensity,tb,&
                   mduration,tb,&
                   logRunIntensity,tb,&
                   mrunningIntens,tb,tb,&
                   mdeficit,tb,&
                   mintensityDuration,tb,&
                   mavgIntensity,tb,&
                   mAWI
   end do
     	
	close(uout)
	write(*,*) ctrHolder,'-hour',' time-series plot files finished'
	return
	
! DISPLAYS ERROR MESSAGE
  125	 write(ulog,*) 'Error opening file ',trim(outputFile)
  	 write(ulog,*) 'Program exited due to this error.'
  	 close (ulog)
  	 if(stats)then
            write(*,*) 'Error opening file ',trim(outputFile)
  	    write(*,*) 'Press Enter key to exit program.'
  	    read(*,*) 
  	 end if
        stop
	end subroutine gnpts
