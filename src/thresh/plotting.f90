! plotting module contains the subroutines dgrs, gnp1, and gnp2. These subroutines
! are used in plotting the data analyzed in the program thresh.

module plotting
implicit none

contains
    ! PURPOSE:
    !	  Writes a file listing most recent conditons at all stations for 
    !   plotting by interactive graphing programs,"dgrs" using separate symbols for each.
	subroutine dgrs(numStations,outputFolder,ulog,dgOutputfile,&
	 &unitNumber,stationNumber,sumAnteced,sumRecent,Trecent,precipUnit)
	implicit none
	
    ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*),precipUnit*(*)
	   character, intent(in)    :: dgOutputfile*(*)
	   character(*), intent(in) :: stationNumber(numStations)
	   real, intent(in)         :: sumAnteced(numStations),sumRecent(numStations)
	   integer, intent(in)      :: numStations,unitNumber,ulog,Trecent
	
    ! LOCAL VARIABLES
	   character           :: pd = char(35), tb = char(9)
	   character (len=255) :: outputFile
	   integer             :: i
	
    !------------------------------	
  	   outputFile=trim(outputFolder)//trim(dgOutputfile)
  	   open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
  	   write(unitNumber,*)& 
     	     (tb,'Recent Conditons at Station',trim(stationNumber(i)),&
     	     tb,Trecent,'-h Precip. at Station (',precipUnit,') ',trim(stationNumber(i)), i=1,numStations)
 	   write(unitNumber,'(100(a1,f7.2,a1,f7.2):)')(tb,sumAnteced(i),tb,sumRecent(i), i=1,numStations)
 	   close(unitNumber)	
	   return
	
    ! SAVES ERROR MESSAGE TO LOG FILE
           125	write(ulog,*) 'Error opening file ',trim(outputFile),'.'	
                write(ulog,*) 'Thresh exited due to this error.'
                close (ulog)
                stop
	end subroutine dgrs
! END OF SUBROUTINE
	
   ! PURPOSE:
   ! 	  Writes a tab-delimited file listing most recent conditons at all
   !	  stations, "gnp1" this is the default format if none of the 
   !	  others are selected
	subroutine gnp1(numStations,outputFolder,ulog,defaultOutputFile,&
	unitNumber,time,date,stationNumber,sumAnteced,sumRecent,intensity,durs,&
	runningIntens,in2mm,Tintensity,TavgIntensity,precipUnit)
	implicit none

   ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*),precipUnit
	   character, intent(in)    :: defaultOutputFile*(*), time*(*), date*(*)
	   character(*), intent(in) :: stationNumber(numStations)
	   real, intent(in)         :: sumAnteced(numStations), durs(numStations)
	   real, intent(in)          :: runningIntens(numStations)
	   real, intent(in)         :: sumRecent(numStations)
	   real, intent(in)         :: intensity(numStations), in2mm
	   real, intent(in)         :: Tintensity, TavgIntensity
	   integer, intent(in)      :: numStations, unitNumber
	   integer, intent(in)      :: ulog 
	
    ! LOCAL VARIABLES
	   character :: pd = char(35), tb = char(9)
	   integer   :: i
	   real      :: logintensity,logRunIntensity
	   character (len=255) :: outputFile
	   character (len=8)   :: TavgIntensityF,TintensityF ! Formatted duration 
	
    !------------------------------	
    ! Store the output file's location in outputFile
  	   outputFile=trim(outputFolder)//trim(defaultOutputFile)
  	
    ! Open outputFile and write its data
  	   open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
	   write (unitNumber,*) pd,time,' ',date
    !------------------------------	
           write(TavgIntensityF,'(F8.3)') TavgIntensity
           TavgIntensityF=adjustl(TavgIntensityF)
	   if (Tintensity>0.) then
	     write(TintensityF,'(F8.3)') Tintensity
	     TintensityF=adjustl(TintensityF)
	     write (unitNumber,*) pd,tb,'Rain Gage',tb,'Antecedent',tb,'Recent',tb,'(',&
	     trim(TintensityF),'-h Intensity) (',precipUnit,')',tb,'Log10(',trim(TintensityF),'-h Intensity) (',precipUnit,')',tb,&
	     'Duration (h)',tb,trim(TavgIntensityF),'-h Running Ave. Intensity (',precipUnit,')',&
	     tb,'Log10 (',trim(TavgIntensityF),'-h Intensity) (',precipUnit,')'
	   else
	     write (unitNumber,*) pd,tb,'Rain Gage',tb,'Antecedent',tb,&
	     'Recent',tb,'Average Intensity (',precipUnit,')',tb,'Log10 Average Intensity (',precipUnit,')',&
	     tb,'Duration (h)',tb,trim(TavgIntensityF),&
	     '-h Intensity (',precipUnit,')',tb,'Log10 (',trim(TavgIntensityF),'-h Intensity) (',precipUnit,')'
	   end if
     
	   do i=1,numStations
     	     logintensity = 0.; logRunIntensity = 0.
	     if (intensity(i)>0.) logintensity = log10(intensity(i))
	     if (runningIntens(i)>0.) logRunIntensity = log10(runningIntens(i))
	     write(unitNumber,'(a1,a8,a1,f7.2,a1,f7.2,a1,f7.3,a1,f7.3,a1,f8.2,&
	     &a1,f7.3,a1,f7.3)')tb,trim(stationNumber(i)),tb,sumAnteced(i),tb,&
	     &sumRecent(i),tb,intensity(i),tb,logintensity,tb,durs(i),tb,&
	     &runningIntens(i),tb,logRunIntensity
	   end do
  	   close(unitNumber)
	   write(*,*) 'Finished gnp1 plot file'
	   return
	
    ! SAVES ERROR MESSAGE TO LOG FILE
           125	write(ulog,*) 'Error opening file ',trim(outputFile)
           	close (ulog)
           	stop
	end subroutine gnp1
