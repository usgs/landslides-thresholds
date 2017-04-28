module data_analysis
implicit none

contains 
   !PURPOSE : 
   !	  Tracks storms and antecedent precipitation
   !
	subroutine track_storm(diffPtrOffset,stationPtr,precip,resetAntMonth,&
	resetAntDay,AWI,AWIconversion,evapConsts,timestampMonth,decayFactor,&
	drainConst,fieldCap,da,hr,TavgIntensity,rph,runIntensity,sumTintensity,&
	minTStormGap,TstormGap,tRainfallBegan,trfbeg,eachDate1904,tstormBeg1904,&
	tRainfallEnd,trfend,tstormEnd1904,dgap,xptr,intensity,dur,numStations,&
	maxLines,Tintensity,precipUnit) !{{{
	implicit none
	integer,parameter :: double=kind(1d0)
	
   ! FORMAL ARGUMENTS
	   real, intent(in)    		:: AWIconversion, evapConsts(12)
	   real, intent(in)    		:: decayFactor, drainConst, fieldCap
	   real, intent(in)             :: TavgIntensity, minTStormGap, Tintensity
	   real, intent(out)   		:: runIntensity(maxLines)
	   real, intent(out)   		:: dur(maxLines), intensity(maxLines)
	   real, intent(inout) 		:: AWI(maxLines)
	   real (double), intent(in)    :: eachDate1904(maxLines), dgap
	   real (double), intent(out)   :: trfbeg, trfend
	   real (double), intent(inout) :: tstormBeg1904
	   real (double), intent(inout) :: tstormEnd1904
	   integer, intent(in)  	:: diffPtrOffset, stationPtr, precip(maxLines)
	   integer, intent(in)  	:: resetAntMonth, resetAntDay, da(maxLines)
	   integer, intent(in)  	:: hr(maxLines),rph
	   integer, intent(in)  	:: numStations, maxLines
	   integer, intent(in)  	:: timestampMonth(maxLines) 
	   integer, intent(out) 	:: tRainfallBegan, tRainfallEnd, sumTintensity
	   integer, intent(out) 	:: TstormGap, xptr
	   character (len=2), intent(in) :: precipUnit

   ! LOCAL VARIABLES
	   real :: floatPrecip
	   integer :: i, j, AvgIntensityCounts,StormGapMinCounts
	   logical :: flagStormEnd

   !-----------------------------
      ! Initialize variables
	   flagStormEnd = .true.
      
	   ! compute antecedent water balance and intensity
	   MainLoop: do i = (1 + diffPtrOffset), stationPtr
	     floatPrecip = float(precip(i))
		
              ! Compute either antecedent Water Index (AWI) or Cumulative precipitation	   
	      if(resetAntMonth * resetAntDay <= 0) then ! Reset date not given, so compute (AWI)
	         if(AWI(i - 1) < 0.) then ! below field capacity
	            AWI(i) = AWI(i - 1) + AWIconversion * (floatPrecip - &
	            evapConsts(timestampMonth(i)))
	         else ! above field capacity, so allow drainage
	            AWI(i) = AWI(i - 1) * decayFactor + AWIconversion * &
	            (floatPrecip - evapConsts(timestampMonth(i)))*&
	            (1. - decayFactor) / drainConst
	         end if
	         if(AWI(i) < -fieldCap) AWI(i) = -fieldCap ! minimum value of AWI
	      else ! Reset date is given, so compute cumulative precipitation
	         AWI(i) = AWI(i - 1) + AWIconversion * floatPrecip
	         if(da(i) == resetAntDay) then
	            if(timestampMonth(i) == resetAntMonth .and. hr(i) <= 1) then 
	               AWI(i) = 0. ! Reset running total for annual running antecedent rainfall
	            end if
	         end if
	      end if
	      ! Set no-data value for cells too close to beginning of file to 
	      ! compute running average antecedent precip. 
              AvgIntensityCounts=ceiling(TavgIntensity*float(rph))
	      if((i - AvgIntensityCounts)<0) runIntensity(i) = -99. 
	      sumTintensity = 0
	   
	      ! Determine starting time of a storm 
              StormGapMinCounts=ceiling(minTStormGap*float(rph))
	      if((i - StormGapMinCounts) >= 1) then
	         TstormGap = 0
	         do j = 1, StormGapMinCounts
	            if (precip(i - j) == 0) TstormGap = TstormGap + 1
	         end do
	         if(TstormGap == StormGapMinCounts .and. precip(i)>0) then
	            tRainfallBegan = i - 1
	            trfbeg = eachDate1904(tRainfallBegan)
	            if(trfbeg >= tstormBeg1904) then 
                       tstormBeg1904 = trfbeg 
                       flagStormEnd = .false.
	            end if
	         end if
	      end if
	      if(i == 1 .and. precip(i) > 0) then
	         tstormBeg1904 = eachDate1904(1) - 1.d0 / (float(rph) * 24.d0)  
	      end if
	   
	      ! determine incremental ending times of storms
	      if(precip(i) > 0 .and. eachDate1904(i) >= tstormBeg1904) then
	         tRainfallEnd = i
	         trfend = eachDate1904(tRainfallEnd)  
	         if(trfend >= tstormEnd1904) then
	            tstormEnd1904 = trfend
	         end if
	      end if
	      !  record duration of most recent storm  for "dgap" hours after
	      !  end of storm.  End of storm must precede or equal current time
	      !  and end of storm must be later than beginning of storm
	      if(eachDate1904(i) >= tstormEnd1904) then
	         if((eachDate1904(i) - dgap) <= tstormEnd1904) then
	            if(tstormEnd1904 >= tstormBeg1904) then
	               dur(i) = (tstormEnd1904 - tstormBeg1904) * 24.d0 ! storm duration in hours
	               	 
	               if(Tintensity == 0.) then ! Storm-average intensity 
                       ! compute latest average precipitation intensity since beginning of storm	
	                  PreliminaryIntensity: do j = tRainfallBegan, i ! during first hours after 
                                              ! rainfall ends, computes gradually decreasing intensity
	                     xptr = j
                        ! check for insufficient data
	                     if(xptr < 1) then
	                        sumTintensity = -99
                        ! check for no data
	                     else if(precip(xptr) < 0) then
	                        sumTintensity = -99
	                     else
	                        sumTintensity = sumTintensity + precip(xptr)
	                     end if
	                  end do PreliminaryIntensity
	                  if(dur(i) > 0 .and. sumTintensity >= 0) then
	                     intensity(i)=float(sumTintensity) / &
	                     ((eachDate1904(i) - tstormBeg1904) * 24.d0 * 100.) 
	                  ! during first hours after rainfall ends, computes gradually decreasing intensity
	                  else
	                     intensity(i) = float(sumTintensity)
	                  end if
	               end if
	            end if
	         end if
	      end if
! 
             ! Post-storm corrections of storm duration and average intensity.
	      if((i - StormGapMinCounts) == tRainfallEnd) flagStormEnd=.false. ! Most recent storm has ended   
	      if (.not. flagStormEnd) then ! Correct intensity & duration values after storm ends
	         if(Tintensity == 0.) then ! Storm-average intensity selected 
	            sumTintensity=0
	            CorrectedIntensity: do j = tRainfallBegan+1, tRainfallEnd
	              xptr = j
                     ! check for insufficient data
	              if(xptr < 1) then
	                 sumTintensity = -99
                     ! check for no data
	              else if(precip(xptr) < 0) then
	                 sumTintensity = -99
	              else
	                 sumTintensity = sumTintensity + precip(xptr)
	              end if
	              dur(j) = (eachDate1904(j) - tstormBeg1904) * 24.d0 ! storm duration in hours
	              intensity(j)=float(sumTintensity) / &
	                 & ((eachDate1904(j) - tstormBeg1904) * 24.d0 * 100.) 
	            end do CorrectedIntensity
	            ! zero out post-storm duration and intensity
	            do j = tRainfallEnd +1, tRainfallEnd + StormGapMinCounts 
	               dur(j)=0 
	               intensity(j)=0.
	            end do
	            flagStormEnd = .true.
	         end if
	      end if
           end do MainLoop
        end subroutine track_storm
   ! END OF SUBROUTINE }}}

   !PURPOSE:
   !	 
   !  	 
	subroutine track_intensity(stationPtr,maxLines,tlenx,sumTintensity,&
	sumTrecent,sumTantecedent,tptr,Trecent,rph,xptr,precip,Tintensity,&
	TavgIntensity,Tantecedent,cumRainfall,intensity,runIntensity,&
	runningIntens,ctri,ctra,intercept,slope,deficit,ctr_recent_antecedent,pt_recent_antecedent,ctrira,&
	ptira,awimx,AWI,AWIexceedCtr,powerSwitch,polySwitch,interSwitch,&
	intervals,xVals,yVals,intensityDuration,in2mm,powerCoeff,duration,&
	powerExp,polynomArr,ctrid,ptid,AWIThresh,AWIIntensCtr,ptawid,&
	threshAvgExceed,ctria,nlo20,ptia,id_index_factor) !{{{
	implicit none

   ! FORMAL ARGUMENTS
	real, intent(in)    :: intercept,slope,Tintensity,TavgIntensity
	real, intent(in)    :: AWI(*),in2mm,powerCoeff,id_index_factor
	real, intent(in)    :: duration(*),powerExp,polynomArr(*),AWIThresh
	real, intent(in)    :: runningIntens, xVals(intervals+1), yVals(intervals+1)
	real, intent(out)   :: intensityDuration(*),intensity(*)
	real, intent(out)   :: runIntensity(maxLines), deficit(*), sumTrecent(maxLines)
	real, intent(out)   :: threshAvgExceed(maxLines), sumTantecedent(maxLines)
	real, intent(inout) :: awimx
	integer, intent(in)    :: stationPtr, tlenx, Trecent, maxLines
	integer, intent(in)    :: rph, precip(*)
	integer, intent(in)    :: Tantecedent,nlo20, intervals
	integer, intent(out)   :: pt_recent_antecedent(*),ptira(*)
	integer, intent(out)   :: ptid(*),ptawid(*),ptia(*)
	integer, intent(out)   :: sumTintensity,tptr, xptr
	integer, intent(inout) :: cumRainfall,ctri,ctra,ctr_recent_antecedent,ctrira
	integer, intent(inout) :: AWIexceedCtr,ctrid,ctria,AWIIntensCtr
	logical, intent(in)    :: powerSwitch, polySwitch, interSwitch
	
   ! LOCAL VARIABLES
   real    :: m, b
	integer :: i, j, x, sumTavgIntensity
	integer :: ssumTrecent, ssumTantecedent,AvgIntensityCounts,IntensityCounts
   !------------------------
	   do i=(1 + stationPtr - tlenx),stationPtr
	      ssumTrecent = 0
	      ssumTantecedent = 0
	      sumTintensity = 0
	      sumTavgIntensity = 0
	      tptr = i 
	      ! computations for "linear" files	
	      ! compute cumulative "Trecent"-hour recent precipitation	
	      if(Trecent <=0) then
	      	sumTrecent = -99.	  
	      else
	         do j = 1, Trecent*rph
	            xptr = tptr - j + 1
	            ! check for insufficient data
	            if(xptr < 1) then
	      	      ssumTrecent = -9900
	               exit
	            else if(precip(xptr) < 0) then
	      	      ssumTrecent = -9900	! check for no data
	      	      exit
	            else
                  ssumTrecent = ssumTrecent + precip(xptr)
               end if
            end do
         end if
         if(Tintensity > 0.) then
            ! compute latest "Tintensity"-hour precipitation intensity (this is a running average intensity)
           IntensityCounts=ceiling(Tintensity*float(rph))
           do j = 1, IntensityCounts 
               xptr = tptr - j + 1
               ! check for insufficient data
               if(xptr < 1) then
                  sumTintensity = -9900 * ceiling(Tintensity)
                  exit
               else if(precip(xptr) < 0) then	! check for no data
                  sumTintensity = -9900 * ceiling(Tintensity)
                  exit
               else
                  sumTintensity = sumTintensity + precip(xptr)
               end if
            end do
         end if
         if(TavgIntensity < 0.) then
         	runIntensity = -99.         		  
         else 		  
            ! compute latest "TavgIntensity"-hour precipitation (running average) intensity 	
            AvgIntensityCounts=ceiling(TavgIntensity*float(rph))
            do j = 1, AvgIntensityCounts 
               xptr = tptr - j + 1
               ! check for insufficient data
               if(xptr < 1) then
                  sumTavgIntensity = -9900 * ceiling(TavgIntensity)
                  exit
               else if(precip(xptr) < 0) then	! check for no data
                  sumTavgIntensity = -9900 * ceiling(TavgIntensity)
                  exit
               else
                  sumTavgIntensity = sumTavgIntensity + precip(xptr)
               end if
            end do
         end if
         ! compute cumulative "Tantecedent"-hour antecedent precipitation
         if(Tantecedent <= 0 .or. Trecent<=0) then 
            sumTantecedent = -99.
         else
            do j = 1, Tantecedent * rph
               xptr = tptr - j + 1 - Trecent * rph
               ! check for insufficient data
               if(xptr < 1) then
                  ssumTantecedent = -9900
                  exit
               else if(precip(xptr) < 0) then
                  ssumTantecedent = -9900		! check for no data
                  exit
               else
                  ssumTantecedent = ssumTantecedent + precip(xptr)
               end if
            end do
         end if
         
         sumTrecent(i) = float(ssumTrecent) / 100.
         sumTantecedent(i) = float(ssumTantecedent) / 100.
         
         if(sumTantecedent(i) >= 0) cumRainfall=cumRainfall+1 ! count number of possible values of Cumulative Antecedent total
            
         if(Tintensity > 0.) &
            intensity(i) = float(sumTintensity) / (Tintensity*float(rph)*100.)
            
         if(TavgIntensity > 0.) &
            runIntensity(i) = float(sumTavgIntensity) / (TavgIntensity*float(rph)*100.)
            
         if(intensity(i) >= 0) ctri = ctri + 1 ! count number of possible values of intensity
            
         if(runIntensity(i) >= 0) ctra = ctra + 1 ! count number of possible values of running average intensity
        
         ! Compute deficit/surplus relative to thresholds
         if(sumTantecedent(i) >= 0) then
            if(sumTantecedent(i) < (-intercept / slope)) then
               deficit(i) = sumTrecent(i) - (intercept + slope * sumTantecedent(i))
            else
               deficit(i) = sumTrecent(i)
            end if
            if(deficit(i) > 0) then 
               ctr_recent_antecedent = ctr_recent_antecedent + 1 ! count exceedence of Cumulative Recent & Antecedent totals
               pt_recent_antecedent(ctr_recent_antecedent) = i
            end if
         end if
         
         if(runIntensity(i) > runningIntens .and. deficit(i) > 0) then
            ctrira = ctrira + 1 ! count exceedences of running average Intensity threshhold when recent and antecedent threshhold is also exeeded.
            ptira(ctrira) = i
         end if	 
         
         if(AWI(i) > awimx) awimx = AWI(i)                         ! update max AWI if necessary
         if(AWI(i) >= AWIThresh) AWIExceedCtr = AWIExceedCtr + 1   !count exceedences of antecedent water index         
         
         if(duration(i) > 0.) then
            if(powerSwitch) then
               intensityDuration(i) = id_index_factor * intensity(i) /&
               (powerCoeff * (duration(i) ** (powerExp)))
            else if(polySwitch) then
               x = duration(i)
               intensityDuration(i) = id_index_factor * intensity(i) / ( polynomArr(1) + x * &
               (polynomArr(2) + x * (polynomArr(3) + x * (polynomArr(4) +&
               x * (polynomArr(5) + polynomArr(6) * x)))))
            else if (interSwitch) then
               x = duration(i)
               do j = 1,intervals
                  if(xVals(j) < x .and. x < xVals(j+1)) then
               		  m = (yVals(j+1) - yVals(j)) / (xVals(j+1) - xVals(j))
               		  b = yVals(j) - m * xVals(j)
               		  intensityDuration(i) = id_index_factor * intensity(i) / (m * x + b)
                  end if
               end do
            end if
            
            if(intensityDuration(i) > 1.d0) then
               ctrid = ctrid + 1 ! count exceedences of I-D threshhold
               ptid(ctrid) = i
               if(AWI(i) >= AWIThresh) then
                  AWIIntensCtr = AWIIntensCtr + 1 ! count exceedences of antecedent water index threshold
                  ptawid(AWIIntensCtr) = i
               end if
            end if
            
            threshAvgExceed(i) = runIntensity(i)
            if(threshAvgExceed(i) > runningIntens) then
               ctria = ctria + 1 ! count exceedences of running average Intensity threshhold
               if(ctria > nlo20) write(*,*) 'Error! ctria > nlo20'
               ptia(ctria) = i
            end if
            
         end if  
      end do
   end subroutine track_intensity
   ! END OF SUBROUTINE}}}
	
   ! Purpose: count events of continuous exceedence of thresholds
   	subroutine count_events(event,counter,event_pointer,rph,minTStormGap)!{{{
   	implicit none
   	
   	! FORMAL ARGUMENTS
           real, intent(in)  :: minTStormGap
           integer, intent(in)  :: rph, event_pointer(*)
           integer, intent(out) :: event, counter
        ! LOCAL VARIABLES
           integer :: i, exceeded, StormGapMinCounts

   !------------------
   	   event = 1
   	   do i = 2, counter
   	      exceeded = event_pointer(i) - event_pointer(i-1)
              StormGapMinCounts=ceiling(minTStormGap*float(rph))
   	      if( exceeded > StormGapMinCounts) then
   	         event = event + 1
   	      end if
   	   end do
   	end subroutine count_events
   ! END OF SUBROUTINE}}}
   	   
   ! PURPOSE: 
   ! 	     Check completeness of data relevant to the seasonal antecedent 
   !	     threshold
        logical function check_SAT(resetMonth,resetDay,threshold)!{{{
        implicit none
        
           ! FORMAL ARGUMENTS
           integer :: resetMonth, resetDay
           real    :: threshold
           
   !------------------
           if (resetDay <= 0) then
              check_SAT = .false.
              return
           else if (resetMonth <= 0) then
              check_SAT = .false.
              return
           else if (threshold <= 0) then
              check_SAT = .false.
              return
           end if
           check_SAT = .true.
           return
        end function
   ! END OF FUNCTION}}}
   
   ! PURPOSE:
   ! 	     Check completeness of data relevant to the AWI
        logical function check_AWI(threshold, fieldCap, drainConst, evapConst)!{{{
        implicit none
         
           ! FORMAL ARUGUMENTS
           real :: threshold, fieldCap, drainConst, evapConst(12)

           ! LOCAL VARIABLES
           integer :: i
   !------------------
   	   
           if (threshold <= 0) then
              check_AWI = .false.
              return
           else if (fieldCap <= 0) then
              check_AWI = .false.
              return
           else if (drainConst <= 0) then
              check_AWI = .false.
              return
           end if

           do i = 1, 12
              if(evapConst(i) < 0) then
                 check_AWI = .false.
                 return
              end if
           end do
           check_AWI = .true.
           return
        end function
   ! END OF FUNCTION}}}

   ! PURPOSE:
   !		 Ensures that multiple *Switch flags aren't enabled
   	  subroutine check_switches(uout,powerSwitch,polySwitch,interSwitch) !{{{
   	  implicit none
   	  
   	  !FORMAL ARGUMENTS
   	  integer, intent(in) :: uout
   	  logical, intent(in) :: powerSwitch, polySwitch, interSwitch
   	  !--------------------------
   	  	   if( .not. powerSwitch .and. .not. polySwitch .and. .not. interSwitch) then !{{{
   	  	      write(uout,*) "There is no intensity-duration threshold defined."
	      	   write(uout,*) "Edit thresh_in.txt and change one ID flag to '.TRUE.'"
	      	   write(*,*) "There is no intensity-duration threshold defined."
	      	   write(*,*) "Edit thresh_in.txt and change one ID flag to '.TRUE.'"
	      	   write(*,*) 'Press Enter key to exit program.'
	      	   read(*,*)
	      	   stop	  
   	  	   end if !}}}
   	      if(powerSwitch .and. polySwitch .and. interSwitch) then !{{{
	   		     write(*,*) "All three Intensity-Duration flags are &
	   		     &set to define the ID function."
	   		     write(*,*) "Edit thresh_in.txt and ensure that only one &
	   		     &ID flag is set to .TRUE."
	   		     write(uout,*) "All three Intensity-Duration flags are &
	   		     &set to define the ID function."
	   		     write(uout,*) "Edit thresh_in.txt and ensure that only one &
	   		     &ID flag is set to .TRUE."
	   		     write(*,*) 'Press Enter key to exit program.'
	   		     read(*,*)
	   		     stop !}}}
	   	   else if(powerSwitch .and. polySwitch) then !{{{
	   		     write(*,*) "Power law and polynomial interpolation"
	   		     write(*,*) "Intensity-Duration flags are both set to"
	   		     write(*,*) "define the ID function."
	   		     write(*,*)
	   		     write(*,*) "Edit thresh_in.txt and ensure that only one"
	   		     write(*,*) "ID flag is set to .TRUE."
	   		     write(*,*)
	   		     write(uout,*) "Power law and polynomial interpolation &
	   		     				 	 &Intensity-Duration flags are both &
	   		     				 	 &set to define the ID function."
	   		     write(uout,*) "Edit thresh_in.txt and ensure that only one &
	   		     					 &ID flag is set to .TRUE."
	   		     write(*,*) 'Press Enter key to exit program.'
	   		     read(*,*)
	   		     stop !}}}
	         else if(powerSwitch .and. interSwitch) then !{{{
	      	     write(*,*) "Power law and linear interpolation"
	      	     write(*,*) "Intensity-Duration flags are both set to"
	      	     write(*,*) "define the ID function."
	      	     write(*,*)
	   		     write(*,*) "Edit thresh_in.txt and ensure that only one"
	   		     write(*,*) "ID flag is set to .TRUE."
	   		     write(*,*)
	   		     write(uout,*) "Power law and linear interpolation &
	      	     				 	 &Intensity-Duration flags are both &
	      	     				 	 &set to define the ID function."
	   		     write(uout,*) "Edit thresh_in.txt and ensure that only one &
	   		     					 &ID flag is set to .TRUE."
	   		     write(*,*) 'Press Enter key to exit program.'
	   		     read(*,*)
	   		     stop  !}}}
	         else if (polySwitch .and. interSwitch) then !{{{
	              write(*,*) "Polynomial interpolation and linear interpolation"
	              write(*,*) "Intensity-Duration flags are both set to"
	              write(*,*) "define the ID function."
	              write(*,*)
	   		     write(*,*) "Edit thresh_in.txt and ensure that only one"
	   		     write(*,*) "ID flag is set to .TRUE."
	   		     write(*,*)
	   		     write(uout,*) "Polynomial interpolation and linear interpolation &
	              				 	 &Intensity-Duration flags are both&
	              				 	 &set to define the ID function."
	   		     write(uout,*) "Edit thresh_in.txt and ensure that only one &
	   		     					 &ID flag is set to .TRUE."
	   		     write(*,*) 'Press Enter key to exit program.'
	   		     read(*,*)
	   		     stop !}}}
	   	   end if
   	  end subroutine check_switches !}}}
   
   ! PURPOSE:
   		    !Ensures resetAntMonth and resetAntDay have meaningful values
   	  subroutine check_antMonth_antDay(uout,year,resetAntMonth,resetAntDay) !{{{
   	  implicit none
   	  
   	     !FORMAL ARGUMENTS
   	     integer, intent(in) :: uout, year, resetAntMonth, resetAntDay
   	     !-----------------------------------
   	     if(resetAntMonth > 12) then
	   		  call error2(uout,"Reset_antecedent_month_&_day","month",12,0)
	   	  end if
	   	  if(resetAntMonth == 1 .or. &
	   		  resetAntMonth == 3 .or. &
	   		  resetAntMonth == 5 .or. &
	   		  resetAntMonth == 7 .or. &
	   		  resetAntMonth == 8 .or. &
	   		  resetAntMonth == 10 .or. &
	   		  resetAntMonth == 12) then
	   			  if(resetAntDay > 31 ) then 
	   			     call error2(uout,"Reset_antecedent_month_&_day","day",31,resetAntMonth)
	   			  end if
	   	  else if (resetAntMonth == 4 .or. &
	   				  resetAntMonth == 6 .or. &
	   				  resetAntMonth == 9 .or. &
	   				  resetAntMonth == 11) then
	   				     if(resetAntDay > 30) then
	   				        call error2(uout,"Reset_antecedent_month_&_day","day",30,resetAntMonth)
	   				     end if
	   	  else if (resetAntMonth == 2) then
	   	     if(((mod(year,4) == 0 .and. mod(year,100) /= 0) .or. mod(year,400) == 0)&
	   			  .and. resetAntDay > 29) then
	   			  call error2(uout,"Reset_antecedent_month_&_day","day",29,resetAntMonth)
	   		  else if(resetAntDay > 28) then
	   			  call error2(uout,"Reset_antecedent_month_&_day","day",28,resetAntMonth)		
	   		  end if
	   	  end if
	     end subroutine check_antMonth_antDay !}}}
   	  
   ! PURPOSE:
   !			 Adjusts values of limits when powerSwitch is set to true
   	  subroutine set_power_limits(uout,lowLim,upLim) !{{{
   	  implicit none
   	  
   	  ! FORMAL ARGUMENTS
   	  real, intent(inout) :: lowLim, upLim
   	  integer, intent(in) :: uout
   	  !----------------------------------
   	  			 
   	  !If lower bound is greater than upper bound, end program, write to log
	        	if(upLim < lowLim .and. upLim /= 0) then
	            write(*,*) "The lower limit on the duration interval is greater than the upper"
	            write(*,*) "limit. Adjust values in thresh_in.txt and restart thresh."
	            write(*,*) 'Press Enter key to exit program.'
	            read(*,*)
	            write(uout,*)"The lower limit on the duration interval is greater than the upper"
	            write(uout,*)"limit. Adjust values in thresh_in.txt and restart thresh."
	            write(*,*) "Thresh exited due to this error."
	            stop
	         else !Checking to see if values should be set to +,- infinity		  
			      if(lowLim == 0 .and. upLim == 0) then
				      lowLim = 0-huge(lowLim)
			      end if
			      if(upLim == 0) then
				      upLim = huge(upLim)
			      end if
			   end if
			   !Widening bounds slightly for power law
	      	if(lowLim /= -huge(lowLim)) then
	            lowLim = floor(0.85 * (upLim - lowLim))
	         end if
	         if(upLim /= huge(upLim)) then
	            upLim = ceiling(1.15 * (upLim - lowLim))
	         end if
   	  end subroutine set_power_limits !}}}
   	  
   !PURPOSE:
   !			Adjusts values of limits when polySwitch is set to true
   	  subroutine set_poly_limits(uout,lowLim,upLim) !{{{
   	  implicit none
   	  
   	  !FORMAL ARGUMENTS
   	  real, intent(inout) :: lowLim, upLim
   	  integer, intent(in) :: uout
   	  !----------------------------
   	  			 
   	  !if lower bound is greater than upper bound, end program, write to log
   	     if(upLim < lowLim) then
   	        write(*,*) "The lower limit on the duration interval is greater than the upper"
   	        write(*,*) "limit. Adjust values in thresh_in.txt and restart thresh."
   	        write(*,*) 'Press Enter key to exit program.'
   	        read(*,*)
   	        write(uout,*) "The lower limit on the duration interval is greater than the upper"
   	        write(uout,*) "limit. Adjust values in thresh_in.txt and restart thresh."
   	        write(uout,*) "Thresh exited due to this error."
   	        stop
   	     end if
   	  end subroutine set_poly_limits !}}}
   ! PURPOSE:
   		    !Condenses code in getinfo.f90, this is a standard error
   		    !message that will print and exit thresh from within.
   		    !Used primarily when a value from thresh_in.txt is different from
   		    !what the program expects.
   	  subroutine error1(uout,var,val) !{{{
   	  implicit none
   	     !FORMAL ARGUMENTS
   	     integer, intent(in) :: uout
   	     character(*), intent(in) :: var, val
   	     !------------------------------------------
   	      write(uout,*) var,' must be greater than ',val,'.'
   			write(uout,*) 'Thresh exited due to an incompatible value.'
   			write(*,*) var,' must be greater than ',val,'.'
   			write(*,*) 'Edit thresh_in.txt and restart thresh.'
   			write(*,*) 'Press Enter key to exit program.'
   			read(*,*)
   			stop
   	     
   	  end subroutine error1!}}}
   
   ! PURPOSE:
   		  	 !Condenses code in getinfo.f90, this is a standard error
   		  	 !message that will print and exit thresh from within.
   		  	 !Used specifically for resetAntMonth and resetAntDay errors.
   	  subroutine error2(uout,var1,var2,val1,val2) !{{{
   	  implicit none
   	  
   	  !FORMAL ARGUMENTS
   	  integer, intent(in)   :: uout, val1, val2
   	  character(*), intent(in) :: var1, var2
   	  !-------------------------------------
   	  	 
   	  	  write(uout,"(A,A,A,A,I2)") var1, " has a ",var2," value that is greater than ",val1,"."
   	  	  if(var2 == "day") then 
   	  	     write(uout,*) "The reset month, ", val2, ", only has ", val1," days." 
   	  	  end if
	   	  write(uout,*) "Thresh exited due to this error."
	   	  write(uout,*) "Edit thresh_in.txt and ensure the value of the ,",var2 &
	   	  ,"is less than",val1 + 1,"."
	   	  
	   	  write(*,*) var1," has a ",var2," value that is greater than ",val1,"."
	   	  if(var2 == "day") then 
   	  	     write(*,*) "The reset month, ", val2, ", only has ", val1," days." 
   	  	  end if
	   	  write(*,*) "Edit thresh_in.txt and ensure the value of the reset day &
	   	  &is less than", val1 + 1,"."
	   	  write(*,*) 'Press Enter key to exit program.'
	   	  read(*,*)
	   	  stop
   	  end subroutine error2 !}}}
   ! PURPOSE:
   		    !Condenses code in getinfo.f90, this is a standard error
   		    !message that will print and exit thresh from within.
   		    !Used primarily when a value from thresh_in.txt is different from
   		    !what the program expects.
   	  subroutine error3(uout,var) !{{{
   	  implicit none
   	     !FORMAL ARGUMENTS
   	     integer, intent(in) :: uout
   	     character(*), intent(in) :: var
   	     !------------------------------------------
   	      write(uout,*) var,' must be an integer.'
   			write(uout,*) 'Thresh exited due to an incompatible value.'
   			write(*,*) var,' must be an integer.'
   			write(*,*) 'Edit thresh_in.txt and restart thresh.'
   			write(*,*) 'Press Enter key to exit program.'
   			read(*,*)
   			stop
   	     
   	  end subroutine error3!}}}
end module 
