! PURPOSE:
!	  Writes the title and purpose of program thresh to the screen

	subroutine titl(sysTime,sysDate,vrsn,revdate)
	implicit none
	
! FORMAL ARGUMENTS
	character, intent(in):: sysTime*(*),sysDate*(*),vrsn*(*),revdate*(*)

!------------------------------	
	
	write(*,*) '**************** Thresh ****************'
	write(*,*) '    Version, ',vrsn,', ',revdate
	write(*,*) '   Program to compute precipitation'
	write(*,*) '     amounts, intensity & duration'
	write(*,*) ' For comparison with rainfall thresholds'
	write(*,*) '  By Rex L. Baum, and Jacob Vigil, USGS'
	write(*,*) '          Compiled using gfortran'
! 	write (*,*) time,' ',date
      	write (*,*) sysDate(5:6),'/',sysDate(7:8),'/',sysDate(1:4),&
	&' ',sysTime(1:2),':',sysTime(3:4),':',sysTime(5:6)
	      write(*,*)
	return
	end subroutine titl