Readme!
=======

Shell Scripts
-------------

The shell scripts in this folder are configured for a Linux system.  Minor changes may be needed depending on the details of your installation.  The scripts should also work on Mac OSX with minor changes as suggested in some of the commented lines.  Before attempting to run the scripts, verify that the user has execution permissions (run `ls -l` on the directory *src/* to display file permissions).  If not, the file can be made executable by running `chmod u+x` *filename.sh*

Building Executable Files from Fortran Source Code
--------------------------------------------------

If executable files for the programs thresh, nwsfmt, and tsthresh are not available for your computer's operating system, it is necessary to compile the code.  Any compiler that supports Fortran 95, such as GNU Fortran (https://gcc.gnu.org/wiki/GFortran), must be installed on the system in order to compile the Fortran source code and run all of the scripts.  Once a suitable Fortran compiler is available on the system, and the thresh software distribution has been copied to the desired location in your user directory, the programs can be compiled and linked from the command line.  For the example below, we'll assume that the user has renamed the top level folder of this distribution "LandslideThresholds" and installed it in the home directory (~).

Change the present working directory to `~/LandslideThresholds/src/thresh`, type `make` and press return to build the program thresh.  The makefile may require editing if using a complier other than gfortran.  Once you have successfully compiled thresh, change to the source directory `LandslideThresholds/src/nwsfmt` and repeat to build the program nwsfmt and then change to `LandslideThresholds/src/tsthresh` to build the program tsthresh:

    cd ~/LandslideThresholds/src/thresh
    make
    cd ~/LandslideThresholds/src/nwsfmt
    make
    cd ~/LandslideThresholds/src/tsthresh
    make

