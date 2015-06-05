! PURPOSE:
!	  tablhtm creates a ThCurrTabl.htm file that organizes the data analyzed
!	  in the thresh.exe program
!
	subroutine tablhtm(unitNumber,u1,outputFolder,numStations,&
	stationNumber,dateTime,duration,sumAnteced,sumRecent,intensity,runningIntens,&
	stationLocation,Tantecedent,Trecent)
	implicit none
	integer, parameter :: ndiv=6 ! number of colors for rf intensity cell background
	
! FORMAL ARGUMENTS
	character (len=50), intent(in) :: stationLocation(numStations)
	character (len=20), intent(in) :: dateTime(numStations)
	character(*), intent(in)       :: stationNumber(numStations)
	character, intent(in)	       :: outputFolder*(*)
	real, intent(in)	       :: duration(numStations),sumAnteced(numStations)
	real, intent(in)	       :: sumRecent(numStations)
	real, intent(in)	       :: intensity(numStations),runningIntens(numStations)
	integer, intent(in)	       :: numStations,unitNumber,u1
	integer, intent(in)	       :: Tantecedent,Trecent
	
! LOCAL VARIABLES
	character (len=255) :: outputFile = 'ThCurrTabl.htm'
	character (len=22)  :: hexColors(10)
	character (len=17)  :: r1='<tr align=center>'
	character (len=7)   :: recent,anteced,mintensity,mduration
	character (len=4)   ::  h1='<th>',d1='<td>'
	character (len=5)   ::  r2='</tr>',h2='</th>',d2='</td>'
	real 		    :: test, div(ndiv)
	integer 	    :: i,clr
	
!------------------------------	
	
! colors white=#ffffff gray=#cccccc violet=#6600cc
! blue=#0000ff light blue=#33ffff green=#00ff00
! yellow=#ffff00 orange=#ff6600 red=#ff0000 magenta=#ff00ff 
	
! if this subroutine works, then generalize by declaring the
! div() and hexColors() arrays in the main program, reading color values, etc.
! from a file so that the user can customize the color scheme.

! instead, consider having a colorfmt.txt file that the user can edit
! that is read in its own subroutine? to minimize confusion in main program

	div=(/0.,0.05,0.1,0.15,0.2,0.25/)
	hexColors=(/'<td bgcolor=#ffffff>','<td bgcolor=#cccccc>',&
	'<td bgcolor=#6600cc>','<td bgcolor=#0000ff>','<td bgcolor=#33ffff>',&
	'<td bgcolor=#00ff00>','<td bgcolor=#ffff00>','<td bgcolor=#ff6600>',&
	'<td bgcolor=#ff0000>','<td bgcolor=#ff00ff>'/)

! Create output file	
  	outputFile=trim(outputFolder)//outputFile
  	
! Open file
  	open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)

!Writing HTML headers and column names
     	write (unitNumber,*) '<center><table border=1 width=90%>'
	write (unitNumber,*) '<caption>Current Conditions by Station</caption>'
	write(unitNumber,*) r1,h1,'Rain Gauge',h2,h1,&
	  'Vicinity of <br>rain gauge',h2,h1,&
          Tantecedent,'-hr Antecedent Total<br>(inches)',h2,h1,&
          Trecent,'-hr RecentTotal<br>(inches)',h2,h1,&
          'Average<br>Intensity<br>(inches/hour)',h2,&
          h1,'Duration of<br>current storm<br>(hours)',h2,h1,'Time & Date',h2,r2

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
	    
	    test=intensity(i)
	    clr=1
	    if (test<0) then
	      write(mintensity,'(a)') '---'
	    else
	      write(mintensity,'(f7.3)') intensity(i)
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
	
! DISPLAYS ERROR MESSAGE (Currently not working)
  125	write(*,*) 'Error opening file ',outputFile	
  	write(*,*) 'Press Enter key to exit program.'
  	read(*,*)
  	write(u1,*) 'Error opening file ',outputFile		
  	close (u1)
	stop
	end subroutine tablhtm
