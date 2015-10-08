! Program to reformat data from National Weather Service Web
! page for use by program Thresh
! Rex L. Baum, USGS, 2/3/06
	program nwsfmt
	implicit none
	integer, parameter:: double=kind(1d0)
	real, allocatable:: ppt(:)
	real (double), allocatable::dtim(:),dltim(:),dltimnu(:)
	real (double):: dltm,dtimax,dif,dhr
    integer:: mo,day,yr,i,lcnt,lines,momi1,yrmi1,nsta,nd
	integer:: j,k,snx,tyear,tmon,tda,thr,tmn,hrcnt,rph
	integer:: u(6),lasday(12)
	integer, allocatable::da(:),hr(:),mnt(:),mon(:),year(:),ippt(:)
	integer, allocatable::sta(:)
	character (len=10):: thtime, vdate
	character (len=8):: thdate,hms
	character (len=3):: wkday,mnth,tz,month(12)
	character (len=31):: filin, outfile,infilt
	character (len=31), allocatable:: infil(:),stlo(:)
!	character (len=2), allocatable:: sta(:)
	character (len=20):: junk
	character (len=50):: header
	character (len=6):: vrsn, opsn
	logical:: match,lsfil,lapnd,leap
! initialize variables	
	call date_and_time(thdate,thtime)
	vrsn='0.1.07'; vdate='06Oct2015' ! previous revision 15 Sep 2015
	u=(/11,12,13,14,15,16/)
	lasday=(/31,28,31,30,31,30,31,31,30,31,30,31/)
! code that uses lasday needs a way to check for leap year *****************	
	month=(/'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug',&
	       &'Sep','Oct','Nov','Dec'/)
	dhr=1.98d0/24.d0
!  open log file
	open(u(1),file='nwsfmtLog.txt',status='unknown')
	write (*,*) 'Starting nwsfmt ver.',vrsn,' ',vdate
	write (u(1),*) 'Starting nwsfmt ver.',vrsn,' ',vdate
     	write (u(1),*) 'Date ',thdate(5:6),'/',thdate(7:8),'/',thdate(1:4)
	write (u(1),*) 'Time ',thtime(1:2),':',thtime(3:4),':',thtime(5:6)
! open initialization file & read data
	open(u(2),file='nwsfmt_in.txt',status='old') !renamed 3/3/2010
	write(u(1),*) 'Listing of initialization file:'
	read(u(2),*) junk,nsta
	write(u(1),*) junk,nsta
	read(u(2),*) junk,lines
	write(u(1),*) junk,lines
	read(u(2),*) header
	write(u(1),*) header
	allocate (infil(nsta),stlo(nsta),sta(nsta),dltim(nsta),dltimnu(nsta))
	do j=1,nsta
	  read(u(2),*) sta(j),stlo(j),infil(j)
	  write(u(1),*) sta(j),stlo(j),infil(j)
	end do
	read(u(2),*) junk,lapnd
	write(u(1),*) junk,lapnd
	if(lapnd) then
	  opsn='append'
	else
	  opsn='rewind'
	end if
	read(u(2),*) junk,rph
	write(u(1),*) junk,rph
	close(u(2))
! allocate arrays
	allocate (ppt(lines),da(lines),hr(lines),mnt(lines))
	allocate (mon(lines),year(lines),ippt(lines),dtim(lines))
	da=0;hr=0;mnt=0
! open & read input file, last data
	inquire(file='nwslast.txt',exist=lsfil)
	if(lsfil) then
	open(u(6),file='nwslast.txt',status='old',err=20)
   	  do j=1,nsta
	    match=.false.
   	    read(u(6),*,err=21,end=21) snx,dltm
!   use station number to match data to correct memory location   	  
   	    do k=1,nsta
   	      if(snx==sta(j)) then
   	        dltim(j)=dltm
   	        match=.true.
	        exit
   	      end if
   	    end do
	    if (match) then
	      cycle
	    else
	      write(u(1),*) 'No match for station ',snx
	      write(u(1),*) 'Check station numbers in initialization file&
	      &and in "nwslast.dat" file'
!	      pause 'Press <return/enter> key to exit'
	      stop 'Station mismatch, Line 88'
	    end if
   	  end do
 	else
   	  open(u(6),file='nwslast.txt',status='new')
   	  dltim=0
   	  do j=1,nsta
   	    write(u(6),*) sta(j),dltim(j)
   	  end do
	end if
  	close(u(6))
! open & read associated date file
	open(u(4),file='date.txt',status='old')
	read(u(4),*) wkday,mnth,day,hms,yr !,tz  !	read(u(4),*) wkday,mnth,day,hms,tz,yr
	close(u(4))
! open & read inut file, recent data
	file_loop: do j=1,nsta
	dtim=0.d0
	filin=adjustl(infil(j))
	write(u(1),*) 'Opening ', filin
	open(u(3),file=trim(filin),status='old')
	lcnt=0
if(rph==1) then
	do i=1,lines
	  read(u(3),*,err=10, end=10) da(i),hr(i),mnt(i),ppt(i)
	  lcnt=lcnt+1
	end do
else
	do i=1,lines
	  read(u(3),*,err=10, end=10) year(i),mon(i),da(i),hr(i),mnt(i),ppt(i)
	  lcnt=lcnt+1
	end do
end if
!	do i=1,lines
!	  read(u(3),*,err=10, end=10) da(i),hr(i),mnt(i),ppt(i)
!	  lcnt=lcnt+1
!	end do
   10	continue
   	close(u(3))
if(rph==1) then
! numeric month	
	do i=1,12
	  if(mnth==month(i)) mo=i
	end do
