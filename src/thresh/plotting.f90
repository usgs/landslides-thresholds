! plotting module contains the subroutines dgrs, gnp1, and gnp2. These subroutines
! are used in plotting the data analyzed in the program thresh.

module plotting
implicit none

contains
    ! PURPOSE:
    !	  Writes a file listing most recent conditons at all stations for 
    !   plotting by DeltaGraph 4,"dgrs" using separate symbols for each.
	subroutine dgrs(numStations,outputFolder,ulog,&
	 &dgOutputfile,unitNumber,stationNumber,sumAnteced,sumRecent,Trecent)
	implicit none
	
    ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*)
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
     	     tb,Trecent,'-hr Precip. at Station',trim(stationNumber(i)), i=1,numStations)
 	   write(unitNumber,'(100(a1,f7.2,a1,f7.2):)')(tb,sumAnteced(i),tb,sumRecent(i), i=1,numStations)
 	   close(unitNumber)	
	   return
	
    ! DISPLAYS ERROR MESSAGE
           125	write(*,*) 'Error opening file ',outputFile	
                write(*,*) 'Press Enter key to exit program.'
                read(*,*)
                write(ulog,*) 'Error opening file ',outputFile	,'.'	
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
	runningIntens,in2mm,Tintensity,TavgIntensity)
	implicit none

   ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*)
	   character, intent(in)    :: defaultOutputFile*(*), time*(*), date*(*)
	   character(*), intent(in) :: stationNumber(numStations)
	   real, intent(in)         :: sumAnteced(numStations), durs(numStations)
	   real, intent(in)          :: runningIntens(numStations)
	   real, intent(in)         :: sumRecent(numStations)
	   real, intent(in)         :: intensity(numStations), in2mm
	   integer, intent(in)      :: numStations, unitNumber
	   integer, intent(in)      :: ulog, Tintensity, TavgIntensity
	
    ! LOCAL VARIABLES
	   character :: pd = char(35), tb = char(9)
	   integer   :: i
	   real      :: logintensity,mmIntensity,avgmmIntensity
	   character (len=255) :: outputFile
	
    !------------------------------	
    ! Store the output file's location in outputFile
  	   outputFile=trim(outputFolder)//trim(defaultOutputFile)
  	
    ! Open outputFile and write its data
  	   open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
	   write (unitNumber,*) pd,time,' ',date
	   if (Tintensity>0) then
	     write (unitNumber,*) pd,tb,'Rain gauge',tb,'Antecedent',tb,'Recent',tb,&
	     Tintensity,'-hr Intensity (in)',tb,Tintensity,'-hr Intensity (mm)',tb,&
	     'Duration (hrs)',tb,TavgIntensity,'-hr Running Ave. Intensity (in)',&
	     tb,'Log10 ',Tintensity,'-hr Intensity (mm)'
	   else
	     write (unitNumber,*) pd,tb,'Rain gauge',tb,'Antecedent',tb,&
	     'Recent',tb,'Average Intensity (in)',tb,'Average Intensity (mm)',&
	     tb,'Duration (hrs)',tb,TavgIntensity,&
	     '-hr Running Ave. Intensity (in)',tb,'Log10 Average Intensity (mm)'
	   end if
     
	   do i=1,numStations
	     if (intensity(i)*in2mm<1.d0) then
     	       logintensity = 0.
	     else 
     	       logintensity = log10(intensity(i)*in2mm)
	     end if
	     if (intensity(i)<0.) then
	       mmIntensity = intensity(i)
	     else
	       mmIntensity = intensity(i)*in2mm
	     end if
	     if (runningIntens(i)<0.) then
	       avgmmIntensity = runningIntens(i)
	     else
	       avgmmIntensity = runningIntens(i) !*in2mm
	     end if
	     write(unitNumber,'(a1,a8,a1,f7.2,a1,f7.2,a1,f7.3,a1,f7.3,a1,f7.1,&
	     &a1,f7.3,a1,f7.3)')tb,trim(stationNumber(i)),tb,sumAnteced(i),tb,&
	     &sumRecent(i),tb,intensity(i),tb,mmIntensity,tb,durs(i),tb,&
	     &avgmmIntensity,tb,logintensity
	   end do
  	   close(unitNumber)
	   write(*,*) 'Finished gnp1 plot file'
	   return
	
    ! DISPLAYS ERROR MESSAGE
           125	write(*,*) 'Error opening file ',outputFile	
           	write(*,*) 'Press Enter key to exit program.'
           	read(*,*)
           	write(ulog,*) 'Error opening file ',outputFile		
           	close (ulog)
           	stop
	end subroutine gnp1
