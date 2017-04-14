! Program to compute maximum "threat score," and other ROC statistics for optimizing decision thresholds
! Rex L. Baum, USGS, 19 May 2016
! latest revision 3 June 2016
program tsthresh
implicit none
integer:: count_rf_sort, count_sli_rf_sort,num_incr,u(4),i,j,k
integer:: num_pairs,line_ctr,itsmax,dec_count,patlen
integer, allocatable:: count_rf_incr_excd(:),count_sli_incr_excd(:)
real, allocatable:: rf_sort(:), sli_rf_sort(:), rf_incr(:)
real, allocatable:: ts(:), tp_rate(:), fp_rate(:)
real:: rfmax, rfmin, tsmax, Y, tp, tn, fp, fn, temp, fac_10, auc
character (len=255):: rf_sort_fil, rf_sli_sort_fil,junk,outfil
character (len=224):: out_path
character (len=31):: init
character (len=24), allocatable::identifier(:)
character (len=9) :: vrsn,bldate
character (len=1):: cm
logical:: ans, l_zero
u=(/11,12,13,14/)
ans=.false.; l_zero=.false.
cm=char(44)
! latest version and date
vrsn='1.0.03'; bldate='14Apr2017'
! Read input files of sorted rainfall totals for entire time period and for landslides occuring during that period
! Read list of input file pairs from a text file
write(*,*) 'tsthresh, version ', trim(vrsn), ', built ', bldate
write(*,*) ' by Rex L. Baum, USGS'
write(*,*) '*****************************'
init='tsth_in.txt'
init=adjustl(init)
inquire (file=trim(init),exist=ans)
if(ans) then
    open (u(1),file=trim(init),status='old',err=100)
    write (*,*) 'Opening default initialization file'
else
    write (*,*) 'Cannot locate default initialization file, <tsth_in.txt>'
    write (*,*) 'Type name of initialization file and'
    write (*,*) 'press RETURN to continue'
    read (*,'(a)') init
    init=adjustl(init)
    open (u(1),file=trim(init),status='old',err=100)
end if
num_pairs=0;line_ctr=1
do 
    read(u(1),*,err=110, end=10) temp
    line_ctr=line_ctr+1
    read(u(1), '(a)', err=120) junk
    line_ctr=line_ctr+1
    read(u(1), '(a)', err=120, end=10) junk
    line_ctr=line_ctr+1
    num_pairs=num_pairs+1
end do
10 continue
write(*,*) 'num_pairs= ', num_pairs
rewind(u(1))
allocate(identifier(num_pairs))
identifier='';line_ctr=1
do k=1, num_pairs
    read(u(1),*,err=110, end=20) identifier(k)
    line_ctr=line_ctr+1
    read(u(1), '(a)', err=120) rf_sort_fil
    line_ctr=line_ctr+1
    read(u(1), '(a)', err=120, end=20) rf_sli_sort_fil
    line_ctr=line_ctr+1
    identifier(k)=adjustl(identifier(k))
    rf_sort_fil=adjustl(rf_sort_fil)
    rf_sli_sort_fil=adjustl(rf_sli_sort_fil)
    write(*,*) trim(rf_sort_fil)
