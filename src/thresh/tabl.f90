! PURPOSE:
!	tabl creates a ThCurrTabl.txt file that organizes the data analyzed
!	in the program
!
!
	subroutine tabl(unitNumber,u1,outputFolder,numStations,&
	stationNumber,dateTime,duration,sumAnteced,sumRecent,intensity,&
	Tantecedent,Trecent,precipUnit)
	implicit none
	
! FORMAL ARGUMENTS
	character, intent(in)	       :: outputFolder*(*),precipUnit*(*)
	character (len=17), intent(in) :: dateTime(numStations)
	character(*), intent(in)       :: stationNumber(numStations)
	real, intent(in)	       :: duration(numStations),sumAnteced(numStations)
	real, intent(in)	       :: sumRecent(numStations)
	real, intent(in)	       :: intensity(numStations)
	integer, intent(in)	       :: numStations,unitNumber
	integer, intent(in)	       :: u1,Tantecedent,Trecent
	
! LOCAL VARIABLES
	character (len=255) :: outputFile = 'ThCurrTabl.txt'
	character (len=7)   :: recent,antecedent,mintensity
	real		    :: test
	integer		    :: i
	
!------------------------------	
	
! Create output file
  	outputFile=trim(outputFolder)//outputFile
  	open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
  	
! Write to file
	write (unitNumber,*) 'Current Conditions by Station'
	write(unitNumber,*) 'Precipitation units: ',precipUnit
	write(unitNumber,'(a10,12x,i3,a14,12x,i2,a10,12x,a9,12x,a8,12x,a11)')&
          'Rain Gage',Tantecedent,'-h Antecedent',Trecent,'-h Recent',&
          'Intensity','Duration','Time and Date'
          
	do i=1,numStations
	  if (trim(stationNumber(i))=='0') cycle
	    test=sumAnteced(i)
	    if (test<0) then
	     write(antecedent,'(a)') '  ---  '
	    else
	     write(antecedent,'(f7.2)') sumAnteced(i)
	    end if  
	    test=sumRecent(i)
	    if (test<0) then
	      write(recent,'(a)') '  ---  '
	    else
	      write(recent,'(f7.2)') sumRecent(i)
	    end if  
	    test=intensity(i)
	    if (test<0) then
	      write(mintensity,'(a)') '  ---  '
	    else
	      write(mintensity,'(f7.3)') intensity(i)
	  end if
	  
	   write(unitNumber,&
     	     '(a8,10x,a7,15x,a7,13x,a7,13x,f7.1,15x,a17)') &
     	     trim(stationNumber(i)),antecedent,recent,mintensity,duration(i),dateTime(i)
	  end do
  	close(unitNumber)	
	write(*,*) 'Finished current condtions text table'
	return
	
! DISPLAY ERROR MESSAGE
  125	write(*,*) 'Error opening file ',trim(outputFile)	
  	write(*,*) 'Press Enter key to exit program.'
  	read(*,*)
  	write(u1,*) 'Error opening file ',trim(outputFile)		
  	close (u1)
	stop
	end subroutine tabl
