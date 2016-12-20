! PURPOSE:
! 	  writes rainfall threshold parameters to individual time-series plot file per station
!
!
	
	subroutine gnpts1(ulog,uout,n,stationNumber,ctrHolder,&
	year,month,day,hour,minute,anteced,&
	recent,intensity,duration,precip,runningIntens,deficit,&
	intensityDuration,avgIntensity,outputFolder,&
	plotFile,stationLocation,in2mm,rph,pt,nlo20,xid,AWI,minTStormGap,&
	TavgIntensity,Tantecedent,Trecent,lowLim,upLim,precipUnit)
	implicit none
	
	
! FORMAL ARGUMENTS
	character, intent(in)    :: outputFolder*(*),plotFile*(*),stationNumber*(*)
	character, intent(in)    :: stationLocation*(*)
	character, intent(inout) :: xid*(*)
	character (len=2), intent(in) :: precipUnit
	real, intent(in)         :: anteced(n),recent(n),intensity(n),in2mm
	real, intent(in)         :: duration(n),runningIntens(n),AWI(n)
	real, intent(in)         :: deficit(n),intensityDuration(n),avgIntensity(n)
	real, intent(in)			 :: lowLim, upLim
	integer, intent(in)      :: n,year(n),minTStormGap,TavgIntensity,Tantecedent,Trecent
	integer, intent(in)      :: month(n),day(n),hour(n),minute(n),precip(n)
	integer, intent(in)      :: uout,ulog,ctrHolder,rph,nlo20,pt(nlo20)
	
! LOCAL VARIABLES
	character (len=255) :: outputFile
	character (len=22)  :: header,mdurflag
	character (len=10)  :: date,manteced,mrecent,mintensity,mduration
	character (len=10)  :: mrunningIntens,mprecip,mdeficit,mavgIntensity
	character (len=10)  :: mintensityDuration,mAWI
	character (len=10)  :: mmIntensity,logmmIntensity 
	character (len=5)   :: time,hrly
	character 	    :: pd = char(35),tb = char(9)
	real            :: floatPrecip
	logical         :: intensLogic1, intensLogic2, durLow, durHigh, runningIntensLogic
	integer		    :: j,tptr,tptrm1

!------------------------------	
! Create output files for stationNumber
	outputFile=trim(adjustl(stationNumber))//'.txt'
  	outputFile=trim(outputFolder)//trim(plotFile)//trim(adjustl(xid))//outputFile

! Create file header to identify rainfall threshold type.  	
   write(hrly,'(i5)') TavgIntensity
   hrly=adjustl(hrly)
   select case (trim(adjustl(xid)))
   case('ExRA_'); header='Recent & Antecedent'
   case('ExID_'); header='Intensity-Duration'
   case('ExIDA'); header='Int.-Dur. & Ant. Water'
   case('ExIR_'); header=trim(hrly)//'-hr Intensity'
   case('ExIRA'); header='Intensity & Cumulative'
   end select
   open(uout,file=outputFile,status='unknown',position='rewind',err=125)
	
! Write heading if writing a new file (position=rewind); skip if appending to an old one.     
   write(uout,*) pd,' Times of exceedance for rainfall threshold: '//header
   write(uout,*) pd,' Station ',trim(stationNumber),': ',trim(stationLocation)
   write(uout,*) pd,' Time & Date',tb,&
                 'Hourly Precip.',tb,&
                 Tantecedent,'-hr Precip.',tb,&
                 Trecent,'-hr Precip.',tb,&
                 'Intensity(in/hour)',tb,&
                 'Intensity(mm/hour)',tb,&
                 'Duration',tb,&
                 'Log10(Intensity(mm/hour))',tb,&
                 trim(hrly)//'-hr Intensity (in/hour)',tb,&
                 'Recent/Antecedent Index',tb,&
                 'Intensity-Duration Index',tb,&
                 TavgIntensity,'-hr Intensity Index',tb,&
                 'Antecedent Water Index',tb,&
                 'Duration Descripton'

! Read data and write time-series plot file
   tptrm1=pt(1)-1
   do j=1,ctrHolder
      tptr=pt(j)
      !initialize mdurflag, intensLogic, durLow, durHigh
      mdurflag            = ""
      intensLogic1        = intensity(tptr)<0