! END OF SUBROUTINE
	
    ! PURPOSE:
    !
    !	
	subroutine gnp2(numStations,outputFolder,ulog,unitNumber,&
	time,date,stationNumber,sumAntecedent,sumRecent,intensity,durs,runningIntens,&
	in2mm,Tintensity,TavgIntensity,Tantecedent,Trecent)
	implicit none
	
    ! FORMAL ARGUMENTS
	   character, intent(in)    :: outputFolder*(*)
	   character, intent(in)    :: time*(*),date*(*)
	   character(*), intent(in) :: stationNumber(numStations)
	   real, intent(in)         :: sumAntecedent(numStations),in2mm
	   real, intent(in)         :: sumRecent(numStations),runningIntens(numStations)
	   real, intent(in)         :: intensity(numStations),durs(numStations)
	   integer, intent(in)      :: numStations,unitNumber,ulog,Tintensity,TavgIntensity
 	   integer, intent(in)      :: Tantecedent,Trecent
	
	
    ! LOCAL VARIABLES
	   character           :: pd = char(35), tb = char(9)
	   character (len=255) :: outputFile
	   real                :: logintensity,mmIntensity,avgmmIntensity
	   integer             :: i

    !------------------------------	
    ! save each station in a separate tab-delimited file for plotting by gnuplot, "gnp2"
 	   do i=1,numStations
    ! Create an output file for each station
  	     outputFile=trim(outputFolder)//'ThSta'//trim(stationNumber(i))//'.txt'
  	     open(unitNumber,file=outputFile,status='unknown',position='rewind',err=125)
 	     write (unitNumber,*) pd,time,' ',date
 	  
 	     if(Tintensity>0) then
 	       write (unitNumber,*) pd,tb,' Station',tb,&
 	       Tantecedent,'-hr Previous Total',tb,Trecent,'-hr Total',tb,&
 	       Tintensity,'-hr Intensity (in)',tb,&
 	       Tintensity,'-hr Intensity (mm)',tb,'Duration (hrs)',tb,&
 	       TavgIntensity,'-hr Running Ave. Intensity (in)',tb,&
 	       'Log10 ',Tintensity,'-hr Intensity (mm)'
 	     else
 	       write (unitNumber,*) pd,tb,' Station',tb,&
 	       Tantecedent,'-hr Previous Total',tb,Trecent,'-hr Total',tb,&
 	       'Average Intensity (in)',tb,'Average Intensity (mm)',tb,&
	       'Duration (hrs)',tb,TavgIntensity,'-hr Running Ave. Intensity (in)',&
	       tb,'Log10 Average Intensity (mm)'
 	     end if
 	  
	     if(intensity(i)*in2mm<1.d0) then
           logintensity=0.
	     else 
     	     logintensity=log10(intensity(i)*in2mm)
	     end if
	  
	     if(intensity(i)<0.) then
	        mmIntensity=intensity(i)
	     else
	        mmIntensity=intensity(i)*in2mm
	     end if
	  
	     if(runningIntens(i)<0.) then
	        avgmmIntensity=runningIntens(i)
	     else
	        avgmmIntensity=runningIntens(i) !*in2mm
	     end if
	  
 	     write(unitNumber,'(a1,a8,a1,f7.2,a1,f7.2,a1,f7.3,a1,f7.3,a1,f7.1,&
	       &a1,f7.3,a1,f7.3)')tb,trim(stationNumber(i)),tb,&
	       sumAntecedent(i),tb,sumRecent(i),tb,intensity(i),tb,&
	       mmIntensity,tb,durs(i),tb,avgmmIntensity,tb,logintensity
  	     close(unitNumber)
	   end do
	
	   write(*,*) 'Finished gnp2 plot files'
	   return
	
    ! DISPLAYS ERROR MESSAGE
           125	write(*,*) 'Error opening file ',outputFile	
           	write(*,*) 'Press Enter key to exit program.'
           	read(*,*)
           	write(ulog,*) 'Error opening file ',outputFile		
           	close (ulog)
           	stop
	end subroutine gnp2
! END OF SUBROUTINE
end module
