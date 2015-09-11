!Subroutine for adjusting dates according to leap year
    subroutine ihr24(month,day,year,hour)
       implicit none
       
! FORMAL ARGUMENTS
       integer, intent(inout) :: month,day,year,hour
       
! LOCAL VARIABLES
       integer :: lastDayOfMonth(12)
       logical :: leapYear
      
!------------------------------	
       lastDayOfMonth = (/31,28,31,30,31,30,31,31,30,31,30,31/)
       leapYear = (mod(year,4) == 0 .and. mod(year,100) /= 0) &
       		  .or. mod(year,400) == 0
       		  
       !check for leap year and adjust number of days in February
       if(leapYear) lastDayOfMonth(2) = 29
       
       !Convert 00:00:00 at midnight to 24:00:00 of previous day
       hour = 24
       if(day > 1) then
       	  day = day - 1
       else
       	  if(month > 1) then
       	     month = month - 1
       	     day = lastDayOfMonth(month)
       	  else
       	     year = year - 1
       	     month = 12
       	     day = lastDayOfMonth(month)
       	  end if
       end if
       return
    end subroutine ihr24
