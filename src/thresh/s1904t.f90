! PURPOSE: 
!  	  converts time and date data to serial numbers used in 1904 
!	  date system to aid in determining chronology of dates and times 		
!

	subroutine s1904t(date,year,month,day,hour,minute,count,numLines)
	implicit none
	integer,parameter:: double=kind(1d0)
	
! FORMAL ARGUMENTS
	real (double), intent(out) :: date(numLines)
	integer, intent(in)	   :: count,numLines
	integer, intent(in)	   :: year(numLines),month(numLines),day(numLines)
	integer, intent(in)	   :: hour(numLines),minute(numLines)

! LOCAL VARIABLES
	real (double) :: time
	integer       :: r,m,i,n,p,nmod,pmod,days(12),juld
	logical       :: leapYear
	
!------------------------------	
			
!  construct array "days", julian day of tdate1904last day of each month 
	days=(/0,31,59,90,120,151,181,212,243,273,304,334/)
	date = 0.
	
!   check for leapYear year 
	do i=1,count
	if (year(i) == 0) then
	   write(*,*) "Year = 0. Check data files for empty lines."
	   stop
	else if (month(i) == 0) then
	   write(*,*) "Month = 0. Check data files for empty lines."
	   stop
	else if (day(i) == 0) then
	   write(*,*) "Day = 0. Check data files for empty lines."
	   stop
	end if 
	  leapYear = (mod(year(i),4)==0 .and. mod(year(i),100) /= 0) &
		.or. mod(year(i),400) == 0

	  juld=days(month(i))+day(i)
	  if (leapYear .and. month(i)>2) juld=juld+1

	  
	  time=(hour(i)/24.)+(minute(i)/1440.) 
	  r=mod((year(i)-1904),4)
	  m=int((year(i)-1904)/4)
	  n=int((year(i)-1900)/100)
	  nmod=mod((year(i)-1900),100)
	  p=int((year(i)-1600)/400)
	  pmod=mod((year(i)-1600),400)
	  date(i)=m * 366. + (3 * m + r) * 365. + juld - n + p + time
	  if (r==0 .and. nmod/=0 .or. pmod==0) date(i)=date(i)-1.
  	end do
	return
	end subroutine s1904t


