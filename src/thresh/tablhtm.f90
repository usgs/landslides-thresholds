module tablhtm_colors
implicit none

contains
! PURPOSE:
!	  tablhtm creates a ThCurrTabl.htm file that organizes the data analyzed
!	  in the thresh.exe program
!
	subroutine tablhtm(unitNumber,u1,outputFolder,numStations,&
	stationNumber,dateTime,duration,intensityDurationIndex,sumAnteced,&
	sumRecent,intensity,runningIntens,stationLocation,Tantecedent,Trecent,&
        hexColors,colors,div,ndiv)
	implicit none
		
! FORMAL ARGUMENTS
	character (len=50), intent(in) :: stationLocation(numStations)
	character (len=20), intent(in) :: dateTime(numStations)
	character (len=22), allocatable, intent(in) :: hexColors(:)
	character (len=6), allocatable, intent(in) :: colors(:)
	real, allocatable, intent(in)  :: div(:)
	character(*), intent(in)       :: stationNumber(numStations)
	character, intent(in)	       :: outputFolder*(*)
	real, intent(in)	       :: duration(numStations),sumAnteced(numStations)
	real, intent(in)	       :: sumRecent(numStations),intensityDurationIndex(numStations)
	real, intent(in)	       :: intensity(numStations),runningIntens(numStations)
	integer, intent(in)	       :: numStations,unitNumber,u1,ndiv
	integer, intent(in)	       :: Tantecedent,Trecent
	
! LOCAL VARIABLES
	character (len=255) :: outputFile = 'ThCurrTabl.htm'
	character (len=17)  :: r1='<tr align=center>'
	character (len=7)   :: recent,anteced,mintensity,mduration
	character (len=4)   ::  h1='<th>',d1='<td>'
	character (len=5)   ::  r2='</tr>',h2='</th>',d2='</td>'
	real 		    :: test
	integer 	    :: i,j,clr
	
!------------------------------	

! colors white=#ffffff gray=#cccccc violet=#6600cc
! blue=#0000ff light blue=#33ffff green=#00ff00
! yellow=#ffff00 orange=#ff6600 red=#ff0000 magenta=#ff00ff 

! Create output file	
  	outputFile=trim(outputFolder)//outputFile
  	
! Open file
  	open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)

!Writing HTML headers and column names
     	write (unitNumber,*) '<center><table border=1 width=90%>'
	write (unitNumber,*) '<caption>Current Conditions by Station</caption>'
	write(unitNumber,*) r1,h1,'Rain Gauge',h2,h1,&
	  'Vicinity of <br>Rain Gauge',h2,h1,&
          Tantecedent,'-hr Antecedent Total<br>(inches)',h2,h1,&
          Trecent,'-hr RecentTotal<br>(inches)',h2,h1,&
          'Average<br>Intensity<br>(inches/hour)',h2,&
          h1,'Duration of<br>Current Storm<br>(hours)',h2,h1,'Time & Date',h2,r2

! Assign proper values to each variable. Used to fill the table.
	do i=1,numStations
	  if (trim(stationNumber(i))=='0') cycle
	  
	    test=sumAnteced(i)
	    if (test<0) then
	     write(anteced,'(a)') '---'
	    else
	     write(anteced,'(f7.2)') sumAnteced(i)
	    end if  
	    
	    test=sumRecent(i)
	    if (test<0) then
	      write(recent,'(a)') '---'
	    else
	      write(recent,'(f7.2)') sumRecent(i)
	    end if  
	    
	    test=intensityDurationIndex(i)
	    clr=1
	    if (test<0) then
	      write(mintensity,'(a)') '---'
	    else ! Assign background colors to intensity based on intensity-duration index.
	      write(mintensity,'(f7.3)') intensity(i)
	      	do j=1,ndiv-1
				if(test>div(j) .and. test<=div(j+1)) then
					clr=j+1
				else if(test<=div(1)) then
					clr=1
				else if(test>div(ndiv)) then
					clr=ndiv+1
				end if
			end do
	    end if  
	    
	    test=duration(i)
	    if (test<0) then
	      write(mduration,'(a)') '---'
	    else
	      write(mduration,'(f7.1)') duration(i)
	    end if
	    
! Filling each row with the data collected from the above loops
	   write(unitNumber,*)r1,d1,trim(stationNumber(i)),d2,d1,&
	   trim(stationLocation(i)),d2,d1,anteced,d2,d1,recent,&
	   d2,hexColors(clr),mintensity,d2,d1,mduration,d2,d1,dateTime(i),d2,r2 
	end do
	
! Closing HTML tags to finish the table
	write (unitNumber,*) '</table></center>'
  	close(unitNumber)	
	write(*,*) 'Finished current condtions HTML table'
	return
	
! DISPLAYS ERROR MESSAGE
  125	write(*,*) 'Error opening file ',outputFile	
  	write(*,*) 'Press Enter key to exit program.'
  	read(*,*)
  	write(u1,*) 'Error opening file ',outputFile		
  	close (u1)
	stop
	end subroutine tablhtm

! PURPOSE:
!	  Provides the user with an option to choose colors for tablhtm
!	  
!
subroutine read_colors(hexColors,colors,div,ndiv)
implicit none

!FORMAL ARGUMENTS
character (len=22), allocatable, intent(out)  :: hexColors(:)
character (len=6), allocatable, intent(out) :: colors(:)	
real, allocatable, intent(out) :: div(:)
integer, intent(out) :: ndiv

! LOCAL VARIABLES
character(len=10), parameter :: FILENAME="Colors.txt"
integer :: unit=667,i,colorcounter,divcounter
!------------------------------	

! Open file
      open(unit,file=FILENAME,err=100,status="old")

read(unit,*) ndiv

allocate(colors(ndiv+1),div(ndiv),hexColors(ndiv+1))      

colorcounter = 0
divcounter = 0
      
do i=1,ndiv+1
    read(unit,*) colors(i)
    hexColors(i) = '<td bgcolor=#'//colors(i)//'>'
    colorcounter = colorcounter + 1
end do

if (colorcounter /= ndiv+1) then
	write(*,*) "The file ", FILENAME, " has the incorrect number of colors."
	write(*,*) "The number of colors should be equal to the number of divisions"
	write(*,*) "plus one. Press Enter key to exit program."
	read(*,*)
	stop
end if

do i=1,ndiv
	read(unit,*) div(i)
	divcounter = divcounter + 1
end do

if (divcounter /= ndiv) then
	write(*,*) "The file ", FILENAME, " has the incorrect number of divisions."
	write(*,*) "The number of divisions should be equal to the number entered"
	write(*,*) "At the beginning of Colors.txt."
	write(*,*) "Press Enter key to exit program."
	read(*,*)
	stop
end if
	
close(unit)
return

!DISPLAYS ERROR MESSAGE
100 write(*,*)"The file ", FILENAME, " could not be opened."
    write(*,*)"Ensure that the file exists in the same directory as"
    write(*,*)"Thresh."
    write(*,*)'Press Enter key to exit program.'
    read(*,*)
    stop
end subroutine read_colors
end module