! assign correct month and year to data	
	do i=1,lcnt
	  ippt(i)=int(ppt(i)*100.)
	  if(da(i)<=day) then
	    mon(i)=mo
	    year(i)=yr
	  else
	    momi1=mo-1
	    yrmi1=yr
	    if(momi1<1) then
	      momi1=momi1+12
	      yrmi1=yr-1
	    end if
	    mon(i)=momi1
	    year(i)=yrmi1
	  end if
	end do
end if
	call s1904t(dtim,year,mon,da,hr,mnt,lcnt,lines)
! save data to file in format usable by thresh, and remove any redundant lines
	infilt=adjustl(infil(j))
	nd=scan(infilt,'.')
	outfile=infilt(1:nd-1)//'_t.txt'
	open (u(5),file=trim(outfile),position=opsn,err=31)
	dtimax=dltim(j)
!
! *** Decide what to do about stations that have readings on intervals shorter than one hour
	do i=lcnt,1,-1
! check for leap year	
	  leap=.false.
	  if (mod(year(i),4)==0 .and. mod(year(i),100) /= 0 &
     	  &.or. mod(year(i),400) == 0) leap=.true.
     	  if(leap)then
     	    lasday(2)=29
     	  else
     	    lasday(2)=28
     	  end if
! save data in fixed-width format for program 'thresh'     	  
	  if(dtim(i)>(dltim(j)+0.5d0/24.d0)) then
	    if(dtim(i)>dtimax) dtimax=dtim(i)
	    if(rph==1)write (u(5),'(i2.2,i4.4,i2.2,i2.2,i2.2,i4.4)',err=30)&
     	       & sta(j),year(i),mon(i),da(i),hr(i),ippt(i) ! Changed to 4-digit precip 7/21/2015, RLB
! check for gaps and fill in with zeros
	    dif=0.d0
	    if(dtim(i+1)>0.d0 .and. i>1)then     	       
	      dif=dtim(i-1)-dtim(i)
	      if(dif>=dhr) write(*,*) i, dif
	    end if
	    if(dif>=dhr) then
	      hrcnt=int(0.5+dif*24.d0)-1
	      write(u(1),*) 'hrcnt=', hrcnt
	      write(u(1),*) 'lines of fill-in data:'
	      do k=1,hrcnt
	        tyear=year(i)
	        tmon=mon(i)
	        tda=da(i)
	        thr=hr(i)+k
	        tmn=0
	        if(thr>23) then !assumes 24 hr clock with 12:00 a.m. (midnight) at 0:00
	          thr=thr-24
	          tda=tda+1
	          if(tda>lasday(tmon)) then
	            tda=tda-lasday(tmon)
	            tmon=tmon+1
	            if(tmon>12) then
	              tmon=tmon-12
	              tyear=tyear+1
	            end if
	          end if
	        end if
	        if(rph==1) write (u(5),'(i2.2,i4.4,i2.2,i2.2,i2.2,i4.4)',err=30)&
     	          & sta(j),tyear,tmon,tda,thr,0  ! Changed to 4-digit precip 7/21/2015, RLB
	        write (u(1),'(i2.2,i4.4,i2.2,i2.2,i2.2,i4.4)')&
     	          & sta(j),tyear,tmon,tda,thr,0  ! Changed to 4-digit precip 7/21/2015, RLB
  	      end do
	    end if
	  end if
	end do
	dltimnu(j)=dtimax
if(rph>1) then
	do i=1,lcnt
	  if(dtim(i)>(dltim(j)+0.5d0/(float(rph)*24.d0))) then
	      if(dtim(i)>dtimax) dtimax=dtim(i)
	      ippt(i)=int(ppt(i)*100.)
                       write (u(5),'(i2.2,i4.4,i2.2,i2.2,i2.2,i2.2,i4.4)',err=30)&
                          & sta(j),year(i),mon(i),da(i),hr(i),mnt(i),ippt(i) ! Changed to 4-digit precip 7/21/2015, RLB
	  end if
	end do
end if
	cycle
   30	continue ! error trapping added November 17, 2006
   	  write(u(1),*) 'Unable to append data to file ', trim(outfile)
   	  write(*,*) 'Unable to append data to file ', trim(outfile)
   	  close(u(5))
   31	continue
   	  write(u(1),*) 'Unable to open data file ', trim(outfile)
   	  write(*,*) 'Unable to open data file ', trim(outfile)  
	end do file_loop
! Update "nwslast.txt" file, which contains the most recent date of data
	open(u(6),file='nwslast.txt')
   	  do j=1,nsta
   	    write(u(6),*) sta(j),dltimnu(j)
   	  end do	  
	close(u(6))
	close(u(5))
	write(u(1),*) 'Program nwsfmt ended normally'
	write(*,*) 'Program nwsfmt ended normally'
   	close(u(1))
	stop
   20	continue
   	open(u(6),file='nwslast.txt',status='new')
   	do j=1,nsta
   	  write(u(6),*) sta(j),0.0
   	end do
   	  write(u(1),*) 'Program terminated,lastfile did not exist'
   	  write(u(1),*) 'lastfile created, restart program nwsfmt'
   	  write(*,*) 'Program terminated,lastfile did not exist'
   	  write(*,*) 'lastfile created, restart program nwsfmt'
   	close(u(6))
   	close(u(1))
   	stop
  21   continue
   	  write(u(1),*) 'Program terminated, error reading "nwslast.txt" '
   	  write(u(1),*) 'delete "nwslast.txt", restart program nwsfmt'
   	  write(*,*) 'Program terminated, error reading "nwslast.txt" '
   	  write(*,*) 'delete "nwslast.txt", restart program nwsfmt'
   	close(u(6))
   	close(u(1))

	end program nwsfmt
 
