! PURPOSE:
!	  Writes the ThAlert.htm file. The data is composed in a table and
!	  color-coded to indicate alert levels.

	subroutine alerthtm(numStations,outputFolder,ulog,unitNumber,&
 	 datimb,stationNumber,deficit,intensity,avgIntensity,runningIntens,&
 	 antecedRainfall,in2mm,duration,stationLocation,TavgIntensity)
 	 
! FORMAL ARGUMENTS
	character, intent(in) 	       :: outputFolder*(*)
	character(*), intent(in)       :: stationNumber(numStations)
	character (len=50), intent(in) :: stationLocation(numStations)
	character (len=20), intent(in) :: datimb(numStations)
	real, intent(in) 	       :: antecedRainfall(numStations)
	real, intent(in) 	       :: duration(numStations),in2mm
	real, intent(in) 	       :: deficit(numStations),runningIntens
	real, intent(in)	       :: intensity(numStations),avgIntensity(numStations)
	integer, intent(in) 	       :: numStations,unitNumber,ulog,TavgIntensity
	
! LOCAL VARIABLES
	character (len=22)	     :: hexColor(4)
	character (len=7) 	     :: color(4)
	character 		     :: tb = char(9)
	character (len=255) 	     :: outputFile='ThAlert.htm'
	character (len=17),parameter :: r1='<tr align=center>'
	character (len=4),parameter  :: h1='<th>',d1='<td>'
	character (len=5),parameter  :: r2='</tr>',h2='</th>',d2='</td>'
	real			     :: avgToRunning
	integer 		     :: i,alertCondition3d15d(numStations)
	integer 		     :: alertConditionID(numStations)
	integer 		     :: alertConditionIA(numStations)
	
!------------------------------	
! alert levels 0="not applicable", 1="green", 2="yellow", 3="red"	
	color=(/'--N/A--',' Green ','Yellow ','  Red  '/)
	hexColor=(/'<td bgcolor=#cccccc>','<td bgcolor=#33ff33>',&
	&'<td bgcolor=#ffff33>','<td bgcolor=#ff0000>'/)
	

! determine alert condition for 3-day/15-day threshold
	do i=1,numStations	
	  alertCondition3d15d(i)=1
	  if(deficit(i) >-0.5 .and. deficit(i) <0.d0) then
	    alertCondition3d15d(i)=2
	  else if (deficit(i) >=0.) then
	    alertCondition3d15d(i)=3
	  end if
	end do
	
! determine alert condition for Intensity-Duration Threshold
	do i = 1, numStations	
	  alertConditionID(i)=0
	  if(duration(i)>0) then  ! threshold applicable only if duration>0
	    alertConditionID(i)=1
	    if(intensity(i) >0.9 .and. intensity(i) <1.0) then
	      alertConditionID(i)=2
	    else if(intensity(i) >=1.0) then
	      alertConditionID(i)=3
	    end if
	  end if
	end do
	
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
	
! file in html-table format listing most recent alert conditions at all stations
  	outputFile=trim(outputFolder)//trim(outputFile)
  	open(unitNumber,file=outputFile,status='unknown',&
     	position='rewind',err=125)
     	write (unitNumber,*) '<center><table border=1 width=90%>'
	write (unitNumber,*) '<caption>',&
	' Current Alert Levels by Station and Threshold ',&
	'</caption>'
	write (unitNumber,*) r1,h1,'Rain gauge',h2,h1,'Vicinity',h2,h1,&
        'Time & Date',h2,h1,'Recent/Antecedent',h2,h1,'Intensity-Duration',&
        h2,h1,TavgIntensity,'-hr Running Average Intensity',h2,r2
	do i=1,numStations
	  write(unitNumber,*) &
          r1,d1,trim(stationNumber(i)),d2,d1,trim(stationLocation(i)),d2,&
          d1,datimb(i),d2,hexColor(1+alertCondition3d15d(i)),&
          color(1+alertCondition3d15d(i)),d2,&
          hexColor(1+alertConditionID(i)),color(1+alertConditionID(i)),&
          d2,hexColor(1+alertConditionIA(i)),color(1+alertConditionIA(i)),d2,r2
	end do
	write (unitNumber,*) '</table></center>'
  	close(unitNumber)
	write(*,*) 'Finished alert status HTML page'
	return
	
! DISPLAYS ERROR MESSAGE
  125	write(*,*) 'Error opening file ',outputFile	
  	write(*,*) 'Press Enter key to exit program.'
  	read(*,*)
  	write(ulog,*) 'Error opening file ',outputFile		
  	close (ulog)
	stop
	end subroutine alerthtm
