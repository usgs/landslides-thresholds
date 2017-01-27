ReadMe!
=======

Dependencies
------------

Python version 2 (preferably Python 2.7.10 or later), including a number of Python libraries, must be installed on the system in order to run all of the scripts in this directory.  These include the following: 

Python 2.7.10, or later
matplotlib 1.43, or later
NumPy 1.9.2, or later
pandas 0.16.2, or later
xmltodict 0.9.2, or later

The easiest way to obtain all of the necessary Python libraries is probably to install Anaconda (https://www.continuum.io/downloads).

Installing xmltodict
--------------------
Once Anaconda has been installed on your system, it will be necessary to install xmltodict separately if you plan to run the script Forecast.py.  None of the other scripts depend on xmltodict.  For this example, we'll assume that anaconda was installed in your home directory.  Its location may be different on your system.  The simplest way to install is using pip. From the command line navigate to the anaconda directory and run the command `pip install`:

	cd ~/anaconda
	./bin/pip install xmltodict

Some users have experienced server errors when trying to install xmltodict using pip.  If you receive an error message, then you can install using the setup tools.  In your web browser, navigate to 
https://pypi.python.org/simple/xmltodict/ and download the latest version of the xmltodict package.
Unpack the zipped archive.
From the command line, run the setup script (see https://wiki.python.org/moin/CheeseShopTutorial)
The basic command is `python setup.py install`.  For example, if the xmltodict folder was extracted to your desktop, type the following commands:
 
	cd ~/anaconda
	./bin/python ~/Desktop/xmltodict-0.10.2/setup.py install
	
Note that it might be necessary to copy the files xmltodict.py and xmltodict.pyc to the folder ~/anaconda/lib/python2.7/site-packages/ after running setup.