! END OF SUBROUTINE
	
    ! PURPOSE:
    !
    !	
	subroutine gnp2(numStations,outputFolder,ulog,unitNumber,&
	time,date,stationNumber,sumAntecedent,sumRecent,intensity,durs,runningIntens,&
	in2mm,Tintensity,TavgIntensity,Tantecedent,Trecent,precipUnit)
	implicit none
	
    ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*),precipUnit*(*)
	   character, intent(in)    :: time*(*),date*(*)
	   character(*), intent(in) :: stationNumber(numStations)
	   real, intent(in)         :: sumAntecedent(numStations),in2mm,Tintensity,TavgIntensity
	   real, intent(in)         :: sumRecent(numStations),runningIntens(numStations)
	   real, intent(in)         :: intensity(numStations),durs(numStations)
	   integer, intent(in)      :: numStations,unitNumber,ulog
 	   integer, intent(in)      :: Tantecedent,Trecent
	
	
    ! LOCAL VARIABLES
	   character           :: pd = char(35), tb = char(9)
	   character (len=255) :: outputFile
	   character (len=8)   :: TavgIntensityF,TintensityF ! Formatted duration
	   real                :: logintensity,logRunIntensity
	   integer             :: i

    !------------------------------	
     write(TavgIntensityF,'(F8.3)') TavgIntensity
     TavgIntensityF=adjustl(TavgIntensityF)
    ! save each station in a separate tab-delimited file for plotting by gnuplot, "gnp2"
 	   do i=1,numStations
    ! Create an output file for each station
  	     outputFile=trim(outputFolder)//'ThSta'//trim(stationNumber(i))//'.txt'
  	     open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
 	     write (unitNumber,*) pd,time,' ',date
 	  
 	     if(Tintensity>0) then
	       write(TintensityF,'(F8.3)') TintensityF
	       TintensityF=adjustl(TintensityF)
 	       write (unitNumber,*) pd,tb,' Station',tb,&
 	       Tantecedent,'-h Previous Total',tb,Trecent,'-h Total',tb,&
 	       '(',trim(TintensityF),'-h Intensity) (',precipUnit,')',tb,&
 	       'log10(',trim(TintensityF),'-h Intensity) (',precipUnit,')',tb,'Duration (h)',tb,&
 	       trim(TavgIntensityF),'-h Running Ave. Intensity (',precipUnit,')',tb,&
 	       'Log10 (',trim(TavgIntensityF),'-h Running Ave. Intensity) (',precipUnit,')'
 	     else
 	       write (unitNumber,*) pd,tb,' Station',tb,&
 	       Tantecedent,'-h Previous Total',tb,Trecent,'-h Total',tb,&
 	       'Average Intensity (',precipUnit,')',tb,'Log10 Average Intensity (',precipUnit,')',tb,&
	       'Duration (h)',tb,trim(TavgIntensityF),'-h Running Ave. Intensity (',precipUnit,')',&
	       tb,'Log10 Running Ave. Intensity (',precipUnit,')'
 	     end if
 	  
    	     logintensity = 0.; logRunIntensity = 0.
	     if (intensity(i)>0.) logintensity = log10(intensity(i))
	     if (runningIntens(i)>0.) logRunIntensity = log10(runningIntens(i))
	  
 	     write(unitNumber,'(a1,a8,a1,f7.2,a1,f7.2,a1,f7.3,a1,f7.3,a1,f8.2,&
	       &a1,f7.3,a1,f7.3)')tb,trim(stationNumber(i)),tb,&
	       sumAntecedent(i),tb,sumRecent(i),tb,intensity(i),tb,&
	       logintensity,tb,durs(i),tb,runningIntens(i),tb,logRunIntensity
  	     close(unitNumber)
	   end do
	
	   write(*,*) 'Finished gnp2 plot files'
	   return
	
    ! SAVES ERROR MESSAGE TO LOG FILE
           125	write(ulog,*) 'Error opening file ',trim(outputFile)
           	close (ulog)
           	stop
	end subroutine gnp2
! END OF SUBROUTINE
end module