!      intensLogic2        = intensity(tptr)*in2mm<1.d-1
      intensLogic2        = abs(intensity(tptr)*in2mm)<1.d-2
      durLow              = duration(tptr) < lowLim
      durHigh             = duration(tptr) > upLim
      runningIntensLogic  = runningIntens(tptr)<0
      
      if(tptr-tptrm1>rph*minTStormGap) then
         write(uout,*) ''
      end if
      write(time,'(i2.2,a1,i2.2)') hour(tptr), ':',minute(tptr)
      write(date,'(i2.2,a1,i2.2,a1,i4)')month(tptr),'/',day(tptr),'/',year(tptr)
      
     
!  Write data to text strings and trim blank spaces to reduce file size      
		if (precipUnit == 'mm') then
			floatPrecip = float(precip(tptr))/254.
		else if (precipUnit == 'in') then
			floatPrecip = float(precip(tptr))/100.
		end if
		
      write(mprecip,             '(f10.2)')     floatPrecip
      write(manteced,            '(f10.2)')     anteced(tptr)
      write(mrecent,             '(f10.2)')     recent(tptr)
      write(mintensity,          '(f10.3)')     intensity(tptr)
      if(intensLogic1) then
         write(mmIntensity,      '(f10.3)')     intensity(tptr)
      else
         write(mmIntensity,      '(f10.3)')     intensity(tptr)*25.4
      end if
      if(intensLogic2) then
         write(logmmIntensity,   '(f10.3)')     -99.
      else 
         write(logmmIntensity,   '(f10.3)')     log10(intensity(tptr)*25.4)
      end if
      write(mduration,           '(f10.2)')     duration(tptr)
      if(durLow) then 
         write(mdurflag,         '(A)'    )     '< minimum defined'
      else if(durHigh) then 
         write(mdurflag,         '(A)'    )     '> maximum defined' 
      else
          write(mdurflag,         '(A)'    )     'within limits'   
      end if
      if(runningIntensLogic) then
         write(mrunningIntens,   '(f10.3)')     runningIntens(tptr)
      else
         write(mrunningIntens,   '(f10.3)')     runningIntens(tptr) !*in2mm
      end if
      write(mdeficit,            '(f10.3)')     deficit(tptr)
      write(mintensityDuration,  '(f10.3)')     intensityDuration(tptr)
      write(mavgIntensity,       '(f10.3)')     avgIntensity(tptr)
      write(mAWI,                '(f10.3)')     AWI(tptr)
	  
      manteced            = trim(adjustl(manteced))
      mrecent             = trim(adjustl(mrecent))
      mintensity          = trim(adjustl(mintensity))
      mmIntensity         = trim(adjustl(mmIntensity))
      logmmIntensity      = trim(adjustl(logmmIntensity))
      mduration           = trim(adjustl(mduration))
      mdurflag            = trim(adjustl(mdurflag))
      mrunningIntens      = trim(adjustl(mrunningIntens))
      mprecip             = trim(adjustl(mprecip))
      mdeficit            = trim(adjustl(mdeficit))
      mavgIntensity       = trim(adjustl(mavgIntensity))
      mintensityDuration  = trim(adjustl(mintensityDuration))
      mAWI                = trim(adjustl(mAWI))
	  
!Writing values of local variables to file	  
      write(uout,*)time,' ',date,tb,&
                   mprecip,tb,&
                   manteced,tb,&
                   mrecent,tb,&
                   mintensity,tb,&
                   mmIntensity,tb,&
                   mduration,tb,&
                   logmmIntensity,tb,&
                   mrunningIntens,tb,&
                   mdeficit,tb,&
                   mintensityDuration,tb,&
                   mavgIntensity,tb,&
                   mAWI,tb,&
                   mdurflag
      tptrm1=tptr
   end do
   close(uout)
   write(*,*) xid,' time-series plot file finished'
   return

! DISPLAY ERROR MESSAGE
   125  write(*,*) 'Error opening file ',outputFile	
        write(*,*) 'Press Enter key to exit program.'
        read(*,*)
        write(ulog,*) 'Error opening file ',outputFile		
        close (ulog)
        stop
   end subroutine gnpts1
