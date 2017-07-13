! imid extracts a substring that is imbedded within a character string
! By Rex L. Baum, USGS, 2 Nov 2001
	
    integer function imid(string,start,ending)
       implicit none
! FORMAL ARGUMENTS 
       integer, intent(in) 	 :: start, ending
       character*(*), intent(in) :: string

!------------------------------	
       read(string(start:ending),*) imid
       return
    end
