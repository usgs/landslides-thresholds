LICENSE
=======

Unless otherwise noted, This software is in the public domain because it contains materials that originally came from the United States Geological Survey, an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at <http://www.usgs.gov/visual-id/credit_usgs.html#copyright>

Dependencies
============

The Fortran source code can be compiled using freely available gfortran (http://gcc.gnu.org/fortran/) or any of the commercially available Fortran compilers that support Fortran 95.  Sample make files are included, but they might require editing in order to work on specific platforms or with other compilers.  

The Python code can be run with a Python 2.7 interpreter.  Minor to moderate revision of individual scripts might be needed to run them using Python 3.  The external packages, such as matplotlib, can either be installed individually or they are available in the Anaconda distribution available at no cost for Windows, OSX, and Linux operating systems from https://www.continuum.io/downloads.

Sample shell scripts are included to demonstrate how the Python scripts and Fortran programs work together automatically to track precipitation thresholds for landslides and provide visualization of threshold and related hill-slope data.  Windows batch files that perform functions equivalent to the shell scripts are also provided.

The Python and Shell scripts in this distribution make calls to a number of Unix/Linux commands for text filtering and file retrieval.  Using this distribution under the Windows operating system requires installation of Cygwin (http://cygwin.com) and a package of Unix commands that have been ported to Windows and are available at http://unxutils.sourceforge.net/.

