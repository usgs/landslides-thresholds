# Simple instructions for building the program "tsthresh" using GCC and Gfortran and 
#  then copying it to the directory "bin"

MKDIR = mkdir -p 
RMDIR = rm -rf 
COPY = cp
OBJDIR = ./obj
EXEDIR = ../../bin

TST = tsthresh

SRCR90 = tsthresh.f95 
OBJR90 = tsthresh.o 

LIBS =

CC = gcc -O3
CCFLAGS = -lm
FC = gfortran -w -O3 
FFLAGS =
F95 = gfortran -w -O3
L95 = gfortran -o
F95FLAGS = -fbounds-check -fimplicit-none -c 
LDFLAGS =

all: $(TST) $(EXEDIR)/$(TST)
#-----------------------------------------------------------------

$(TST): $(OBJR90)  
	$(L95) $@ $(OBJR90) $(LIBS)
	
$(EXEDIR)/$(TST): $(EXEDIR) $(TST)
	$(COPY) $(TST) $(EXEDIR)

$(OBJR90): $(SRCR90)
	$(F95) $(F95FLAGS) $(SRCR90)
 
$(OBJDIR):
	$(MKDIR) $(OBJDIR)
	
$(EXEDIR):
	$(MKDIR) $(EXEDIR)

#-----------------------------------------------------------------
clean:
#	$(RMDIR) "$(OBJDIR)"
	rm -f $(TST) 
	rm -rf $(OBJR90) 
	rm -rf *.mod *.exe *.stackdump

.SUFFIXES: $(SUFFIXES) .o .f .c .f95

.o.o:
	$(F95) $(F95FLAGS) -c $<

.f.o:
	$(F95) $(F95FLAGS) -c $<

.c.o:
	$(CC) $(CCINCLUDE) -c -w $<

.f95.o:
	$(F95) $(F95FLAGS) -c $<

