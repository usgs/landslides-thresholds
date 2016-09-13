# Simple instructions for building the program "thresh" using GCC and Gfortran
#  and then copying it to the directory "bin"

MKDIR = mkdir -p 
RMDIR = rm -rf 
COPY = cp
OBJDIR = ./obj
EXEDIR = ../../bin


THR = thresh

SRCT90 = alert.f90 alerthtm.f90 arcsav.f90 dataanalysis.f90 getinfo.f90 gnpts.f90 gnpts1.f90 ihr24.f90 imid.f90 plotting.f90 s1904t.f90 tabl.f90 tablhtm.f90 thresh.f90 tindm.f90 titl.f90
OBJT90 = alert.o alerthtm.o arcsav.o dataanalysis.o getinfo.o gnpts.o gnpts1.o ihr24.o imid.o plotting.o s1904t.o tabl.o tablhtm.o thresh.o tindm.o titl.o


LIBS =

CC = gcc -O3
CCFLAGS = -lm
FC = gfortran -w -O3 
FFLAGS =
F90 = gfortran -w -O3
L90 = gfortran -o
F90FLAGS = -fbounds-check -fimplicit-none -c 
LDFLAGS =

all: $(THR) $(EXEDIR)/$(THR)
#-----------------------------------------------------------------

$(THR): $(OBJT90)  
	$(L90) $@ $(OBJT90) $(LIBS)
	
$(EXEDIR)/$(THR): $(EXEDIR) $(THR)
	$(COPY) $(THR) $(EXEDIR)

$(OBJT90): $(SRCT90)
	$(F90) $(F90FLAGS) $(SRCT90)
 
$(OBJDIR):
	$(MKDIR) $(OBJDIR)
	
$(EXEDIR):
	$(MKDIR) $(EXEDIR)

#-----------------------------------------------------------------
clean:
#	$(RMDIR) "$(OBJDIR)"
	rm -f $(THR) 
	rm -rf $(OBJT90) 
	rm -rf *.mod *.exe *.stackdump

.SUFFIXES: $(SUFFIXES) .o .f .c .f95

.o.o:
	$(F90) $(F90FLAGS) -c $<

.f.o:
	$(F90) $(F90FLAGS) -c $<

.c.o:
	$(CC) $(CCINCLUDE) -c -w $<

.f95.o:
	$(F90) $(F90FLAGS) -c $<

