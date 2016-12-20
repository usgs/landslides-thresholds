! PURPOSE: 
!	  writes rainfall threshold parameters to individual archive 
!	  file per station	

	
	subroutine arcsav(ulog,uout,n,stationNumber,ctrHolder,&
	stationPtr,year,month,day,hour,minute,sumAnteced,&
	sumRecent,intensity,stormDuration,precip,runIntensity,AWI,outputFolder,&
	archiveFile,stationLocation,TavgIntensity,Tantecedent,Trecent,precipUnit,&
        checkS,checkA)
	implicit none
	
! FORMAL ARGUMENTS
	character, intent(in) :: outputFolder*(*),archiveFile*(*),stationNumber*(*)
	character, intent(in) :: stationLocation*(*)
	character (len=2), intent(in) :: precipUnit
	real, intent(in)      :: sumAnteced(n),sumRecent(n),intensity(n)
	real, intent(in)      :: stormDuration(n),AWI(n),runIntensity(n)
	integer, intent(in)   :: n,TavgIntensity
	integer, intent(in)   :: uout,ulog,ctrHolder,stationPtr,Tantecedent,Trecent
	integer, intent(in)   :: year(n),month(n),day(n),hour(n),minute(n),precip(n)
        logical, intent(in)   :: checkS,checkA	
	
! LOCAL VARIABLES
	character (len=255) :: outputFile
	character (len=12)  :: sNumber
	character (len=10)  :: date,msumAnteced,msumRecent,mintensity
	character (len=10)  :: mstormDuration,mrunIntensity,mAWI,mprecip
	character (len=6)   :: pn
	character (len=5)   :: time
	character (len=3)   :: AntecedentHeader
	character (len=1)   :: pd=char(35),tb=char(9)
	real                :: floatPrecip
	integer             :: j
	logical             :: exists

!------------------------------	
	sNumber = adjustl(trim(stationNumber))// '.txt'
  	outputFile=trim(outputFolder)//trim(archiveFile)//trim(sNumber)

! Set text for heading of Antecedent precipitation column
  	if(checkS) then
  	   AntecedentHeader='SAP' !Seasonal Antecedent Precipitation
        else if (checkA) then
           AntecedentHeader='AWI' !Antecedent Wetness Index
        else
           AntecedentHeader='ACP' !Annual Cumulative Precipitation
        end if
  	
  	inquire(file=outputFile,exist=exists)
  	if(exists) then
  	   pn = 'append'
  	else
  	   pn = 'rewind'
  	end if
        
	open(uout,file=outputFile,status='unknown',position=pn,err=125)
	
! Write heading if writing a new file (position=rewind); skip if appending to an old one.     
     	if(pn=='rewind') then
	  write(uout,*) pd,' Archive of Rainfall Totals for Comparison with Thresholds'
	  write(uout,*) pd,' Station ',trim(stationNumber) ,': ',trim(stationLocation)
	  write(uout,*) pd,' Time & Date',&
                   tb,'Hourly Precip.',&
                   tb,Tantecedent,'-hr Antecedent Precip.',&
                   tb,Trecent,'-hr Precip.',&
                   tb,'Intensity',&
                   tb,'Duration',&
                   tb,TavgIntensity,'-hr Intensity',&
                   tb,AntecedentHeader
     	end if

! Fill file with data
write(*,*) '!## stationPtr, ctrHolder ##! ', stationPtr,ctrHolder 
	do j=(1+stationPtr-ctrHolder),stationPtr
      
	   !Initializing floatPrecip variable
		if (precipUnit == 'mm') then
			floatPrecip = float(precip(j))/254.
		else if (precipUnit == 'in') then
			floatPrecip = float(precip(j))/100.
		end if

     !Writing values to string variables
	  write(time,'(i2.2,a1,i2.2)') hour(j), ':',minute(j)
	  write(date,'(i2.2,a1,i2.2,a1,i4)')month(j),'/',day(j),'/',year(j)
     	  
	  write(msumAnteced,     '(f10.2)')     sumAnteced(j)
     write(msumRecent,      '(f10.2)')     sumRecent(j)
     write(mintensity,      '(f10.3)')     intensity(j)
     write(mstormDuration,  '(f10.2)')     stormDuration(j)
     write(mrunIntensity,   '(f10.3)')     runIntensity(j)
     write(mAWI,            '(f10.3)')     AWI(j)
	  write(mprecip,         '(f10.2)')     floatPrecip
	  
	  msumAnteced       = trim(adjustl(msumAnteced))
	  msumRecent        = trim(adjustl(msumRecent))
	  mintensity        = trim(adjustl(mintensity))
	  mstormDuration    = trim(adjustl(mstormDuration))
	  mrunIntensity     = trim(adjustl(mrunIntensity))
	  mprecip           = trim(adjustl(mprecip))
	  
!  Write data to internal files and trim blank spaces to reduce file size      
	  write(uout,*)time,' ',date,tb,&
	               mprecip,tb,&
	               msumAnteced,tb,&
	               msumRecent,tb,&
	               mintensity,tb,&
	               mstormDuration,tb,&
	               mrunIntensity,tb,&
	               mAWI
     	end do
	close(uout)
	write(*,*) 'Finished updating archive files'
	return
	
! DISPLAYS ERROR MESSAGE
  125	write(*,*) 'Error opening file ',outputFile	
  	write(*,*) 'Press Enter key to exit program.'
  	read(*,*) 
  	write(ulog,*) 'Error opening file ',outputFile		
  	close (ulog)
	stop
	end subroutine arcsav
