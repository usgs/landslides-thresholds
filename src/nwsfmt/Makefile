# Simple instructions for building the program "nwsfmt" using GCC and Gfortran and 
#  then copying it to the directory "bin"

MKDIR = mkdir -p 
RMDIR = rm -rf 
COPY = cp
OBJDIR = ./obj
EXEDIR = ../../bin

NFT = nwsfmt

SRCN90 = nwsfmt.f90 s1904t.f90
OBJN90 = nwsfmt.o s1904t.o

LIBS =

CC = gcc -O3
CCFLAGS = -lm
FC = gfortran -w -O3 
FFLAGS =
F90 = gfortran -w -O3
L90 = gfortran -o
F90FLAGS = -fbounds-check -fimplicit-none -c 
LDFLAGS =

all: $(NFT) $(EXEDIR)/$(NFT)
#-----------------------------------------------------------------

$(NFT): $(OBJN90)  
	$(L90) $@ $(OBJN90) $(LIBS)
	
$(EXEDIR)/$(NFT): $(EXEDIR) $(NFT)
	$(COPY) $(NFT) $(EXEDIR)

$(OBJN90): $(SRCN90)
	$(F90) $(F90FLAGS) $(SRCN90)
 
$(OBJDIR):
	$(MKDIR) $(OBJDIR)
	
$(EXEDIR):
	$(MKDIR) $(EXEDIR)

#-----------------------------------------------------------------
clean:
#	$(RMDIR) "$(OBJDIR)"
	rm -f $(NFT) 
	rm -rf $(OBJN90) 
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

