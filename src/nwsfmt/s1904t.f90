	subroutine s1904t(dtim,yr,mo,da,hr,mnt,kount,nline)
!  converts time and date data to serial numbers used in 1904 
!  date system to aid in determining chronology of dates and times 
	implicit none
	integer,parameter:: double=kind(1d0)
	integer ::r,m,i,n,p,nmod,pmod,das(12),juld
	integer, intent(in):: kount,nline
	integer, intent(in)::yr(nline),mo(nline),da(nline)
	integer, intent(in)::hr(nline),mnt(nline)
	logical ::leap
	real (double), intent(out)::dtim(nline)
	real (double) ::time
!  construct array "das", number of days in month previous 
! 	das=(/0,31,28,31,30,31,30,31,31,30,31,30/)
!  construct array "das", julian day of last day of each month 
	das=(/0,31,59,90,120,151,181,212,243,273,304,334/)
	dtim=0.
!   check for leap year 
	do i=1,kount
	  leap=.false.
	  if (mod(yr(i),4)==0 .and. mod(yr(i),100) /= 0 &
     	  &.or. mod(yr(i),400) == 0) leap=.true.
	  juld=das(mo(i))+da(i)
	  if (leap .and. mo(i)>2) juld=juld+1
! 	  sec=0
	  time=(hr(i)/24.)+(mnt(i)/1440.) ! +(sec/86400.)
	  r=mod((yr(i)-1904),4)
	  m=int((yr(i)-1904)/4)
	  n=int((yr(i)-1900)/100)
	  nmod=mod((yr(i)-1900),100)
	  p=int((yr(i)-1600)/400)
	  pmod=mod((yr(i)-1600),400)
	  dtim(i)=m*366.+(3*m+r)*365.+juld-n+p+time
	  if (r==0 .and. nmod/=0 .or. pmod==0) dtim(i)=dtim(i)-1.
  	end do
! 	write(*,*) dtim(kount)
	return
	end subroutine s1904t