!    inquire(file=trim(rf_sort_fil),exist=ans1)
!    inquire(file=trim(rf_sli_sort_fil ),exist=ans2)
    open(u(2), file=trim(rf_sort_fil), status='old', err=130)
    open(u(3), file=trim(rf_sli_sort_fil), status='old', err=140)
    patlen=scan(rf_sort_fil,'/\',.true.) ! find end of folder name
    out_path=rf_sort_fil(1:patlen) ! path to sorted rainfall file
    outfil=trim(out_path)//'TS_'//trim(identifier(k))//'.txt'
    open(u(4),file=trim(outfil),status='unknown',err=170)
    write(u(4),*,err=180) 'tsthresh, version ', trim(vrsn), ', built ', bldate
    write(u(4),*,err=180) '*****************************'
    write(u(4),*,err=180) trim(identifier(k))
    write(u(4),*,err=180) trim(rf_sort_fil)
    write(u(4),*,err=180) trim(rf_sli_sort_fil)
    write(u(4),*,err=180) '*****************************'
    count_rf_sort=0
    do
        read(u(2),*,err=150,end=50) temp
        count_rf_sort=count_rf_sort+1
    end do
    50 continue
    rewind(u(2))
    write(u(4),*,err=180) 'count_rf_sort ',count_rf_sort
    allocate(rf_sort(count_rf_sort))
    rf_sort=0
    do i=1,count_rf_sort
        read(u(2),*,end=51) rf_sort(i)
    end do
    51 continue
    close(u(2))
    count_sli_rf_sort=0
    rfmax=maxval(rf_sort)
    rfmin=minval(rf_sort)
! Determine multiplier for fixed decimal input.
    dec_count=0;fac_10=1.0
    do
        if(abs(fac_10*(rfmax-rfmin)-int(fac_10*(rfmax-rfmin)))>0.099 .or. fac_10<100.) then
            fac_10=10.0*fac_10
            write(u(4),*,err=180) fac_10, fac_10*(rfmax-rfmin),&
              &abs(fac_10*(rfmax-rfmin)-int(fac_10*(rfmax-rfmin)))
        else
            exit
        end if
    end do
    if (fac_10>1000.) fac_10=1000.
    if(rfmin==0. .or. l_zero) then
        num_incr=int(fac_10*rfmax)+1
    else
        num_incr=int(fac_10*(rfmax-rfmin))+1
    end if
    write(u(4),*,err=180) 'rfmax, rfmin, num_incr, fac_10 ',rfmax, rfmin, num_incr, fac_10
    do
        read(u(3),*,err=160, end=60) temp
        count_sli_rf_sort=count_sli_rf_sort+1
    end do
    60 continue
    rewind(u(3))
    write(u(4),*,err=180) 'count_sli_rf_sort ',count_sli_rf_sort
    allocate(sli_rf_sort(count_sli_rf_sort))
    sli_rf_sort=0
    do i=1,count_sli_rf_sort
        read(u(3),*,end=61) sli_rf_sort(i)
    end do
    61 continue
    close(u(3))
    allocate(count_rf_incr_excd(num_incr),count_sli_incr_excd(num_incr),ts(num_incr),rf_incr(num_incr))
    allocate(tp_rate(num_incr),fp_rate(num_incr))
    count_rf_incr_excd=0; count_sli_incr_excd=0; ts=0;tsmax=0
    auc=0.
    write(u(4),*,err=180)  'rf_incr(i), tp, Y (=tp+fp), fn, tn'
    do i=1,num_incr
        rf_incr(i)=float(i-1)/fac_10+rfmin
        do j=1,count_rf_sort
            if(rf_sort(j)<rf_incr(i)) then
                count_rf_incr_excd(i)=count_rf_incr_excd(i)+1
            else
                exit
            end if
        end do
        do j=1,count_sli_rf_sort
            if(sli_rf_sort(j)<rf_incr(i)) then
                count_sli_incr_excd(i)=count_sli_incr_excd(i)+1
            else
                exit
            end if
        end do
        fn=float(count_sli_incr_excd(i))
        Y=float(count_rf_sort)-float(count_rf_incr_excd(i))
        tp=float(count_sli_rf_sort)-fn
        fp=Y-tp
        tn=float(count_rf_incr_excd(i)-count_sli_incr_excd(i))
        tp_rate(i)=tp/(tp+fn)
        fp_rate(i)=fp/(fp+tn)
        write(u(4),*,err=180)  rf_incr(i), cm, tp, cm, Y, cm, fn, cm, tn
        ts(i)=tp/(Y+fn)
        if(ts(i)>tsmax) then
            tsmax=ts(i)
            itsmax=i
        endif
        if(i>1) then
            auc=auc+abs(fp_rate(i)-fp_rate(i-1))*(tp_rate(i)+tp_rate(i-1))/2.
        end if
    end do
!    tsmax=maxval(ts)
    write(u(4),*,err=180) 'Identifier, tsmax, rf_incr(itsmax) : ', identifier(k), tsmax, rf_incr(itsmax)
    write(u(4),*,err=180) 'Area under ROC curve (AUC): ', auc
    write(u(4),*,err=180) 'Cumulative rainfall' , cm,'TS ', cm, 'TP rate ', cm, 'FP rate'
    do i=1,num_incr                 
        write(u(4),*,err=180) rf_incr(i), cm, ts(i), cm, tp_rate(i), cm, fp_rate(i)
    end do
    deallocate(rf_sort,sli_rf_sort,count_rf_incr_excd,count_sli_incr_excd,ts,rf_incr)
    deallocate(tp_rate,fp_rate)
    close(u(4))
end do 
close(u(1))
write(*,*) 'Program tsthresh finished normally'
stop '0'
100 continue
    write (*,*) '*** Error opening intialization file in tsthresh ***'
    write (*,*) '--> ',trim(init)
    write (*,*) 'Check file location and name'
    write(*,*) 'Press RETURN to exit'
    read*
stop '100 in tsthresh'
110 continue
    write (*,*) '*** Error reading numeric value frm intialization file in tsthresh ***'
    write (*,*) '--> ',trim(init)
    write (*,*) 'at ine',line_ctr
    write(*,*) 'Press RETURN to exit'
    read*
stop '110 in tsthresh'
120 continue
    write (*,*) '*** Error reading string value frm intialization file in tsthresh ***'
    write (*,*) '--> ',trim(init)
    write (*,*) 'at ine',line_ctr
    write(*,*) 'Press RETURN to exit'
    read*
stop '120 in tsthresh'
130 continue
    write (*,*) '*** Error opening data file in tsthresh ***'
    write (*,*) '--> ',trim(rf_sort_fil)
    write (*,*) 'Check file location and name'
    write(*,*) 'Press RETURN to exit'
    read*
stop '130 in tsthresh'
140 continue
    write (*,*) '*** Error opening data file in tsthresh ***'
    write (*,*) '--> ',trim(rf_sli_sort_fil)
    write (*,*) 'Check file location and name'
    write(*,*) 'Press RETURN to exit'
    read*
stop '140 in tsthresh'
150 continue
    write (*,*) '*** Error reading numeric value from data file in tsthresh ***'
    write (*,*) '--> ',trim(rf_sort_fil)
    write (*,*) 'at ine',count_rf_sort+1
    write(*,*) 'Press RETURN to exit'
    read*
stop '150 in tsthresh'
160 continue
    write (*,*) '*** Error reading numeric value from data file in tsthresh ***'
    write (*,*) '--> ',trim(rf_sli_sort_fil)
    write (*,*) 'at ine',count_sli_rf_sort+1
    write(*,*) 'Press RETURN to exit'
    read*
stop '160 in tsthresh'
170 continue
    write (*,*) '*** Error opening output file in tsthresh ***'
    write (*,*) '--> ',trim(outfil)
    write (*,*) 'Check file location and name'
    write(*,*) 'Press RETURN to exit'
    read*
stop '170 in tsthresh'
180 continue
    write (*,*) '*** Error writing to output file in tsthresh ***'
    write (*,*) '--> ',trim(outfil)
    write(*,*) 'Press RETURN to exit'
    read*
stop '180 in tsthresh'
20 continue
write(*,*) 'Program tsthresh finished'
write(*,*) 'Last identifier might have been skipped'
end program tsthresh
