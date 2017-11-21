! PURPOSE:
!	 Writes the ThAlert.txt file. The data is composed in a table and
!	colors are used to indicate alert levels.
!
!
	subroutine alert(numStations,outputFolder,ulog,unitNumber,datim,&
	 stationNumber,deficit,intensity,runningIntens,avgIntensity,&
	 antecedPrecip,in2mm,duration,TavgIntensity,sAWI,AWIThresh,&
         fieldCap,checkS,checkA)
	implicit none
	
! FORMAL ARGUMENTS
	character, intent(in) 	       :: outputFolder*(*)
	character(*), intent(in)       :: stationNumber(numStations)
	character (len=17), intent(in) :: datim(numStations)
	real, intent(in) 	       :: antecedPrecip(numStations),duration(numStations),in2mm
	real, intent(in) 	       :: deficit(numStations),runningIntens
	real, intent(in) 	       :: intensity(numStations)
	real, intent(in) 	       :: avgIntensity(numStations),sAWI(numStations)
	real, intent(in)               :: AWIThresh,fieldCap,TavgIntensity
	integer, intent(in) 	    :: numStations,unitNumber,ulog
        logical, intent(in)         :: checkS,checkA	
	
! LOCAL VARIABLES
	character (len=255) :: outputFile='ThAlert.txt'
	character (len=7)   :: alert_lev(4)
	character (len=8)   :: TavgIntensityF 
	character 	    :: tb = char(9)
	real		    :: avgToRunning,AWI_low
	integer 	    :: i,alertConditionRecentAntecedent(numStations)
	integer 	    :: alertConditionID(numStations)
	integer 	    :: alertConditionIA(numStations)

!------------------------------	
! alert levels 0="Null", 1="Outlook", 2="Watch", 3="Warning"	
       alert_lev=(/' Null  ','Outlook',' Watch ','Warning'/)
	
! determine alert condition for Cumulative Recent & Antecedent threshold
	do i=1,numStations	
	  alertConditionRecentAntecedent(i)=0
	  if(deficit(i) > -0.5 .and. deficit(i) < 0.d0) then
	    alertConditionRecentAntecedent(i)=0
	  else if (deficit(i) >=0.) then
	    alertConditionRecentAntecedent(i)=1
	  end if
	end do
	
        if(checkA .and. .not. checkS) then
! determine alert condition for Intensity-Duration Threshold & AWI
           AWI_low=-(AWIThresh+fieldCap)/2.
           do i = 1, numStations
        	     alertConditionID(i)=0
        	     if(duration(i)>0 .and. deficit(i) >=0.) then  ! threshold applicable only if duration>0
        	       alertConditionID(i)=1
        	       if(intensity(i) >1.0 .and. sAWI(i) > AWI_low) then
        	          alertConditionID(i)=2
        	       else if(intensity(i) >=1.0 .and. sAWI(i) > AWIThresh) then
        	         alertConditionID(i)=3
        	       end if
        	     end if
        	   end do
	else	
! determine alert condition for Intensity-Duration Threshold alone
	   do i = 1, numStations
	     alertConditionID(i)=0
	     if(duration(i)>0 .and. deficit(i) >=0.) then  ! threshold applicable only if duration>0
	       alertConditionID(i)=1
	       if(intensity(i) > 0.9 .and. intensity(i) < 1.0 ) then
	         alertConditionID(i)=2
	       else if(intensity(i) >= 1.0) then
	         alertConditionID(i)=3
	       end if
	     end if
	   end do
	end if
		
! determine alert condition for Intensity-Antecedent Precipitation Threshold
	do i = 1, numStations
	  alertConditionIA(i)=0
	  if(deficit(i) > 0) then ! antecedent, in millimeters
	      alertConditionIA(i)=1
	      avgToRunning = avgIntensity(i) / runningIntens
	    if(avgToRunning >0.9 .and. avgToRunning < 1.0) then
	      alertConditionIA(i)=2
	    else if(avgToRunning >= 1.0) then
	      alertConditionIA(i)=3
	    end if
	  end if
	end do
	
! tab-delimited file listing most recent alert conditions at all stations
        write(TavgIntensityF,'(F8.3)') TavgIntensity
        TavgIntensityF=adjustl(TavgIntensityF)
  	outputFile=trim(outputFolder)//trim(outputFile)
  	open(unitNumber,file=outputFile,status='unknown',&
  	position='rewind',err=125)
	write (unitNumber,*) ' Current Alert Levels by Station and Threshold'
	write (unitNumber,*) tb,'Rain gage',&
	                     tb,'Time and date',&
	                     tb,'Recent-antecedent',&
	                     tb,'Intensity-duration',&
	                     tb,trim(TavgIntensityF),'-h running average intensity'
	                     
	do i=1,numStations
	  write(unitNumber,*) tb,trim(stationNumber(i)),&
	                      tb,datim(i),&
	                      tb,alert_lev(1+alertConditionRecentAntecedent(i)),&
	                      tb,alert_lev(1+alertConditionID(i)),&
	                      tb,alert_lev(1+alertConditionIA(i))
	end do
	
  	close(unitNumber)
	write(*,*) 'Finished alert status text file'
	return
	
! WRITES ERROR MESSAGE TO LOG FILE
   125       write(ulog,*) 'Error opening file ',trim(outputFile	)
  	     close (ulog)
	     stop
	end subroutine alert
